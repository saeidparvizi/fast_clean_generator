// lib/src/generators/bindings_generator.dart

import 'dart:io';
import '../helpers/naming_helpers.dart';

class BindingGenerator {
  BindingGenerator._();

  static Future<String> generate({
    required String projectName,
    required String feature,
    required String model,
    required List<String> newCrudMethods,
    required String bindingFilePath,
  }) async {
    final file = File(bindingFilePath);
    String existingContent = '';
    if (file.existsSync()) {
      existingContent = await file.readAsString();
    }

    if (existingContent.isEmpty) {
      return _generateNewBinding(projectName, feature, model, newCrudMethods);
    }

    return _updateExistingBinding(existingContent, projectName, feature, model, newCrudMethods);
  }

  static String _generateNewBinding(
    String projectName,
    String feature,
    String model,
    List<String> crudMethods,
  ) {
    final buffer = StringBuffer();
    _writeHeader(buffer, projectName, feature);
    _writeModelSpecificImports(buffer, projectName, feature, model, crudMethods);
    
    final pascalFeature = toPascal(feature);
    buffer.writeln('\nclass ${pascalFeature}Binding extends Bindings {');
    buffer.writeln('  @override');
    buffer.writeln('  void dependencies() {');
    
    // Core Dependencies (only once)
    buffer.writeln('    // Data Sources');
    buffer.writeln('    Get.lazyPut(() => ${pascalFeature}RemoteDataImp());\n');
    buffer.writeln('    // Repositories');
    buffer.writeln('    Get.lazyPut(');
    buffer.writeln('      () => ${pascalFeature}RepositoryImpl(');
    buffer.writeln('        remoteData: Get.find<${pascalFeature}RemoteDataImp>(),');
    buffer.writeln('        executor: Get.find<RepositoryExecutor>(),),');
    buffer.writeln('    );\n');

    _writeModelDependencies(buffer, feature, model, crudMethods);

    buffer.writeln('  }');
    buffer.writeln('}');
    return buffer.toString();
  }

  static String _updateExistingBinding(
    String content,
    String projectName,
    String feature,
    String model,
    List<String> crudMethods,
  ) {
    final lines = content.split('\n');
    final resultLines = <String>[];
    
    // 1. Manage Imports
    final existingImports = <String>{};
    int lastImportIndex = -1;
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].trim().startsWith('import ')) {
        existingImports.add(lines[i].trim());
        lastImportIndex = i;
      }
      resultLines.add(lines[i]);
    }

    final newImports = _getModelImports(projectName, feature, model, crudMethods);
    int addedImportsCount = 0;
    for (final imp in newImports) {
      if (!existingImports.contains(imp)) {
        resultLines.insert(lastImportIndex + 1 + addedImportsCount, imp);
        addedImportsCount++;
      }
    }

    // 2. Manage dependencies block
    int depStartIndex = -1;
    int depEndIndex = -1;
    for (int i = 0; i < resultLines.length; i++) {
      if (resultLines[i].contains('void dependencies()')) {
        depStartIndex = i;
      }
      if (depStartIndex != -1 && resultLines[i].trim() == '}') {
        depEndIndex = i;
        break;
      }
    }

    if (depStartIndex != -1 && depEndIndex != -1) {
      final depBlock = resultLines.sublist(depStartIndex, depEndIndex).join('\n');
      final newDepsBuffer = StringBuffer();
      _writeModelDependencies(newDepsBuffer, feature, model, crudMethods);
      
      // Filter out lines already present in the block
      final newLines = newDepsBuffer.toString().split('\n');
      final linesToInsert = <String>[];
      for (final line in newLines) {
        final trimmed = line.trim();
        if (trimmed.isNotEmpty && !depBlock.contains(trimmed)) {
          linesToInsert.add('    $trimmed');
        }
      }
      
      if (linesToInsert.isNotEmpty) {
        resultLines.insertAll(depEndIndex, linesToInsert);
      }
    }

    return resultLines.join('\n');
  }

  static void _writeHeader(StringBuffer buffer, String projectName, String feature) {
    buffer.writeln("import 'package:get/get.dart';");
    buffer.writeln("import 'package:$projectName/core/utils/repository_executor.dart';");
    buffer.writeln("import 'package:$projectName/features/$feature/data/data_sources/${feature}_remote_data.dart';");
    buffer.writeln("import 'package:$projectName/features/$feature/data/repositories/${feature}_repository_impl.dart';");
    buffer.writeln("import 'package:$projectName/features/$feature/domain/repositories/${feature}_repository.dart';");
  }

  static List<String> _getModelImports(String projectName, String feature, String model, List<String> crudMethods) {
    final snakeModel = toSnakeFromName(model);
    final pascalModel = toPascal(model);
    final pluralSnake = toSnakeFromName(pluralize(model));
    
    final imports = [
      "import 'package:$projectName/features/$feature/presentation/controllers/${snakeModel}s_controller.dart';",
      if (crudMethods.contains('get') || crudMethods.contains('update'))
        "import 'package:$projectName/features/$feature/presentation/controllers/${snakeModel}_controller.dart';",
    ];

    if (crudMethods.contains('list')) {
      imports.add("import 'package:$projectName/features/$feature/domain/usecases/${pluralSnake}_usecase.dart';");
    }
    if (crudMethods.contains('get')) {
      imports.add("import 'package:$projectName/features/$feature/domain/usecases/get_${snakeModel}_usecase.dart';");
    }
    if (crudMethods.contains('add')) {
      imports.add("import 'package:$projectName/features/$feature/domain/usecases/add_${snakeModel}_usecase.dart';");
    }
    if (crudMethods.contains('update')) {
      imports.add("import 'package:$projectName/features/$feature/domain/usecases/update_${snakeModel}_usecase.dart';");
    }
    if (crudMethods.contains('delete')) {
      imports.add("import 'package:$projectName/features/$feature/domain/usecases/delete_${snakeModel}_usecase.dart';");
    }

    return imports;
  }

  static void _writeModelSpecificImports(StringBuffer buffer, String projectName, String feature, String model, List<String> crudMethods) {
    final imports = _getModelImports(projectName, feature, model, crudMethods);
    for (final imp in imports) {
      buffer.writeln(imp);
    }
  }

  static void _writeModelDependencies(StringBuffer buffer, String feature, String model, List<String> crudMethods) {
    final pascalModel = toPascal(model);
    final pluralPascal = pluralize(pascalModel);
    final pluralCamel = toCamel(pluralPascal);
    final pascalFeature = toPascal(feature);

    buffer.writeln('    // Use Cases ($pascalModel)');
    if (crudMethods.contains('list')) {
      buffer.writeln('    Get.lazyPut(() => ${pluralPascal}UseCase(repository: Get.find<${pascalFeature}RepositoryImpl>()),);');
    }
    if (crudMethods.contains('get')) {
      buffer.writeln('    Get.lazyPut(() => Get${pascalModel}UseCase(repository: Get.find<${pascalFeature}RepositoryImpl>()),);');
    }
    if (crudMethods.contains('add')) {
      buffer.writeln('    Get.lazyPut(() => Add${pascalModel}UseCase(repository: Get.find<${pascalFeature}RepositoryImpl>()),);');
    }
    if (crudMethods.contains('update')) {
      buffer.writeln('    Get.lazyPut(() => Update${pascalModel}UseCase(repository: Get.find<${pascalFeature}RepositoryImpl>()),);');
    }
    if (crudMethods.contains('delete')) {
      buffer.writeln('    Get.lazyPut(() => Delete${pascalModel}UseCase(repository: Get.find<${pascalFeature}RepositoryImpl>()),);');
    }

    buffer.writeln('\n    // Controllers ($pascalModel)');
    buffer.writeln('    Get.lazyPut(() => ${pascalModel}sController(');
    if (crudMethods.contains('list')) buffer.writeln('      ${pluralCamel}UseCase: Get.find<${pluralPascal}UseCase>(),');
    if (crudMethods.contains('add')) buffer.writeln('      add${pascalModel}UseCase: Get.find<Add${pascalModel}UseCase>(),');
    if (crudMethods.contains('update')) buffer.writeln('      update${pascalModel}UseCase: Get.find<Update${pascalModel}UseCase>(),');
    if (crudMethods.contains('delete')) buffer.writeln('      delete${pascalModel}UseCase: Get.find<Delete${pascalModel}UseCase>(),');
    buffer.writeln('    ),);');

    if (crudMethods.contains('get') || crudMethods.contains('update')) {
      buffer.writeln('    Get.lazyPut(() => ${pascalModel}Controller(');
      if (crudMethods.contains('get')) buffer.writeln('      get${pascalModel}UseCase: Get.find<Get${pascalModel}UseCase>(),');
      if (crudMethods.contains('update')) buffer.writeln('      update${pascalModel}UseCase: Get.find<Update${pascalModel}UseCase>(),');
      buffer.writeln('    ),);');
    }
  }
}

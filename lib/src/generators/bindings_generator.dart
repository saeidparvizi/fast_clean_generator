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

    if (existingContent.trim().isEmpty) {
      return _generateNewBinding(projectName, feature, model, newCrudMethods);
    }

    return _updateExistingBinding(
        existingContent, projectName, feature, model, newCrudMethods);
  }

  static String _generateNewBinding(
    String projectName,
    String feature,
    String model,
    List<String> crudMethods,
  ) {
    final buffer = StringBuffer();
    _writeHeader(buffer, projectName, feature);
    _writeModelSpecificImports(
        buffer, projectName, feature, model, crudMethods);

    final pascalFeature = toPascal(feature);
    buffer.writeln('\nclass ${pascalFeature}Binding extends Bindings {');
    buffer.writeln('  @override');
    buffer.writeln('  void dependencies() {');

    buffer.writeln('    // Data Sources');
    buffer.writeln('    Get.lazyPut(() => ${pascalFeature}RemoteDataImp());\n');
    buffer.writeln('    // Repositories');
    buffer.writeln('    Get.lazyPut(');
    buffer.writeln('      () => ${pascalFeature}RepositoryImpl(');
    buffer.writeln(
        '        remoteData: Get.find<${pascalFeature}RemoteDataImp>(),');
    buffer.writeln('        executor: Get.find<RepositoryExecutor>(),),');
    buffer.writeln('    );\n');

    buffer.writeln('    // Use Cases');
    buffer.writeln('    // Controllers');
    buffer.writeln('  }'); // Close dependencies
    buffer.writeln('}'); // Close class

    // Now update the complete shell with the model logic
    return _updateExistingBinding(
        buffer.toString(), projectName, feature, model, crudMethods);
  }

  static String _updateExistingBinding(
    String content,
    String projectName,
    String feature,
    String model,
    List<String> crudMethods,
  ) {
    var updatedContent = content;

    // 1. Manage Imports
    final newImports =
        _getModelImports(projectName, feature, model, crudMethods);
    for (final imp in newImports) {
      if (!updatedContent.contains(imp)) {
        updatedContent = '$imp\n$updatedContent';
      }
    }

    final pascalModel = toPascal(model);
    final pluralPascal = pluralize(pascalModel);
    final pascalFeature = toPascal(feature);
    final pluralCamel = toCamel(pluralize(model));

    // 2. Add Missing UseCases
    final useCaseMap = {
      'list': '${pluralPascal}UseCase',
      'get': 'Get${pascalModel}UseCase',
      'add': 'Add${pascalModel}UseCase',
      'update': 'Update${pascalModel}UseCase',
      'delete': 'Delete${pascalModel}UseCase',
    };

    for (var entry in useCaseMap.entries) {
      if (crudMethods.contains(entry.key)) {
        if (!updatedContent.contains('() => ${entry.value}')) {
          final newUseCase =
              '    Get.lazyPut(() => ${entry.value}(repository: Get.find<${pascalFeature}RepositoryImpl>()),);';
          updatedContent =
              _injectIntoSection(updatedContent, newUseCase, '// Use Cases');
        }
      }
    }

    // 3. Update Controllers
    final controllers = [
      {'name': '${pluralPascal}Controller', 'isList': true},
      {'name': '${pascalModel}Controller', 'isList': false},
    ];

    for (var ctrl in controllers) {
      final ctrlName = ctrl['name'] as String;
      final isList = ctrl['isList'] as bool;

      if (!updatedContent.contains('() => $ctrlName')) {
        if ((isList &&
                crudMethods.any(
                    (m) => ['list', 'add', 'update', 'delete'].contains(m))) ||
            (!isList &&
                (crudMethods.contains('get') ||
                    crudMethods.contains('update')))) {
          final buffer = StringBuffer();
          _writeControllerBlock(buffer, ctrlName, model, crudMethods,
              isList: isList);
          updatedContent = _injectIntoSection(
              updatedContent, buffer.toString(), '// Controllers');
        }
      } else {
        final params = isList
            ? {
                'list':
                    '${pluralCamel}UseCase: Get.find<${pluralPascal}UseCase>(),',
                'add':
                    'add${pascalModel}UseCase: Get.find<Add${pascalModel}UseCase>(),',
                'update':
                    'update${pascalModel}UseCase: Get.find<Update${pascalModel}UseCase>(),',
                'delete':
                    'delete${pascalModel}UseCase: Get.find<Delete${pascalModel}UseCase>(),',
              }
            : {
                'get':
                    'get${pascalModel}UseCase: Get.find<Get${pascalModel}UseCase>(),',
                'update':
                    'update${pascalModel}UseCase: Get.find<Update${pascalModel}UseCase>(),',
              };

        for (var entry in params.entries) {
          if (crudMethods.contains(entry.key)) {
            final paramName = entry.value.split(':')[0].trim();
            final ctrlPattern = RegExp(
                '($ctrlName\\s*\\([\\s\\S]*?)(\\s*\\)(\\s*,)?\\s*\\)\\s*;)');
            updatedContent =
                updatedContent.replaceFirstMapped(ctrlPattern, (m) {
              final head = m.group(1)!;
              final tail = m.group(2)!;
              if (head.contains(paramName)) return m.group(0)!;
              return '$head\n      ${entry.value}$tail';
            });
          }
        }
      }
    }

    return updatedContent;
  }

  static String _injectIntoSection(
      String content, String code, String sectionTag) {
    if (content.contains(sectionTag)) {
      return content.replaceFirst(sectionTag, '$sectionTag\n$code');
    }
    final lastBraceIndex = content.lastIndexOf('}');
    if (lastBraceIndex == -1) return content;
    final depEndIndex = content.lastIndexOf('}', lastBraceIndex - 1);
    if (depEndIndex == -1) return content;
    return '${content.substring(0, depEndIndex)}$code\n${content.substring(depEndIndex)}';
  }

  static void _writeControllerBlock(StringBuffer buffer, String ctrlName,
      String model, List<String> crudMethods,
      {required bool isList}) {
    final pascalModel = toPascal(model);
    final pluralPascal = pluralize(pascalModel);
    final pluralCamel = toCamel(pluralize(model));

    buffer.writeln('    Get.lazyPut(() => $ctrlName(');
    if (isList) {
      if (crudMethods.contains('list')) {
        buffer.writeln(
            '      ${pluralCamel}UseCase: Get.find<${pluralPascal}UseCase>(),');
      }
      if (crudMethods.contains('add')) {
        buffer.writeln(
            '      add${pascalModel}UseCase: Get.find<Add${pascalModel}UseCase>(),');
      }
      if (crudMethods.contains('update')) {
        buffer.writeln(
            '      update${pascalModel}UseCase: Get.find<Update${pascalModel}UseCase>(),');
      }
      if (crudMethods.contains('delete')) {
        buffer.writeln(
            '      delete${pascalModel}UseCase: Get.find<Delete${pascalModel}UseCase>(),');
      }
    } else {
      if (crudMethods.contains('get')) {
        buffer.writeln(
            '      get${pascalModel}UseCase: Get.find<Get${pascalModel}UseCase>(),');
      }
      if (crudMethods.contains('update')) {
        buffer.writeln(
            '      update${pascalModel}UseCase: Get.find<Update${pascalModel}UseCase>(),');
      }
    }
    buffer.writeln('    ),);');
  }

  static void _writeHeader(
      StringBuffer buffer, String projectName, String feature) {
    final snakeFeature = toSnakeFromName(feature);
    buffer.writeln("import 'package:get/get.dart';");
    buffer.writeln(
        "import 'package:$projectName/core/utils/repository_executor.dart';");
    buffer.writeln(
        "import 'package:$projectName/features/$feature/data/data_sources/${snakeFeature}_remote_data.dart';");
    buffer.writeln(
        "import 'package:$projectName/features/$feature/data/repositories/${snakeFeature}_repository_impl.dart';");
    buffer.writeln(
        "import 'package:$projectName/features/$feature/domain/repositories/${snakeFeature}_repository.dart';");
  }

  static List<String> _getModelImports(String projectName, String feature,
      String model, List<String> crudMethods) {
    final snakeModel = toSnakeFromName(model);
    final pluralSnake = toSnakeFromName(pluralize(model));
    final imports = [
      "import 'package:$projectName/features/$feature/presentation/controllers/${pluralSnake}_controller.dart';",
      if (crudMethods.contains('get') || crudMethods.contains('update'))
        "import 'package:$projectName/features/$feature/presentation/controllers/${snakeModel}_controller.dart';",
    ];
    if (crudMethods.contains('list')) {
      imports.add(
          "import 'package:$projectName/features/$feature/domain/usecases/${pluralSnake}_usecase.dart';");
    }
    if (crudMethods.contains('get')) {
      imports.add(
          "import 'package:$projectName/features/$feature/domain/usecases/get_${snakeModel}_usecase.dart';");
    }
    if (crudMethods.contains('add')) {
      imports.add(
          "import 'package:$projectName/features/$feature/domain/usecases/add_${snakeModel}_usecase.dart';");
    }
    if (crudMethods.contains('update')) {
      imports.add(
          "import 'package:$projectName/features/$feature/domain/usecases/update_${snakeModel}_usecase.dart';");
    }
    if (crudMethods.contains('delete')) {
      imports.add(
          "import 'package:$projectName/features/$feature/domain/usecases/delete_${snakeModel}_usecase.dart';");
    }
    return imports;
  }

  static void _writeModelSpecificImports(
      StringBuffer buffer,
      String projectName,
      String feature,
      String model,
      List<String> crudMethods) {
    final imports = _getModelImports(projectName, feature, model, crudMethods);
    for (final imp in imports) {
      buffer.writeln(imp);
    }
  }
}

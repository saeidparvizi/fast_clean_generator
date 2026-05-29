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
    final existingMethods = await _extractExistingCrudMethods(bindingFilePath);
    final allMethods = _mergeCrudMethods(existingMethods, newCrudMethods);

    return _generateBindingContent(
      projectName: projectName,
      feature: feature,
      model: model,
      crudMethods: allMethods,
    );
  }

  static Future<List<String>> _extractExistingCrudMethods(
    String filePath,
  ) async {
    final file = File(filePath);
    if (!file.existsSync()) {
      return [];
    }

    final content = await file.readAsString();
    final methods = <String>[];

    final useCaseMap = {
      'Get': 'get',
      'Add': 'add',
      'Update': 'update',
      'Delete': 'delete',
    };

    // Detect regular use cases (GetTask, AddTask, etc.)
    for (final entry in useCaseMap.entries) {
      final pattern = RegExp('Get\\.lazyPut.*=>\\s*${entry.key}', dotAll: true);
      if (pattern.hasMatch(content)) {
        methods.add(entry.value);
      }
    }

    // Detect list use cases (plural)
    final listPattern = RegExp(r'Get\.lazyPut\(\(\) => (\w+)UseCase');
    final listMatches = listPattern.allMatches(content);
    for (final match in listMatches) {
      final className = match.group(1) ?? '';
      // If class name starts with uppercase and ends with 's' (plural)
      if (className.length > 1 &&
          className[0] == className[0].toUpperCase() &&
          className.endsWith('s') &&
          !useCaseMap.keys.any((key) => className.startsWith(key))) {
        methods.add('list');
        break;
      }
    }

    return methods.toSet().toList();
  }

  static List<String> _mergeCrudMethods(
    List<String> existing,
    List<String> newMethods,
  ) {
    final merged = {...existing, ...newMethods};
    return merged.toList();
  }

  static String _generateBindingContent({
    required String projectName,
    required String feature,
    required String model,
    required List<String> crudMethods,
  }) {
    final buffer = StringBuffer();

    _generateImports(buffer, projectName, feature, model, crudMethods);
    _generateBindingClass(buffer, projectName, feature, model, crudMethods);

    return buffer.toString();
  }

  static void _generateImports(
    StringBuffer buffer,
    String projectName,
    String feature,
    String model,
    List<String> crudMethods,
  ) {
    final snakeModel = toSnakeFromName(model);

    buffer.writeln("import 'package:get/get.dart';");
    buffer.writeln(
      "import 'package:$projectName/core/utils/repository_executor.dart';",
    );

    // Data sources
    buffer.writeln(
      "import 'package:$projectName/features/$feature/data/data_sources/${feature}_remote_data.dart';",
    );

    // Repositories
    buffer.writeln(
      "import 'package:$projectName/features/$feature/data/repositories/${feature}_repository_impl.dart';",
    );
    buffer.writeln(
      "import 'package:$projectName/features/$feature/domain/repositories/${feature}_repository.dart';",
    );

    // Use cases
    _generateUseCaseImports(buffer, projectName, feature, model, crudMethods);

    // Controller
    buffer.writeln(
      "import 'package:$projectName/features/$feature/presentation/controllers/${snakeModel}s_controller.dart';",
    );
    buffer.writeln();
  }

  static void _generateUseCaseImports(
    StringBuffer buffer,
    String projectName,
    String feature,
    String model,
    List<String> crudMethods,
  ) {
    final pascalModel = toPascal(model);
    final snakeModel = toSnakeFromName(model);
    final pluralPascalModel = pluralize(pascalModel);
    final pluralSnakeModel = toSnakeFromName(pluralPascalModel);

    final useCaseMap = {
      'get': {
        'file': 'get_${snakeModel}_usecase.dart',
        'class': 'Get${pascalModel}UseCase',
      },
      'list': {
        'file': '${pluralSnakeModel}_usecase.dart',
        'class': '${pluralPascalModel}UseCase',
      },
      'add': {
        'file': 'add_${snakeModel}_usecase.dart',
        'class': 'Add${pascalModel}UseCase',
      },
      'update': {
        'file': 'update_${snakeModel}_usecase.dart',
        'class': 'Update${pascalModel}UseCase',
      },
      'delete': {
        'file': 'delete_${snakeModel}_usecase.dart',
        'class': 'Delete${pascalModel}UseCase',
      },
    };

    for (final method in crudMethods) {
      final methodLower = method.toLowerCase();
      final useCaseInfo = useCaseMap[methodLower];

      if (useCaseInfo != null) {
        buffer.writeln(
          "import 'package:$projectName/features/$feature/domain/usecases/${useCaseInfo['file']}';",
        );
      }
    }
  }

  static void _generateBindingClass(
    StringBuffer buffer,
    String projectName,
    String feature,
    String model,
    List<String> crudMethods,
  ) {
    final pascalFeature = toPascal(feature);

    buffer.writeln('class ${pascalFeature}Binding extends Bindings {');
    buffer.writeln('  @override');
    buffer.writeln('  void dependencies() {');

    _generateDependencies(buffer, feature, model, crudMethods);

    buffer.writeln('  }');
    buffer.writeln('}');
  }

  static void _generateDependencies(
    StringBuffer buffer,
    String feature,
    String model,
    List<String> crudMethods,
  ) {
    final pascalFeature = toPascal(feature);

    // Remote Data
    buffer.writeln('    // Data Sources');
    buffer.writeln('    Get.lazyPut(() => ${pascalFeature}RemoteDataImp());');
    buffer.writeln();

    // Repository
    buffer.writeln('    // Repositories');
    buffer.writeln('    Get.lazyPut(');
    buffer.writeln(
      '      () => ${pascalFeature}RepositoryImpl('
      '\n        remoteData: Get.find<${pascalFeature}RemoteDataImp>(),'
      '\n        executor: Get.find<RepositoryExecutor>(),),',
    );
    buffer.writeln('    );');
    buffer.writeln();

    // Use Cases
    _generateUseCaseDependencies(buffer, feature, model, crudMethods);
    buffer.writeln();

    // Controller
    _generateControllerDependency(buffer, feature, model, crudMethods);
  }

  static void _generateUseCaseDependencies(
    StringBuffer buffer,
    String feature,
    String model,
    List<String> crudMethods,
  ) {
    final pascalFeature = toPascal(feature);
    final pascalModel = toPascal(model);
    final pluralPascalModel = pluralize(pascalModel);

    final useCaseMap = {
      'get': 'Get${pascalModel}UseCase',
      'list': '${pluralPascalModel}UseCase',
      'add': 'Add${pascalModel}UseCase',
      'update': 'Update${pascalModel}UseCase',
      'delete': 'Delete${pascalModel}UseCase',
    };

    buffer.writeln('    // Use Cases');
    for (final method in crudMethods) {
      final methodLower = method.toLowerCase();
      final className = useCaseMap[methodLower];

      if (className != null) {
        buffer.writeln(
          '    Get.lazyPut(() => $className(repository: Get.find<${pascalFeature}RepositoryImpl>()),);',
        );
      }
    }
  }

  static void _generateControllerDependency(
    StringBuffer buffer,
    String feature,
    String model,
    List<String> crudMethods,
  ) {
    final pascalModel = toPascal(model);
    final pluralPascalModel = pluralize(pascalModel);
    final pluralSnakeModel = toSnakeFromName(pluralPascalModel);

    final paramMap = {
      'get': {
        'name': 'get${pascalModel}UseCase',
        'class': 'Get${pascalModel}UseCase',
      },
      'list': {
        'name': '${pluralSnakeModel}UseCase',
        'class': '${pluralPascalModel}UseCase',
      },
      'add': {
        'name': 'add${pascalModel}UseCase',
        'class': 'Add${pascalModel}UseCase',
      },
      'update': {
        'name': 'update${pascalModel}UseCase',
        'class': 'Update${pascalModel}UseCase',
      },
      'delete': {
        'name': 'delete${pascalModel}UseCase',
        'class': 'Delete${pascalModel}UseCase',
      },
    };

    buffer.writeln('    // Controller');
    buffer.writeln('    Get.lazyPut(() => ${pascalModel}sController(');

    final controllersParams = <String>[];
    for (final method in crudMethods) {
      final methodLower = method.toLowerCase();
      final paramInfo = paramMap[methodLower];

      if (paramInfo != null && method != 'get') {
        controllersParams.add(
          '${paramInfo['name']}: Get.find<${paramInfo['class']}>()',
        );
      }
    }

    // Add parameters with beautiful formatting
    for (int i = 0; i < controllersParams.length; i++) {
      buffer.writeln('      ${controllersParams[i]},');
    }

    buffer.writeln('    ),);');
  }
}

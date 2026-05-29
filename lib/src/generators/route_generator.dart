// lib/src/generators/route_generator.dart
import 'dart:io';
import '../helpers/naming_helpers.dart';

String generateFeatureRoutes({
  required String className,
  required String feature,
  required String projectName,
  required List<String> crudMethods,
  required String routesFilePath,
}) {
  final pascalModel = toPascal(className);
  final snakeModel = toSnakeFromName(className);
  final pascalFeature = toPascal(feature);

  // Read existing file content
  final existingContent = _readExistingRoutes(routesFilePath);

  if (existingContent.isEmpty) {
    return _createNewRoutesFile(
      className,
      feature,
      projectName,
      crudMethods,
      pascalModel,
      snakeModel,
      pascalFeature,
    );
  }

  // Add only new imports and routes, keeping existing content intact
  return _addOnlyNewImportsAndRoutes(
    existingContent,
    className,
    feature,
    projectName,
    crudMethods,
    pascalModel,
    snakeModel,
    pascalFeature,
  );
}

String _createNewRoutesFile(
  String className,
  String feature,
  String projectName,
  List<String> crudMethods,
  String pascalModel,
  String snakeModel,
  String pascalFeature,
) {
  final buffer = StringBuffer();

  _writeBaseImports(buffer, projectName, feature, snakeModel);
  _writeCrudImports(buffer, projectName, feature, snakeModel, crudMethods);
  buffer.writeln("import 'package:get/get.dart';");
  buffer.writeln();

  buffer.writeln('List<GetPage> ${feature}Routes = [');

  // Add new routes
  _writeNewRoutes(buffer, className, pascalFeature, crudMethods);

  buffer.writeln('];');

  return buffer.toString();
}

String _addOnlyNewImportsAndRoutes(
  String existingContent,
  String className,
  String feature,
  String projectName,
  List<String> crudMethods,
  String pascalModel,
  String snakeModel,
  String pascalFeature,
) {
  // 1. Get file lines
  final lines = existingContent.split('\n');
  final resultLines = <String>[];

  // 2. Collect existing imports
  final existingImports = <String>{};
  int lastImportIndex = -1;

  for (int i = 0; i < lines.length; i++) {
    if (lines[i].trim().startsWith('import ')) {
      existingImports.add(lines[i].trim());
      lastImportIndex = i;
    }
    resultLines.add(lines[i]);
  }

  // 3. Add new imports if they don't exist
  final newImports = _getNewImports(
    existingImports,
    projectName,
    feature,
    snakeModel,
    crudMethods,
  );

  if (newImports.isNotEmpty && lastImportIndex >= 0) {
    // Insert new imports after the last existing one
    for (final newImport in newImports) {
      resultLines.insert(lastImportIndex + 1, newImport);
      lastImportIndex++;
    }
  }

  // 4. Add new routes before the closing bracket
  final newRoutes = _getNewRoutes(
    existingContent,
    className,
    pascalFeature,
    crudMethods,
  );

  if (newRoutes.isNotEmpty) {
    // Find ]; and insert new routes before it
    for (int i = resultLines.length - 1; i >= 0; i--) {
      if (resultLines[i].trim() == '];') {
        for (final newRoute in newRoutes.reversed) {
          resultLines.insert(i, newRoute);
        }
        break;
      }
    }
  }

  return resultLines.join('\n');
}

void _writeBaseImports(
  StringBuffer buffer,
  String projectName,
  String feature,
  String snakeModel,
) {
  buffer.writeln("import 'package:$projectName/core/routes/app_pages.dart';");
  buffer.writeln(
    "import 'package:$projectName/features/$feature/presentation/bindings/${feature}_binding.dart';",
  );
}

void _writeCrudImports(
  StringBuffer buffer,
  String projectName,
  String feature,
  String snakeModel,
  List<String> crudMethods,
) {
  if (crudMethods.contains('list')) {
    buffer.writeln(
      "import 'package:$projectName/features/$feature/presentation/pages/${pluralize(snakeModel)}_screen.dart';",
    );
  }

  if (crudMethods.contains('get')) {
    buffer.writeln(
      "import 'package:$projectName/features/$feature/presentation/pages/${snakeModel}_screen.dart';",
    );
  }

  if (crudMethods.contains('add')) {
    buffer.writeln(
      "import 'package:$projectName/features/$feature/presentation/pages/add_${snakeModel}_screen.dart';",
    );
  }

  if (crudMethods.contains('update')) {
    buffer.writeln(
      "import 'package:$projectName/features/$feature/presentation/pages/edit_${snakeModel}_screen.dart';",
    );
  }
}

List<String> _getNewImports(
  Set<String> existingImports,
  String projectName,
  String feature,
  String snakeModel,
  List<String> crudMethods,
) {
  final newImports = <String>[];
  final pluralSnake = pluralize(snakeModel);

  final importsToCheck = [
    if (crudMethods.contains('list'))
      "import 'package:$projectName/features/$feature/presentation/pages/${pluralSnake}_screen.dart';",
    if (crudMethods.contains('get'))
      "import 'package:$projectName/features/$feature/presentation/pages/${snakeModel}_screen.dart';",
    if (crudMethods.contains('add'))
      "import 'package:$projectName/features/$feature/presentation/pages/add_${snakeModel}_screen.dart';",
    if (crudMethods.contains('update'))
      "import 'package:$projectName/features/$feature/presentation/pages/edit_${snakeModel}_screen.dart';",
  ];

  for (final import in importsToCheck) {
    // Better check: check the exact file name at the end of the import
    final fileName = import.split('/').last;
    if (!existingImports.any((existing) => existing.contains(fileName))) {
      newImports.add(import);
    }
  }

  return newImports;
}

List<String> _getNewRoutes(
  String existingContent,
  String className,
  String pascalFeature,
  List<String> crudMethods,
) {
  final newRoutes = <String>[];
  final String pascalModel = toPascal(className);
  final String snakeModel = toSnakeFromName(className);
  final String camelModel = toCamel(className);

  // Potential routes
  final potentialRoutes = <String, String>{
    if (crudMethods.contains('list'))
      pluralize(className): '''
  GetPage(
    name: AppRoutes.${pluralize(camelModel)},
    page: () => const ${pluralize(pascalModel)}Screen(),
    binding: ${pascalFeature}Binding(),
  ),''',
    if (crudMethods.contains('get'))
      className: '''
  GetPage(
    name: AppRoutes.$camelModel,
    page: () => const ${(pascalModel)}Screen(),
    binding: ${pascalFeature}Binding(),
  ),''',
    if (crudMethods.contains('add'))
      '${snakeModel}Add': '''
  GetPage(
    name: AppRoutes.${camelModel}Add,
    page: () => const Add${pascalModel}Screen(),
    binding: ${pascalFeature}Binding(),
  ),''',
    if (crudMethods.contains('update'))
      '${snakeModel}Edit': '''
  GetPage(
    name: AppRoutes.${camelModel}Edit,
    page: () => const Edit${pascalModel}Screen(),
    binding: ${pascalFeature}Binding(),
  ),''',
  };

  // Check if route name already exists in content
  for (final routeName in potentialRoutes.keys) {
    final routeContent = potentialRoutes[routeName]!;

    final nameMatch = RegExp(
      r'name:\s*(AppRoutes\.\w+)',
    ).firstMatch(routeContent);
    if (nameMatch != null) {
      final routeNamePattern = nameMatch.group(1)!;

      if (!existingContent.contains(routeNamePattern)) {
        newRoutes.add(routeContent);
      }
    }
  }

  return newRoutes;
}

void _writeNewRoutes(
  StringBuffer buffer,
  String className,
  String pascalFeature,
  List<String> crudMethods,
) {
  final String pascalModel = toPascal(className);
  final String camelModel = toCamel(className);

  if (crudMethods.contains('list')) {
    buffer.writeln('''
  GetPage(
    name: AppRoutes.${pluralize(camelModel)},
    page: () => const ${pluralize(pascalModel)}Screen(),
    binding: ${pascalFeature}Binding(),
  ),''');
  }

  if (crudMethods.contains('get')) {
    buffer.writeln('''
  GetPage(
    name: AppRoutes.$camelModel,
    page: () => const ${(pascalModel)}Screen(),
    binding: ${pascalFeature}Binding(),
  ),''');
  }
  if (crudMethods.contains('add')) {
    buffer.writeln('''
  GetPage(
    name: AppRoutes.${camelModel}Add,
    page: () => const Add${pascalModel}Screen(),
    binding: ${pascalFeature}Binding(),
  ),''');
  }

  if (crudMethods.contains('update')) {
    buffer.writeln('''
  GetPage(
    name: AppRoutes.${camelModel}Edit,
    page: () => const Edit${pascalModel}Screen(),
    binding: ${pascalFeature}Binding(),
  ),''');
  }
}

String _readExistingRoutes(String filePath) {
  final file = File(filePath);
  if (file.existsSync()) {
    return file.readAsStringSync();
  }
  return '';
}

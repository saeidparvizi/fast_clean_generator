import 'dart:io';

import '../helpers/naming_helpers.dart';

/// Generates the updated content for the app_pages.dart file.
String generateFeatureAppPages({
  required String feature,
  required String projectName,
  required String routesFilePath,
}) {
  final snakeFeature = toSnakeFromName(feature);

  // Variable name defined in the feature routes file (e.g., productRoutes)
  final routesVariableName = '${snakeFeature}Routes';

  // Path to the core app_pages.dart file
  const appPagesPath = 'lib/core/routes/app_pages.dart';

  // Read current file content
  final file = File(appPagesPath);
  String existingContent = '';
  if (file.existsSync()) {
    existingContent = file.readAsStringSync();
  }

  // If file doesn't exist or is empty, create a new structure
  if (existingContent.trim().isEmpty) {
    return _createNewAppPagesFile(
      projectName,
      feature,
      routesVariableName,
      routesFilePath,
    );
  }

  // Update existing file
  return _updateExistingAppPagesFile(
    existingContent,
    projectName,
    feature,
    routesVariableName,
    routesFilePath,
  );
}

/// Creates a new app_pages.dart file with the initial structure.
String _createNewAppPagesFile(
  String projectName,
  String feature,
  String routesVariableName,
  String routesFilePath,
) {
  final buffer = StringBuffer();

  buffer.writeln("import 'package:get/get.dart';");
  // Import the new feature route file
  buffer.writeln(
    "import 'package:$projectName/features/$feature/routes/${toSnakeFromName(feature)}_routes.dart';",
  );
  buffer.writeln();
  buffer.writeln("part 'app_routes.dart';");
  buffer.writeln();
  buffer.writeln('class AppPages {');
  buffer.writeln('  AppPages._();');
  buffer.writeln();
  buffer.writeln('  static String get initialRoutes {');
  buffer.writeln('    return AppRoutes.main + AppRoutes.home;');
  buffer.writeln('  }');
  buffer.writeln();
  buffer.writeln('  static List<GetPage> get pages => [');
  buffer.writeln('    ...$routesVariableName,');
  buffer.writeln('  ];');
  buffer.writeln('}');

  return buffer.toString();
}

/// Updates the existing app_pages.dart file (Imports and pages list).
String _updateExistingAppPagesFile(
  String existingContent,
  String projectName,
  String feature,
  String routesVariableName,
  String routesFilePath,
) {
  final lines = existingContent.split('\n');
  final resultLines = <String>[];

  // 1. Manage Imports
  final existingImports = <String>{};
  int lastImportIndex = -1;

  for (int i = 0; i < lines.length; i++) {
    final line = lines[i];
    if (line.trim().startsWith('import ')) {
      existingImports.add(line.trim());
      lastImportIndex = i;
    }
    resultLines.add(line);
  }

  // Build new import
  final newImport =
      "import 'package:$projectName/features/$feature/routes/${toSnakeFromName(feature)}_routes.dart';";

  // Check if import already exists
  final bool importExists = existingImports.any(
    (imp) => imp.contains('/$feature/routes/'),
  );

  if (!importExists && lastImportIndex >= 0) {
    // Add after the last import
    resultLines.insert(lastImportIndex + 1, newImport);
  }

  // 2. Manage pages list
  // Find the line starting with "static List<GetPage> get pages => ["
  // and ending with "];"

  int pagesStartIndex = -1;
  int pagesEndIndex = -1;

  for (int i = 0; i < resultLines.length; i++) {
    if (resultLines[i].contains('static List<GetPage> get pages')) {
      pagesStartIndex = i;
    }
    // Find the end of the block (];)
    if (pagesStartIndex != -1 && resultLines[i].trim().endsWith('];')) {
      pagesEndIndex = i;
      break;
    }
  }

  if (pagesStartIndex != -1 && pagesEndIndex != -1) {
    // Check if the route variable is already added
    bool routeExists = false;
    for (int i = pagesStartIndex; i <= pagesEndIndex; i++) {
      if (resultLines[i].contains('...$routesVariableName')) {
        routeExists = true;
        break;
      }
    }

    if (!routeExists) {
      // Add the new variable before the "];" line
      final insertLine = '    ...$routesVariableName,';
      resultLines.insert(pagesEndIndex, insertLine);
    }
  }

  return resultLines.join('\n');
}

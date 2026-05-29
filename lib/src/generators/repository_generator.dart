// tool/generators/repository_generator.dart
import 'dart:developer';
import 'dart:io';

import '../helpers/file_helpers.dart';
import '../helpers/naming_helpers.dart';

const bool kDebugMode = true;

String generateRepositoryShell(String projectName, String feature) {
  final pascalFeature = toPascal(feature);
  return '''
import 'package:dartz/dartz.dart';
import 'package:$projectName/core/exceptions/failure.dart';

abstract class ${pascalFeature}Repository {
}
''';
}

Future<void> upsertRepository({
  required String projectName,
  required String feature,
  required String className,
  List<String> crudMethods = const ['get', 'list', 'add', 'update', 'delete'],
}) async {
  final repoPath =
      'lib/features/$feature/domain/repositories/${toSnakeFromName(feature)}_repository.dart';
  final file = File(repoPath);

  // if (!await file.exists()) {
  //   final shell = generateRepositoryShell(feature);
  //   await file.create(recursive: true);
  //   await file.writeAsString(shell);
  //   if (kDebugMode) {
  //     log('🆕 Repository shell created: $repoPath');
  //   }
  // }

  if (!file.existsSync()) {
    final shell = generateRepositoryShell(projectName, feature);
    file.createSync(recursive: true);
    file.writeAsStringSync(shell);
    if (kDebugMode) {
      log('🆕 Repository shell created: $repoPath');
    }
  }

  var src = await file.readAsString();

  src = ensureImportOnce(src, "import 'package:dartz/dartz.dart';");
  src = ensureImportOnce(
    src,
    "import 'package:$projectName/core/exceptions/failure.dart';",
  );

  final entityImport =
      "import 'package:$projectName/features/$feature/domain/entities/${toSnakeFromName(className)}_entity.dart';";
  src = ensureImportOnce(src, entityImport);

  final pascalClass = toPascal(className);
  final pluralPascal = pluralize(pascalClass);
  // final pluralSnake = toSnakeFromName(pluralPascal);

  for (final method in crudMethods) {
    String methodName;
    String returnType;
    switch (method.toLowerCase()) {
      case 'get':
        methodName = 'get$pascalClass';
        returnType = 'Future<Either<Failure, ${pascalClass}Entity>>';
        break;
      case 'list':
        methodName = 'get$pluralPascal';
        returnType = 'Future<Either<Failure, List<${pascalClass}Entity>>>';
        break;
      case 'add':
        methodName = 'add$pascalClass';
        returnType = 'Future<Either<Failure, ${pascalClass}Entity>>';
        break;
      case 'update':
        methodName = 'update$pascalClass';
        returnType = 'Future<Either<Failure, ${pascalClass}Entity>>';
        break;
      case 'delete':
        methodName = 'delete$pascalClass';
        returnType = 'Future<Either<Failure, Map<String, dynamic>>>';
        break;
      default:
        continue;
    }

    final methodExists = RegExp(r'\b' + methodName + r'\s*\(').hasMatch(src);
    if (methodExists) {
      if (kDebugMode) {
        log('ℹ️ Method $methodName already exists');
      }
      continue;
    }

    final methodSig = '''
  $returnType $methodName(Map<String, dynamic> data);
''';

    final pascalFeatureClass = toPascal(feature);
    final classBlock = RegExp(
      r'abstract\s+class\s+' +
          pascalFeatureClass +
          r'Repository\s*\{([\s\S]*?)\}',
      multiLine: true,
    );
    final match = classBlock.firstMatch(src);
    if (match != null) {
      final insertPos = match.end - 1;
      src = src.substring(0, insertPos) + methodSig + src.substring(insertPos);
    } else {
      src = '${src.trimRight()}\n\n$methodSig';
      if (kDebugMode) {
        log('⚠️ Repository class not found; method appended at EOF');
      }
    }
    if (kDebugMode) {
      log('✅ Method $methodName appended to $repoPath');
    }
  }

  await file.writeAsString(src);
}

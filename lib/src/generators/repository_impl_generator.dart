// tool/generators/repository_impl_generator.dart
import 'dart:developer';
import 'dart:io';

import '../helpers/naming_helpers.dart';

const bool kDebugMode = true;

Future<void> generateRepositoryImpl({
  required String projectName,
  required String feature,
  required String className,
  List<String> crudMethods = const ['get', 'list', 'add', 'update', 'delete'],
}) async {
  final pascalFeature = toPascal(feature);
  final pascalClass = toPascal(className);
  final pluralPascal = pluralize(pascalClass);
  final snakeFeature = toSnakeFromName(feature);
  final snakeClass = toSnakeFromName(className);

  final repoPath =
      'lib/features/$feature/data/repositories/${snakeFeature}_repository_impl.dart';
  final entityImport =
      "import 'package:$projectName/features/$feature/domain/entities/${snakeClass}_entity.dart';";
  final repoInterfaceImport =
      "import 'package:$projectName/features/$feature/domain/repositories/${snakeFeature}_repository.dart';";
  final dataSourceImport =
      "import 'package:$projectName/features/$feature/data/data_sources/${snakeFeature}_remote_data.dart';";

  final classHeader = '''
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:$projectName/core/exceptions/failure.dart';
import 'package:$projectName/core/exceptions/server_exception.dart';
import 'package:$projectName/core/utils/repository_executor.dart';

$dataSourceImport
$entityImport
$repoInterfaceImport

class ${pascalFeature}RepositoryImpl implements ${pascalFeature}Repository {

 ${pascalFeature}RepositoryImpl({
  required this.remoteData,
  required RepositoryExecutor executor,
  }) : _executor = executor;
  
  final ${pascalFeature}RemoteData remoteData;
  final RepositoryExecutor _executor;

''';

  final file = File(repoPath);
  if (!file.existsSync()) {
    await file.create(recursive: true);
    await file.writeAsString('$classHeader\n}');
    if (kDebugMode) {
      log('🆕 RepositoryImpl created: $repoPath');
    }
  }

  var src = await file.readAsString();

  if (!src.contains(entityImport)) {
    src = '$entityImport\n$src';
  }
  if (!src.contains(repoInterfaceImport)) {
    src = '$repoInterfaceImport\n$src';
  }
  if (!src.contains(dataSourceImport)) {
    src = '$dataSourceImport\n$src';
  }

  // اضافه کردن متدهای CRUD
  for (final method in crudMethods) {
    String methodName;
    String returnType;
    String body;

    switch (method.toLowerCase()) {
      case 'get':
        methodName = 'get$pascalClass';
        returnType = 'Future<Either<Failure, ${pascalClass}Entity>>';
        body = '''
  return _executor.execute(() => remoteData.get$pascalClass(params));     
''';
        break;

      case 'list':
        methodName = 'get$pluralPascal';
        returnType = 'Future<Either<Failure, List<${pascalClass}Entity>>>';
        body = '''
  return _executor.execute(() => remoteData.get$pluralPascal(params));
''';
        break;

      case 'add':
        methodName = 'add$pascalClass';
        returnType = 'Future<Either<Failure, ${pascalClass}Entity>>';
        body = '''
  return _executor.execute(() => remoteData.add$pascalClass(params));
''';
        break;

      case 'update':
        methodName = 'update$pascalClass';
        returnType = 'Future<Either<Failure, ${pascalClass}Entity>>';
        body = '''
  return _executor.execute(() => remoteData.update$pascalClass(params));
''';
        break;

      case 'delete':
        methodName = 'delete$pascalClass';
        returnType = 'Future<Either<Failure, Map<String, dynamic>>>';
        body = '''
  return _executor.execute(() => remoteData.delete$pascalClass(params));
''';
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

    final methodSignature = '''
  @override
  $returnType $methodName(Map<String, dynamic> params) async {
  $body  
  }
''';

    final classEnd = src.lastIndexOf('}');
    if (classEnd != -1) {
      src = '${src.substring(0, classEnd)}\n$methodSignature\n}';
    } else {
      src = '${src.trimRight()}\n\n$methodSignature';
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

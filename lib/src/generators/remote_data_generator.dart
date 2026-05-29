// tool/generators/remotedata_generator.dart
import 'dart:developer';
import 'dart:io';

import '../helpers/naming_helpers.dart';

const bool kDebugMode = true;

Future<void> generateRemoteData({
  required String projectName,
  required String feature,
  required String className,
  List<String> crudMethods = const ['get', 'list', 'add', 'update', 'delete'],
}) async {
  final pascalClass = toPascal(className);
  final pluralPascal = pluralize(pascalClass);
  final pascalFeature = toPascal(feature);
  final snakeFeature = toSnakeFromName(feature);
  final snakeClass = toSnakeFromName(className);

  final dataSourcePath =
      'lib/features/$feature/data/data_sources/${snakeFeature}_remote_data.dart';
  final modelImport =
      "import 'package:$projectName/features/$feature/data/models/${snakeClass}_model.dart';";

  final abstractClass = '''
import 'package:get/get.dart';
import 'package:$projectName/core/data/network/api_provider.dart';
import 'package:$projectName/core/exceptions/server_exception.dart';
import 'package:$projectName/core/helpers/api_helper.dart';
$modelImport

abstract class ${pascalFeature}RemoteData {
''';

  final implClassHeader = '''
class ${pascalFeature}RemoteDataImp implements ${pascalFeature}RemoteData {

  ${pascalFeature}RemoteDataImp();

  final ApiProvider apiProvider = Get.find<ApiProvider>();
  final ApiHelper apiHelper = Get.find<ApiHelper>();

''';

  final file = File(dataSourcePath);
  if (!file.existsSync()) {
    await file.create(recursive: true);
    await file.writeAsString('$abstractClass\n}\n$implClassHeader\n}');
    if (kDebugMode) {
      log('🆕 RemoteData created: $dataSourcePath');
    }
  }

  // if (!file.existsSync()) {
  //   file.createSync(recursive: true);
  //   file.writeAsStringSync('$abstractClass\n$implClassHeader');
  //   if (kDebugMode) {
  //     log('🆕 RemoteData created: $dataSourcePath');
  //   }
  // }

  var src = await file.readAsString();

  if (!src.contains(modelImport)) {
    src = '$modelImport\n$src';
  }

  // اضافه کردن متدهای CRUD
  for (final method in crudMethods) {
    String methodName;
    String returnType;
    String body;

    switch (method.toLowerCase()) {
      case 'get':
        methodName = 'get$pascalClass';
        returnType = 'Future<${pascalClass}Model>';
        body = '''
    return apiHelper.handleRequest<${pascalClass}Model>(
      request: () => apiProvider.get('/$snakeFeature/$snakeClass/', data: params),
      onSuccess: (json) => ${pascalClass}Model.fromJson(json),
      debugLabel: '$methodName',
    );
''';
        break;

      case 'list':
        methodName = 'get$pluralPascal';
        returnType = 'Future<List<${pascalClass}Model>>';
        body = '''
    return apiHelper.handleRequest<List<${pascalClass}Model>>(
      request: () => apiProvider.get('/$snakeFeature/$snakeClass/', data: params),
      onSuccess: (json) => ${pascalClass}Model.fromJsonList(json as List),
      debugLabel: '$methodName',
    );
''';
        break;

      case 'add':
        methodName = 'add$pascalClass';
        returnType = 'Future<${pascalClass}Model>';
        body = '''
    return apiHelper.handleRequest<${pascalClass}Model>(
      request: () => apiProvider.post('/$snakeFeature/$snakeClass/', data: params),
      onSuccess: (json) => ${pascalClass}Model.fromJson(json),
      debugLabel: '$methodName',
    );
''';
        break;

      case 'update':
        methodName = 'update$pascalClass';
        returnType = 'Future<${pascalClass}Model>';
        body = '''
    return apiHelper.handleRequest<${pascalClass}Model>(
      request: () => apiProvider.put('/$snakeFeature/$snakeClass/', data: params),
      onSuccess: (json) => ${pascalClass}Model.fromJson(json),
      debugLabel: '$methodName',
    );
''';
        break;

      case 'delete':
        methodName = 'delete$pascalClass';
        returnType = 'Future<Map<String, dynamic>>';
        body = '''
    return apiHelper.handleRequest<Map<String, dynamic>>(
      request: () => apiProvider.delete('/$snakeFeature/$snakeClass/',),
      onSuccess: (json) => json,
      debugLabel: '$methodName',
    );
''';
        break;

      default:
        continue;
    }

    final methodExists = RegExp(r'\b' + methodName + r'\s*\(').hasMatch(src);
    if (methodExists) {
      if (kDebugMode) {
        log('ℹ️ Method $methodName already exists in $dataSourcePath');
      }
      continue;
    }

    // اضافه کردن به abstract class
    final abstractMatch = RegExp(
      r'abstract\s+class\s+' + pascalFeature + r'RemoteData\s*\{([\s\S]*?)\}',
      multiLine: true,
    ).firstMatch(src);
    if (abstractMatch != null) {
      final insertPos = abstractMatch.end - 1;
      src =
          '${src.substring(0, insertPos)}  $returnType $methodName(Map<String, dynamic> params);\n${src.substring(insertPos)}';
    }

    // اضافه کردن به impl class
    final implMatch = RegExp(
      r'class\s+' +
          pascalFeature +
          r'RemoteDataImp\s+implements\s+' +
          pascalFeature +
          r'RemoteData\s*\{([\s\S]*?)\}',
      multiLine: true,
    ).firstMatch(src);
    if (implMatch != null) {
      final classEnd = src.lastIndexOf('}');
      final methodCode = '''
  @override
  $returnType $methodName(Map<String, dynamic> params) {
$body  }
''';
      src = '${src.substring(0, classEnd)}\n$methodCode\n}';
    }

    if (kDebugMode) {
      log('✅ Method $methodName appended to $dataSourcePath');
    }
  }

  await file.writeAsString(src);
}

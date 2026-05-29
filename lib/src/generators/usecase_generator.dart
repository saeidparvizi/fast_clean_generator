// tool/generators/usecase_generator.dart
import '../helpers/naming_helpers.dart';

/// Generate multiple use cases based on CRUD methods
Future<Map<String, String>> generateUseCases({
  required String projectName,
  required String className,
  required String feature,
  required List<String> crudMethods,
}) async {
  final pascalClass = toPascal(className);
  final snakeClass = toSnakeFromName(className);
  final pascalFeature = toPascal(feature);
  final Map<String, String> useCaseFiles = {};

  for (final method in crudMethods) {
    final methodLower = method.toLowerCase();

    String classSuffix;
    String callLine;
    String fileName;
    String resultType = '';

    switch (methodLower) {
      case 'get':
        classSuffix = 'Get$pascalClass'
            'UseCase';
        callLine = 'repository.get$pascalClass(params)';
        fileName = 'get_${snakeClass}_usecase.dart';
        resultType = '${pascalClass}Entity';
        break;
      case 'list':
        final pluralPascal = pluralize(pascalClass);
        final pluralSnake = toSnakeFromName(pluralPascal);
        classSuffix = '${pluralPascal}UseCase';
        callLine = 'repository.get$pluralPascal(params)';
        fileName = '${pluralSnake}_usecase.dart';
        resultType = 'List<${pascalClass}Entity>';
        break;
      case 'add':
        classSuffix = 'Add$pascalClass'
            'UseCase';
        callLine = 'repository.add$pascalClass(params)';
        fileName = 'add_${snakeClass}_usecase.dart';
        resultType = '${pascalClass}Entity';
        break;
      case 'update':
        classSuffix = 'Update$pascalClass'
            'UseCase';
        callLine = 'repository.update$pascalClass(params)';
        fileName = 'update_${snakeClass}_usecase.dart';
        resultType = '${pascalClass}Entity';
        break;
      case 'delete':
        classSuffix = 'Delete$pascalClass'
            'UseCase';
        callLine = 'repository.delete$pascalClass(params)';
        fileName = 'delete_${snakeClass}_usecase.dart';
        resultType = 'Map<String, dynamic>';
        break;
      default:
        continue;
    }

    final content = '''
import 'package:dartz/dartz.dart';
import 'package:$projectName/core/exceptions/failure.dart';
import 'package:$projectName/core/use_case/base_use_case.dart';
import 'package:$projectName/features/$feature/domain/repositories/${toSnakeFromName(feature)}_repository.dart';
${methodLower != 'delete' ? "import '../entities/${snakeClass}_entity.dart';\n" : ''}
typedef Params = Map<String, dynamic>;
typedef Result = $resultType;

class $classSuffix implements BaseUseCase<Result, Params> {

  $classSuffix({required this.repository});
  
  final ${pascalFeature}Repository repository;

  @override
  Future<Either<Failure, Result>> call(Map<String, dynamic> params) {
    return $callLine;
  }
}
''';

    final filePath = 'lib/features/$feature/domain/usecases/$fileName';
    useCaseFiles[filePath] = content;
  }

  return useCaseFiles;
}

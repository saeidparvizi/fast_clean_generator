import 'package:test/test.dart';
import 'package:fast_clean_generator/src/generators/usecase_generator.dart';

void main() {
  group('UseCaseGenerator Tests', () {
    const projectName = 'test_project';
    const feature = 'booking';
    const className = 'Task';

    test('generateUseCases creates correct files for list and get', () async {
      final crudMethods = ['list', 'get'];
      final result = await generateUseCases(
        projectName: projectName,
        className: className,
        feature: feature,
        crudMethods: crudMethods,
      );

      expect(result.length, equals(2));

      final listPath =
          'lib/features/booking/domain/usecases/tasks_usecase.dart';
      final getPath =
          'lib/features/booking/domain/usecases/get_task_usecase.dart';

      expect(result.containsKey(listPath), isTrue);
      expect(result.containsKey(getPath), isTrue);

      final listContent = result[listPath]!;
      expect(
          listContent,
          contains(
              'class TasksUseCase implements BaseUseCase<Result, Params>'));
      expect(listContent, contains('typedef Result = List<TaskEntity>;'));
      expect(listContent, contains('return repository.getTasks(params);'));

      final getContent = result[getPath]!;
      expect(
          getContent,
          contains(
              'class GetTaskUseCase implements BaseUseCase<Result, Params>'));
      expect(getContent, contains('typedef Result = TaskEntity;'));
      expect(getContent, contains('return repository.getTask(params);'));
    });

    test('generateUseCases handles delete method correctly', () async {
      final crudMethods = ['delete'];
      final result = await generateUseCases(
        projectName: projectName,
        className: className,
        feature: feature,
        crudMethods: crudMethods,
      );

      final deletePath =
          'lib/features/booking/domain/usecases/delete_task_usecase.dart';
      expect(result.containsKey(deletePath), isTrue);

      final content = result[deletePath]!;
      expect(content, contains('class DeleteTaskUseCase'));
      expect(content, contains('typedef Result = Map<String, dynamic>;'));
      // Delete shouldn't import the entity usually
      expect(
          content, isNot(contains("import '../entities/task_entity.dart';")));
    });
  });
}

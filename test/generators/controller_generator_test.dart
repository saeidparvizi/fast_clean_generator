import 'package:test/test.dart';
import 'package:fast_clean_generator/src/generators/controller_generator.dart';

void main() {
  group('ControllerGenerator Tests', () {
    const projectName = 'test_project';
    const feature = 'booking';
    const className = 'Task';
    final jsonSchema = {'id': 1, 'title': 'Test'};

    group('generateListController', () {
      test('should generate a controller with list and delete methods', () {
        final crudMethods = ['list', 'delete'];
        final result = generateListController(
          className: className,
          feature: feature,
          projectName: projectName,
          crudMethods: crudMethods,
          jsonSchema: jsonSchema,
        );

        expect(
            result, contains('class TasksController extends GetxController'));
        expect(result, contains('final TasksUseCase tasksUseCase;'));
        expect(result, contains('final DeleteTaskUseCase deleteTaskUseCase;'));
        expect(result, contains('Future<void> getTasks() async'));
        expect(result, contains('Future<void> deleteTask(int id) async'));
        expect(
            result,
            contains(
                "import 'package:test_project/features/booking/domain/usecases/tasks_usecase.dart';"));
      });

      test('should include add method and Map conversion when add is enabled',
          () {
        final crudMethods = ['add'];
        final result = generateListController(
          className: className,
          feature: feature,
          projectName: projectName,
          crudMethods: crudMethods,
          jsonSchema: jsonSchema,
        );

        expect(result, contains('Future<void> addTask(TaskEntity task) async'));
        expect(result, contains("'id': task.id,"));
        expect(result, contains("'title': task.title,"));
      });
    });

    group('generateSingleController', () {
      test('should generate a single item controller with get and update', () {
        final crudMethods = ['get', 'update'];
        final result = generateSingleController(
          className: className,
          feature: feature,
          projectName: projectName,
          crudMethods: crudMethods,
          jsonSchema: jsonSchema,
        );

        expect(result, contains('class TaskController extends GetxController'));
        expect(result, contains('final GetTaskUseCase getTaskUseCase;'));
        expect(result, contains('final UpdateTaskUseCase updateTaskUseCase;'));
        expect(result, contains('Future<void> getTask(String id) async'));
        expect(result, contains('Future<void> updateTask() async'));
      });
    });
  });
}

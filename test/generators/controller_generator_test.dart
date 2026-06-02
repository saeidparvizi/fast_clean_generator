import 'package:test/test.dart';
import 'package:fast_clean_generator/src/generators/controller_generator.dart';
import 'dart:io';

void main() {
  group('ControllerGenerator Tests', () {
    const projectName = 'test_project';
    const feature = 'booking';
    const className = 'Task';
    const controllerPath = 'test_controller.dart';
    final jsonSchema = {'id': 1, 'title': 'Test'};

    tearDown(() {
      final file = File(controllerPath);
      if (file.existsSync()) file.deleteSync();
    });

    group('generateList', () {
      test('should generate a controller with list and delete methods', () async {
        final crudMethods = ['list', 'delete'];
        final result = await ControllerGenerator.generateList(
          className: className,
          feature: feature,
          projectName: projectName,
          crudMethods: crudMethods,
          jsonSchema: jsonSchema,
          controllerPath: controllerPath,
        );

        expect(result, contains('class TasksController extends GetxController'));
        expect(result, contains('final TasksUseCase tasksUseCase;'));
        expect(result, contains('Future<void> getTasks() async'));
        expect(result, contains("import 'package:test_project/features/booking/domain/usecases/tasks_usecase.dart';"));
      });
    });

    group('Incremental Updates', () {
      test('should merge new methods into existing controller', () async {
        // 1. Initial generation with 'list'
        final initialContent = await ControllerGenerator.generateList(
          className: className,
          feature: feature,
          projectName: projectName,
          crudMethods: ['list'],
          jsonSchema: jsonSchema,
          controllerPath: controllerPath,
        );
        File(controllerPath).writeAsStringSync(initialContent);

        // 2. Add 'add' method
        final updatedContent = await ControllerGenerator.generateList(
          className: className,
          feature: feature,
          projectName: projectName,
          crudMethods: ['add'],
          jsonSchema: jsonSchema,
          controllerPath: controllerPath,
        );

        expect(updatedContent, contains('Future<void> getTasks()'));
        expect(updatedContent, contains('Future<void> addTask'));
        expect(updatedContent, contains('final AddTaskUseCase addTaskUseCase;'));
      });
    });
  });
}

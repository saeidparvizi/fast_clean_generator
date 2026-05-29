import 'package:test/test.dart';
import 'package:clean_arch_generator/src/generators/page_generator.dart';

void main() {
  group('PageGenerator Tests', () {
    const projectName = 'test_project';
    const feature = 'booking';
    const className = 'Task';
    final jsonSchema = {'id': 1, 'title': 'Test'};

    test('generateListScreen creates a screen with FAB when add is enabled',
        () {
      final crudMethods = ['list', 'add'];
      final result = generateListScreen(
        className: className,
        feature: feature,
        projectName: projectName,
        crudMethods: crudMethods,
        jsonSchema: jsonSchema,
      );

      expect(result,
          contains('class TasksScreen extends GetView<TasksController>'));
      expect(result, contains('appBar: AppAppbar('));
      expect(result, contains('icon: const Icon(Icons.add)'));
      expect(result, contains('Get.toNamed(AppRoutes.taskAdd)'));
      expect(result, contains('ListView.builder('));
    });

    test(
        'generateListScreen includes delete dialog logic when delete is enabled',
        () {
      final crudMethods = ['list', 'delete'];
      final result = generateListScreen(
        className: className,
        feature: feature,
        projectName: projectName,
        crudMethods: crudMethods,
        jsonSchema: jsonSchema,
      );

      expect(result, contains('void _showDeleteDialog(BuildContext context'));
      expect(result, contains('controller.deleteTask(task.id!);'));
    });

    test('generateSingleScreen displays fields from jsonSchema', () {
      final crudMethods = ['get'];
      final result = generateSingleScreen(
        className: className,
        feature: feature,
        projectName: projectName,
        crudMethods: crudMethods,
        jsonSchema: jsonSchema,
      );

      expect(
          result, contains('class TaskScreen extends GetView<TaskController>'));
      expect(result, contains("'Id: \${taskData.id?.toString() ?? \"N/A\"}'"));
      expect(result,
          contains("'Title: \${taskData.title?.toString() ?? \"N/A\"}'"));
    });
  });
}

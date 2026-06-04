import 'package:test/test.dart';
import 'package:fast_clean_generator/src/generators/page_generator.dart';

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

      // Now it should call the external showDeleteTaskDialog function
      expect(result,
          contains('showDeleteTaskDialog(context, task.id, task.toString())'));
      // And it should NOT have the internal _showDeleteDialog method anymore
      expect(result,
          isNot(contains('void _showDeleteDialog(BuildContext context')));
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
      // Now it uses the _buildDetailRow helper method
      expect(
          result,
          contains(
              "_buildDetailRow('Id', taskData.id?.toString() ?? \"N/A\")"));
      expect(
          result,
          contains(
              "_buildDetailRow('Title', taskData.title?.toString() ?? \"N/A\")"));
    });
  });
}

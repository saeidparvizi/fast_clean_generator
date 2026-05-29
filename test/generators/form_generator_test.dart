import 'package:test/test.dart';
import 'package:clean_arch_generator/src/generators/form_generator.dart';

void main() {
  group('FormGenerator Tests', () {
    const projectName = 'test_project';
    const feature = 'booking';
    const className = 'Task';

    test('generateForm creates a StatefulWidget with correct controllers', () {
      final jsonSchema = {
        'id': 1,
        'title': 'Test Task',
        'is_completed': false,
        'due_date': '2023-12-31',
        'priority': 5,
      };

      final result = generateForm(
        className: className,
        feature: feature,
        projectName: projectName,
        jsonSchema: jsonSchema,
      );

      expect(result, contains('class TaskForm extends StatefulWidget'));
      expect(
          result,
          contains(
              'final TextEditingController _titleController = TextEditingController();'));
      expect(result, contains('bool _isCompletedValue = false;'));
      expect(
          result,
          contains(
              'final TextEditingController _priorityController = TextEditingController();'));
      expect(result, contains('DateTime? _dueDateValue;'));

      // ID should not have a controller as it's usually not editable
      expect(
          result, isNot(contains('final TextEditingController _idController')));
    });

    test(
        'generateForm submit logic includes ID from initial data and values from controllers',
        () {
      final jsonSchema = {
        'id': 1,
        'title': 'Test Task',
      };

      final result = generateForm(
        className: className,
        feature: feature,
        projectName: projectName,
        jsonSchema: jsonSchema,
      );

      // In the submit method, ID is taken from initialData
      expect(result, contains('id: widget.initialData?.id,'));
      expect(result, contains('title: _titleController.text,'));
    });

    test('generateForm includes DatePicker logic when date string is present',
        () {
      final jsonSchema = {
        'due_date': '2023-12-31',
      };

      final result = generateForm(
        className: className,
        feature: feature,
        projectName: projectName,
        jsonSchema: jsonSchema,
      );

      expect(
          result,
          contains(
              'Future<void> _selectDate(BuildContext context, String fieldName) async'));
      expect(result, contains('InkWell('));
    });
  });
}

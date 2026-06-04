import 'package:test/test.dart';
import 'package:fast_clean_generator/src/generators/form_generator.dart';

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

      // Due date should now be a regular TextEditingController since it's a DateTime type
      expect(
          result,
          contains(
              'final TextEditingController _dueDateController = TextEditingController();'));

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

    test('Smart Forms: should use SwitchListTile for boolean values', () {
      final jsonSchema = {
        'is_active': true,
      };

      final result = generateForm(
        className: className,
        feature: feature,
        projectName: projectName,
        jsonSchema: jsonSchema,
      );

      expect(result, contains('SwitchListTile('));
      expect(result, contains("title: Text('Is Active')"));
      expect(result, contains('value: _isActiveValue'));
    });

    test('Smart Forms: should use date picker for date-like strings', () {
      final jsonSchema = {
        'start_date': '2023-01-01',
      };

      final result = generateForm(
        className: className,
        feature: feature,
        projectName: projectName,
        jsonSchema: jsonSchema,
      );

      expect(result, contains('InkWell('));
      expect(result, contains("_selectDate(context, 'startDate')"));
      expect(result, contains('Icons.calendar_today'));
    });

    test('Smart Forms: should use numeric keyboard for numbers', () {
      final jsonSchema = {
        'amount': 100.5,
        'count': 10,
      };

      final result = generateForm(
        className: className,
        feature: feature,
        projectName: projectName,
        jsonSchema: jsonSchema,
      );

      expect(result, contains('keyboardType: TextInputType.number'));
      expect(
          result, contains("_validateNumberField(value, 'Amount', 'double')"));
      expect(result, contains("_validateNumberField(value, 'Count', 'int')"));
    });
  });
}

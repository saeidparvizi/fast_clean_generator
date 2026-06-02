import 'package:test/test.dart';
import 'package:fast_clean_generator/src/generators/model_generator.dart';

void main() {
  group('ModelGenerator Tests', () {
    const projectName = 'test_project';
    const feature = 'booking';

    test('generateModel creates a valid model class inheriting from Entity',
        () {
      final data = {
        'id': 1,
        'title': 'Test',
      };

      final result = generateModel(
        className: 'Task',
        feature: feature,
        projectName: projectName,
        data: data,
        fileBase: {},
      );

      expect(result, contains('class TaskModel extends TaskEntity'));
      expect(result, contains('const TaskModel({'));
      expect(result, contains('super.id,'));
      expect(result, contains('super.title,'));
      expect(
          result,
          contains(
              "import 'package:test_project/features/booking/domain/entities/task_entity.dart';"));
    });

    test('generateModel creates fromJson and toJson methods', () {
      final data = {
        'id': 1,
        'title': 'Test',
      };

      final result = generateModel(
        className: 'Task',
        feature: feature,
        projectName: projectName,
        data: data,
        fileBase: {},
      );

      expect(result,
          contains('factory TaskModel.fromJson(Map<String, dynamic> json)'));
      expect(result, contains("id: json['id'],"));
      expect(result, contains("title: json['title'],"));
      expect(result, contains('Map<String, dynamic> toJson()'));
      expect(result, contains("'id': id,"));
      expect(result, contains("'title': title,"));
    });

    test('generateModel handles nested models correctly', () {
      final data = {
        'id': 1,
        'owner': {'name': 'Saeid'},
        'tags': [
          {'id': 1, 'name': 'dart'}
        ]
      };

      // Realistically, collectClasses would produce these keys using toPascal(key)
      final fileBase = {
        'Owner': 'owner_profile',
        'Tags': 'task_tag',
      };

      final result = generateModel(
        className: 'Task',
        feature: feature,
        projectName: projectName,
        data: data,
        fileBase: fileBase,
      );

      // Check imports
      expect(
          result,
          contains(
              "import 'package:test_project/features/booking/data/models/owner_profile_model.dart';"));
      expect(
          result,
          contains(
              "import 'package:test_project/features/booking/data/models/task_tag_model.dart';"));

      // Check fromJson for Map
      expect(
          result,
          contains(
              "owner: json['owner'] != null ? OwnerModel.fromJson(json['owner']) : null,"));

      // Check fromJson for List of Maps
      expect(
          result,
          contains(
              "tags: (json['tags'] as List?)?.map((e) => TagsModel.fromJson(e)).toList(),"));
    });

    test('generateModel recursive toJson for nested objects', () {
      final data = {
        'id': 1,
        'author': {'name': 'Saeid'},
        'comments': [
          {'id': 1, 'text': 'nice'}
        ]
      };

      final result = generateModel(
        className: 'Post',
        feature: feature,
        projectName: projectName,
        data: data,
        fileBase: {},
      );

      // Verify toJson calls for children
      expect(result, contains("'author': author?.toJson(),"));
      expect(result,
          contains("'comments': comments?.map((e) => e.toJson()).toList(),"));
    });

    test('generateModel handles fields correctly', () {
      final data = {
        'id': 1,
        'created_at': '2023-12-31',
      };

      final result = generateModel(
        className: 'Task',
        feature: feature,
        projectName: projectName,
        data: data,
        fileBase: {},
      );

      expect(result, contains("createdAt: json['created_at'],"));
      expect(result, contains("'created_at': createdAt,"));
    });
  });
}

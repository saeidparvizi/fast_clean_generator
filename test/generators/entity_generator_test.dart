import 'package:test/test.dart';
import 'package:clean_arch_generator/src/generators/entity_generator.dart';

void main() {
  group('EntityGenerator Tests', () {
    test('generateEntity creates a valid entity class with basic fields', () {
      final data = {
        'id': 1,
        'title': 'Test Task',
        'is_completed': false,
      };

      final result = generateEntity('Task', data, {});

      expect(result, contains('class TaskEntity extends Equatable'));
      expect(result, contains('final int? id;'));
      expect(result, contains('final String? title;'));
      expect(result, contains('final bool? isCompleted;'));
      expect(result, contains('required this.id,'));
      expect(result, contains('required this.title,'));
      expect(result, contains('required this.isCompleted,'));
      expect(result, contains('props => [id, title, isCompleted]'));
      expect(result, contains("import 'package:equatable/equatable.dart';"));
    });

    test('generateEntity handles nested objects and adds imports', () {
      final data = {
        'id': 1,
        'user_profile': {
          'name': 'Saeid',
          'bio': 'Developer',
        },
      };

      // Simulating the fileBase map that would be created by collectClasses
      final fileBase = {'UserProfile': 'user_profile'};

      final result = generateEntity('User', data, fileBase);

      expect(result, contains("import 'user_profile_entity.dart';"));
      expect(result, contains('final UserProfileEntity? userProfile;'));
      expect(result, contains('required this.userProfile,'));
    });

    test('generateEntity handles empty data', () {
      final result = generateEntity('Empty', {}, {});
      expect(result, contains('class EmptyEntity extends Equatable'));
      expect(result, contains('const EmptyEntity();'));
      expect(result, contains('props => [];'));
    });
  });
}

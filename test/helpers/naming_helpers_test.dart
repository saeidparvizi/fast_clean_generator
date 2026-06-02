import 'package:test/test.dart';
import 'package:fast_clean_generator/src/helpers/naming_helpers.dart';

void main() {
  group('NamingHelpers Tests', () {
    test('toPascal converts snake_case and kebab-case to PascalCase', () {
      expect(toPascal('hello_world'), equals('HelloWorld'));
      expect(toPascal('hello-world'), equals('HelloWorld'));
      expect(toPascal('user'), equals('User'));
    });

    test('toCamel converts strings to camelCase', () {
      expect(toCamel('HelloWorld'), equals('helloWorld'));
      expect(toCamel('user_profile'), equals('userProfile'));
      expect(toCamel('APIClient'), equals('aPIClient'));
    });

    test('toSnakeFromName converts PascalCase/camelCase to snake_case', () {
      expect(toSnakeFromName('UserProfile'), equals('user_profile'));
      expect(toSnakeFromName('userProfile'), equals('user_profile'));
      expect(toSnakeFromName('XMLHttpClient'), equals('xml_http_client'));
    });

    test('pluralize handles basic pluralization rules', () {
      expect(pluralize('Category'), equals('Categories'));
      expect(pluralize('User'), equals('Users'));
      expect(pluralize('Box'), equals('Boxes'));
      expect(pluralize('Wish'), equals('Wishes'));
    });

    test('toTitleCase converts various formats to Title Case', () {
      expect(toTitleCase('user_profile'), equals('User Profile'));
      expect(toTitleCase('user-profile'), equals('User Profile'));
      expect(toTitleCase('userProfile'), equals('User Profile'));
    });

    test('dartTypeForEntity identifies correct Dart types', () {
      expect(dartTypeForEntity(1, 'id'), equals('int'));
      expect(dartTypeForEntity(1.5, 'price'), equals('double'));
      expect(dartTypeForEntity(true, 'isActive'), equals('bool'));
      expect(dartTypeForEntity('2023-12-31', 'createdAt'), equals('String'));
      expect(dartTypeForEntity({'key': 'value'}, 'data'), equals('DataEntity'));
      expect(
          dartTypeForEntity([
            {'key': 'value'}
          ], 'list'),
          equals('List<ListEntity>'));
      expect(dartTypeForEntity('text', 'name'), equals('String'));
    });

    test('identifyIdField finds the correct ID field based on priority', () {
      // Priority 1: id
      expect(identifyIdField({'id': 1, 'uuid': 'abc'}), equals('id'));

      // Priority 2: uuid (when id is missing)
      expect(identifyIdField({'uuid': 'abc', '_id': 123}), equals('uuid'));

      // Priority 3: _id
      expect(identifyIdField({'_id': 123, 'identifier': 'id1'}), equals('_id'));

      // Priority 4: identifier
      expect(identifyIdField({'identifier': 'id1', 'uid': 'u1'}),
          equals('identifier'));

      // Priority 5: uid
      expect(identifyIdField({'uid': 'u1', 'name': 'test'}), equals('uid'));

      // Default case
      expect(identifyIdField({'name': 'test', 'title': 'hello'}), equals('id'));
    });
  });
}

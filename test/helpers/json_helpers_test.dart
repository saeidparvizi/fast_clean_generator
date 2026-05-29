import 'package:test/test.dart';
import 'package:clean_arch_generator/src/helpers/json_helpers.dart';
import 'package:clean_arch_generator/src/exceptions/generator_exception.dart';

void main() {
  group('JsonHelpers Tests', () {
    test('loadJson should parse valid JSON string', () async {
      final jsonStr = '{"id": 1, "name": "Test"}';
      final result = await loadJson(jsonStr);
      expect(result['id'], equals(1));
      expect(result['name'], equals('Test'));
    });

    test('loadJson should throw JsonSchemaException for invalid JSON string',
        () {
      final jsonStr = '{"id": 1, "name": "Test"'; // missing brace
      expect(() => loadJson(jsonStr), throwsA(isA<JsonSchemaException>()));
    });

    test('collectClasses should extract nested structures', () {
      final schema = {
        'id': 1,
        'profile': {
          'bio': 'hello',
          'address': {'city': 'Tehran'}
        },
        'tags': [
          {'id': 101, 'label': 'dart'}
        ]
      };

      final out = <String, Map<String, dynamic>>{};
      final fileBase = <String, String>{};

      collectClasses('User', schema, out, fileBase,
          jsonKeyForThisClass: 'user');

      expect(out.containsKey('User'), isTrue);
      expect(out.containsKey('Profile'), isTrue);
      expect(out.containsKey('Address'), isTrue);
      expect(out.containsKey('Tags'), isTrue);

      expect(fileBase['User'], equals('user'));
      expect(fileBase['Profile'], equals('profile'));
    });
  });
}

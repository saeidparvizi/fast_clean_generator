import 'dart:convert';
import 'dart:io';

import '../exceptions/generator_exception.dart';
import 'naming_helpers.dart';

Future<Map<String, dynamic>> loadJson(String arg) async {
  final t = arg.trim();
  try {
    if (t.startsWith('{') || t.startsWith('[')) {
      final decoded = json.decode(t);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      throw JsonSchemaException('Root JSON must be an object.');
    }
    
    final f = File(arg);
    if (!f.existsSync()) {
      throw JsonSchemaException('JSON file not found: $arg');
    }
    
    final text = await f.readAsString();
    final decoded = json.decode(text);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw JsonSchemaException('Root JSON in file must be an object.');
  } on FormatException catch (e) {
    throw JsonSchemaException('Invalid JSON format.', e.message);
  } catch (e) {
    if (e is JsonSchemaException) rethrow;
    throw JsonSchemaException('Failed to load JSON.', e.toString());
  }
}

void collectClasses(
  String className,
  Map<String, dynamic> map,
  Map<String, Map<String, dynamic>> out,
  Map<String, String> fileBase, {
  required String jsonKeyForThisClass,
}) {
  if (!out.containsKey(className)) {
    out[className] = map;
    fileBase[className] = toSnakeFromName(className);
  }

  map.forEach((key, value) {
    if (value is Map) {
      collectClasses(
        toPascal(key),
        Map<String, dynamic>.from(value),
        out,
        fileBase,
        jsonKeyForThisClass: key,
      );
    } else if (value is List && value.isNotEmpty && value.first is Map) {
      collectClasses(
        toPascal(key),
        Map<String, dynamic>.from(value.first),
        out,
        fileBase,
        jsonKeyForThisClass: key,
      );
    }
  });
}

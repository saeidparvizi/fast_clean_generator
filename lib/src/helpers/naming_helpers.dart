// tool/helpers/naming_helpers.dart
String dartTypeForEntity(dynamic value, String key) {
  if (value is int) {
    return 'int';
  }
  if (value is double) {
    return 'double';
  }
  if (value is bool) {
    return 'bool';
  }
  if (value is Map) {
    return '${toPascal(key)}Entity';
  }
  if (value is List) {
    if (value.isNotEmpty && value.first is Map) {
      return 'List<${toPascal(key)}Entity>';
    }
    return 'List<dynamic>';
  }
  return 'String';
}

String toCamel(String s) {
  final pascal = toPascal(s);
  if (pascal.isEmpty) {
    return pascal;
  }
  return pascal[0].toLowerCase() + pascal.substring(1);
}

String toPascal(String s) {
  final t = s.replaceAll('-', '_');
  if (t.isEmpty) {
    return t;
  }
  return t
      .split('_')
      .map((p) => p.isEmpty ? '' : p[0].toUpperCase() + p.substring(1))
      .join();
}

String toSnakeFromKey(String key) => key.replaceAll('-', '_').toLowerCase();

String toSnakeFromName(String name) {
  if (name.isEmpty) {
    return name;
  }
  // 1) Insert underscore between lower->Upper (e.g. "carAvailability" -> "car_Availability")
  var s = name.replaceAllMapped(
    RegExp(r'([a-z0-9])([A-Z])'),
    (m) => '${m[1]}_${m[2]}',
  );

  // 2) Insert underscore between contiguous uppercase groups followed by lowercase
  //    (e.g. "XMLHttp" -> "XML_Http")
  s = s.replaceAllMapped(
    RegExp(r'([A-Z]+)([A-Z][a-z])'),
    (m) => '${m[1]}_${m[2]}',
  );

  // 3) replace hyphens and multiple underscores, then lowercase
  s = s.replaceAll('-', '_');
  s = s.replaceAll(RegExp(r'_+'), '_');

  return s.toLowerCase();
}

String pluralize(String word) {
  if (word.isEmpty) {
    return word;
  }

  final lower = word.toLowerCase();

  // If it ends with 'y' preceded by a consonant -> ies
  if (lower.endsWith('y') &&
      lower.length > 1 &&
      !'aeiou'.contains(lower[lower.length - 2])) {
    return '${word.substring(0, word.length - 1)}ies';
  }

  // If it ends with s, x, z, ch, or sh -> es
  if (lower.endsWith('s') ||
      lower.endsWith('x') ||
      lower.endsWith('z') ||
      lower.endsWith('ch') ||
      lower.endsWith('sh')) {
    return '${word}es';
  }

  // Default -> s
  return '${word}s';
}

// tool/helpers/naming_helpers.dart

// Add this function
String toTitleCase(String text) {
  if (text.isEmpty) {
    return text;
  }

  // Handle snake_case, camelCase, and kebab-case
  final words = text
      .replaceAll('_', ' ')
      .replaceAll('-', ' ')
      .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}')
      .toLowerCase()
      .split(' ')
      .where((word) => word.isNotEmpty);

  return words.map((word) {
    if (word.length > 1) {
      return word[0].toUpperCase() + word.substring(1);
    }
    return word.toUpperCase();
  }).join(' ');
}

// Identifies the ID field from the JSON schema
String identifyIdField(Map<String, dynamic> jsonSchema) {
  // Priority list for ID fields
  final priorityFields = ['id', 'uuid', '_id', 'identifier', 'uid'];

  for (final field in priorityFields) {
    if (jsonSchema.containsKey(field)) {
      return field;
    }
  }

  return 'id';
}

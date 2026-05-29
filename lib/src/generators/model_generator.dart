// tool/generators/model_generator.dart
import '../helpers/naming_helpers.dart';

String generateModel({
  required String className,
  required String feature,
  required String projectName,
  required Map<String, dynamic> data,
  required Map<String, String> fileBase,
}) {
  final baseThis = fileBase[className] ?? toSnakeFromName(className);
  final entityImport =
      'package:$projectName/features/$feature/domain/entities/${baseThis}_entity.dart';

  final b = StringBuffer()..writeln("import '$entityImport';");

  final imports = <String>{};
  data.forEach((key, value) {
    if (value is Map ||
        (value is List && value.isNotEmpty && value.first is Map)) {
      final nested = toPascal(key);
      final base = fileBase[nested] ?? toSnakeFromKey(key);

      final nestedModelImport =
          'package:$projectName/features/$feature/data/models/${base}_model.dart';
      imports.add("import '$nestedModelImport';");

      // imports.add("import '${base}_model.dart';");
    }
  });
  for (final i in imports) {
    b.writeln(i);
  }

  b.writeln('\nclass ${className}Model extends ${className}Entity {');

  if (data.isNotEmpty) {
    b.writeln('  const ${className}Model({');
    for (var k in data.keys) {
      b.writeln('    super.${toCamel(k)},');
    }
    b.writeln('  });\n');
  } else {
    b.writeln('  const ${className}Model();\n');
  }

  b.writeln(
    '  factory ${className}Model.fromJson(Map<String, dynamic> json) {',
  );
  if (data.isNotEmpty) {
    b.writeln('    return ${className}Model(');
    data.forEach((key, value) {
      final camel = toCamel(key);
      if (value is Map) {
        final nested = toPascal(key);
        b.writeln(
          "      $camel: json['$key'] != null ? ${nested}Model.fromJson(json['$key']) : null,",
        );
      } else if (value is List && value.isNotEmpty && value.first is Map) {
        final nested = toPascal(key);
        b.writeln(
          "      $camel: (json['$key'] as List?)?.map((e) => ${nested}Model.fromJson(e)).toList(),",
        );
      } else {
        b.writeln("      $camel: json['$key'],");
      }
    });
    b.writeln('    );');
  } else {
    b.writeln('    return ${className}Model();');
  }
  b.writeln('  }\n');

  b.writeln('  Map<String, dynamic> toJson() {');
  b.writeln('    return {');
  data.forEach((key, _) {
    final camel = toCamel(key);
    b.writeln("      '$key': $camel,");
  });
  b.writeln('    };');
  b.writeln('  }\n');

  b.writeln('  static List<${className}Model> fromJsonList(List list) {');
  b.writeln(
    '    return list.map((item) => ${className}Model.fromJson(item)).toList();',
  );
  b.writeln('  }');

  b.writeln('}');
  return b.toString();
}

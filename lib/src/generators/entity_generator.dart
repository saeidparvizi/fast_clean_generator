// tool/generators/entity_generator.dart
import '../helpers/naming_helpers.dart';

String generateEntity(
  String className,
  Map<String, dynamic> data,
  Map<String, String> fileBase,
) {
  final b = StringBuffer()
    ..writeln("import 'package:equatable/equatable.dart';");

  final imports = <String>{};
  data.forEach((key, value) {
    if (value is Map ||
        (value is List && value.isNotEmpty && value.first is Map)) {
      final nested = toPascal(key);
      final base = fileBase[nested] ?? toSnakeFromKey(key);
      imports.add("import '${base}_entity.dart';");
    }
  });
  for (final i in imports) {
    b.writeln(i);
  }

  b.writeln('\nclass ${className}Entity extends Equatable {');

  if (data.isNotEmpty) {
    b.writeln('  const ${className}Entity({');
    for (var k in data.keys) {
      b.writeln('    required this.${toCamel(k)},');
    }
    b.writeln('  });\n');
    data.forEach((key, value) {
      final type = dartTypeForEntity(value, key);
      b.writeln('  final $type? ${toCamel(key)};');
    });
  } else {
    b.writeln('  const ${className}Entity();\n');
  }

  b.writeln('\n  @override');
  b.writeln(
    '  List<Object?> get props => [${data.keys.map(toCamel).join(', ')}];',
  );
  b.writeln('}');
  return b.toString();
}

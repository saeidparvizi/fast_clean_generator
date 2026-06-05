// tool/generators/form_generator.dart
import '../helpers/naming_helpers.dart';

String generateForm({
  required String className,
  required String feature,
  required String projectName,
  required Map<String, dynamic> jsonSchema,
}) {
  final pascalModel = toPascal(className);
  final snakeModel = toSnakeFromName(className);

  // شناسایی فیلدهای ID که باید ignore شوند
  final idFields = _identifyIdFields(jsonSchema);
  // فیلدهای قابل ویرایش (غیر از ID)
  final editableFields = _getEditableFields(jsonSchema, idFields);

  final buffer = StringBuffer();

  // Imports
  buffer.writeln("import 'package:flutter/material.dart';");
  buffer.writeln("import 'package:$projectName/core/widgets/input.dart';");
  buffer.writeln(
    "import 'package:$projectName/features/$feature/domain/entities/${snakeModel}_entity.dart';",
  );
  buffer.writeln();

  // Class definition
  buffer.writeln('class ${pascalModel}Form extends StatefulWidget {');

  buffer.writeln('  const ${pascalModel}Form({');
  buffer.writeln('    required this.onSubmit,');
  buffer.writeln('    this.initialData,');
  buffer.writeln('    super.key,');
  buffer.writeln('  });');
  buffer.writeln();

  buffer.writeln('  final ${pascalModel}Entity? initialData;');
  buffer.writeln('  final Function(${pascalModel}Entity) onSubmit;');
  buffer.writeln();

  buffer.writeln('  @override');
  buffer.writeln(
    '  State<${pascalModel}Form> createState() => _${pascalModel}FormState();',
  );
  buffer.writeln('}');
  buffer.writeln();

  // State class
  buffer.writeln(
    'class _${pascalModel}FormState extends State<${pascalModel}Form> {',
  );
  buffer.writeln('  final _formKey = GlobalKey<FormState>();');

  // Create controllers for each editable field
  editableFields.forEach((key, value) {
    final camelKey = toCamel(key);
    final type = _getFieldType(value);

    if (type == 'bool') {
      buffer.writeln('  bool _${camelKey}Value = false;');
    } else if (type == 'DateTime') {
      buffer.writeln('  String? _${camelKey}Value;');
      buffer.writeln(
        '  final TextEditingController _${camelKey}Controller = TextEditingController();',
      );
    } else if (_isNestedField(value)) {
      // برای فیلدهای nested، کنترلر خاص
      buffer.writeln(
        '  final TextEditingController _${camelKey}Controller = TextEditingController();',
      );
    } else {
      buffer.writeln(
        '  final TextEditingController _${camelKey}Controller = TextEditingController();',
      );
    }
  });

  buffer.writeln();
  buffer.writeln('  @override');
  buffer.writeln('  void initState() {');
  buffer.writeln('    super.initState();');
  buffer.writeln('    _initializeForm();');
  buffer.writeln('  }');
  buffer.writeln();
  buffer.writeln('  void _initializeForm() {');
  buffer.writeln('    if (widget.initialData != null) {');

  editableFields.forEach((key, value) {
    final camelKey = toCamel(key);
    final type = _getFieldType(value);

    if (type == 'bool') {
      buffer.writeln(
        '      _${camelKey}Value = widget.initialData!.$camelKey ?? false;',
      );
    } else if (type == 'DateTime') {
      buffer.writeln(
        '      _${camelKey}Value = widget.initialData!.$camelKey;',
      );
      buffer.writeln('      if (_${camelKey}Value != null) {');
      buffer.writeln(
        '        _${camelKey}Controller.text = _${camelKey}Value!;',
      );
      buffer.writeln('      }');
    } else if (_isNestedField(value)) {
      // برای nested fields، مقدار را به string تبدیل کنیم
      buffer.writeln('      if (widget.initialData!.$camelKey != null) {');
      buffer.writeln(
        '        _${camelKey}Controller.text = widget.initialData!.$camelKey.toString();',
      );
      buffer.writeln('      }');
    } else {
      buffer.writeln('      if (widget.initialData!.$camelKey != null) {');
      buffer.writeln(
        '        _${camelKey}Controller.text = widget.initialData!.$camelKey.toString();',
      );
      buffer.writeln('      }');
    }
  });

  buffer.writeln('    }');
  buffer.writeln('  }');
  buffer.writeln();
  buffer.writeln('  @override');
  buffer.writeln('  void dispose() {');

  editableFields.forEach((key, value) {
    final camelKey = toCamel(key);
    final type = _getFieldType(value);

    if (type != 'bool' && type != 'DateTime') {
      buffer.writeln('    _${camelKey}Controller.dispose();');
    }
  });

  buffer.writeln('    super.dispose();');
  buffer.writeln('  }');
  buffer.writeln();
  buffer.writeln('  @override');
  buffer.writeln('  Widget build(BuildContext context) {');
  buffer.writeln('    return Form(');
  buffer.writeln('      key: _formKey,');
  buffer.writeln('      child: SingleChildScrollView(');
  buffer.writeln('        child: Column(');
  buffer.writeln('          mainAxisSize: MainAxisSize.min,');
  buffer.writeln('          children: [');

  // Generate form fields برای فیلدهای قابل ویرایش
  editableFields.forEach((key, value) {
    final camelKey = toCamel(key);
    final label = _toTitleCase(key);
    final type = _getFieldType(value);
    final isNested = _isNestedField(value);

    if (type == 'bool') {
      // Switch برای boolean (smart feel)
      buffer.writeln('            SwitchListTile(');
      buffer.writeln('              title: Text(\'$label\'),');
      buffer.writeln('              value: _${camelKey}Value,');
      buffer.writeln('              onChanged: (value) {');
      buffer.writeln('                setState(() {');
      buffer.writeln('                  _${camelKey}Value = value;');
      buffer.writeln('                });');
      buffer.writeln('              },');
      buffer.writeln('            ),');
    } else if (type == 'DateTime') {
      // Date picker برای تاریخ
      buffer.writeln('            InkWell(');
      buffer.writeln(
        '              onTap: () => _selectDate(context, \'$camelKey\'),',
      );
      buffer.writeln('              child: InputDecorator(');
      buffer.writeln('                decoration: InputDecoration(');
      buffer.writeln('                  labelText: \'$label\',');
      buffer.writeln('                  border: const OutlineInputBorder(),');
      buffer.writeln(
        '                  suffixIcon: const Icon(Icons.calendar_today),',
      );
      buffer.writeln('                ),');
      buffer.writeln('                child: Text(');
      buffer.writeln('                  _${camelKey}Controller.text.isEmpty');
      buffer.writeln('                      ? \'Select Date\'');
      buffer.writeln('                      : _${camelKey}Controller.text,');
      buffer.writeln('                ),');
      buffer.writeln('              ),');
      buffer.writeln('            ),');
    } else if (type == 'int' || type == 'double') {
      // Number input برای اعداد
      buffer.writeln('            AppInput(');
      buffer.writeln('              controller: _${camelKey}Controller,');
      buffer.writeln('              labelText: \'$label\',');
      buffer.writeln('              keyboardType: TextInputType.number,');
      buffer.writeln(
        '              validator: (value) => _validateNumberField(value, \'$label\', \'$type\'),',
      );
      buffer.writeln('            ),');
    } else if (isNested) {
      // برای nested fields (مثل object یا array)
      buffer.writeln('            AppInput(');
      buffer.writeln('              controller: _${camelKey}Controller,');
      buffer.writeln('              labelText: \'$label\',');
      buffer.writeln('              hintText: \'Enter JSON for $label\',');
      buffer.writeln('              maxLines: 3,');
      buffer.writeln('              validator: (value) {');
      buffer.writeln('                if (value == null || value.isEmpty) {');
      buffer.writeln('                  return \'Please enter $label\';');
      buffer.writeln('                }');
      buffer.writeln('                return null;');
      buffer.writeln('              },');
      buffer.writeln('            ),');
    } else {
      // Text input معمولی برای string
      buffer.writeln('            AppInput(');
      buffer.writeln('              controller: _${camelKey}Controller,');
      buffer.writeln('              labelText: \'$label\',');
      buffer.writeln('              keyboardType: TextInputType.text,');
      buffer.writeln('              validator: (value) {');
      buffer.writeln('                if (value == null || value.isEmpty) {');
      buffer.writeln('                  return \'Please enter $label\';');
      buffer.writeln('                }');
      buffer.writeln('                return null;');
      buffer.writeln('              },');
      buffer.writeln('            ),');
    }

    buffer.writeln('            const SizedBox(height: 16),');
  });

  buffer.writeln('            ElevatedButton(');
  buffer.writeln('              onPressed: _submitForm,');
  buffer.writeln('              child: const Text(\'Submit\'),');
  buffer.writeln('            ),');
  buffer.writeln('            const SizedBox(height: 16),');
  buffer.writeln('          ],');
  buffer.writeln('        ),');
  buffer.writeln('      ),');
  buffer.writeln('    );');
  buffer.writeln('  }');
  buffer.writeln();

  // Submit method
  buffer.writeln('  void _submitForm() {');
  buffer.writeln('    if (_formKey.currentState!.validate()) {');
  buffer.writeln('      ');
  buffer.writeln('      final $snakeModel = ${pascalModel}Entity(');

  // ابتدا فیلدهای ID را اضافه کنیم
  for (var idField in idFields) {
    final camelIdField = toCamel(idField);
    buffer.writeln('        $camelIdField: widget.initialData?.$idField,');
  }

  // سپس فیلدهای قابل ویرایش
  editableFields.forEach((key, value) {
    final camelKey = toCamel(key);
    final type = _getFieldType(value);

    if (type == 'bool') {
      buffer.writeln('        $camelKey: _${camelKey}Value,');
    } else if (type == 'DateTime') {
      buffer.writeln('        $camelKey: _${camelKey}Value,');
    } else if (type == 'int') {
      buffer.writeln(
        '        $camelKey: int.tryParse(_${camelKey}Controller.text),',
      );
    } else if (type == 'double') {
      buffer.writeln(
        '        $camelKey: double.tryParse(_${camelKey}Controller.text),',
      );
    } else if (_isNestedField(value)) {
      // برای nested fields، نیاز به پردازش خاص داریم
      buffer.writeln(
        '        $camelKey: _parseNestedField(_${camelKey}Controller.text, \'$key\'),',
      );
    } else {
      buffer.writeln('        $camelKey: _${camelKey}Controller.text,');
    }
  });

  buffer.writeln('      );');
  buffer.writeln('      ');
  buffer.writeln('      widget.onSubmit($snakeModel);');
  buffer.writeln('    }');
  buffer.writeln('  }');
  buffer.writeln();

  // Date picker method
  if (_hasDateTimeField(editableFields)) {
    buffer.writeln(
      '  Future<void> _selectDate(BuildContext context, String fieldName) async {',
    );
    buffer.writeln('    final DateTime? picked = await showDatePicker(');
    buffer.writeln('      context: context,');
    buffer.writeln('      initialDate: _getInitialDate(fieldName),');
    buffer.writeln('      firstDate: DateTime(2000),');
    buffer.writeln('      lastDate: DateTime(2100),');
    buffer.writeln('    );');
    buffer.writeln('    ');
    buffer.writeln('    if (picked != null) {');
    buffer.writeln('      setState(() {');
    buffer.writeln('        switch (fieldName) {');

    editableFields.forEach((key, value) {
      final camelKey = toCamel(key);
      final type = _getFieldType(value);

      if (type == 'DateTime') {
        buffer.writeln('          case \'$camelKey\':');
        buffer.writeln(
            '            _${camelKey}Value = picked.toIso8601String().split(\'T\')[0];');
        buffer.writeln(
          '            _${camelKey}Controller.text = _${camelKey}Value!;',
        );
        buffer.writeln('            break;');
      }
    });

    buffer.writeln('        }');
    buffer.writeln('      });');
    buffer.writeln('    }');
    buffer.writeln('  }');
    buffer.writeln();

    buffer.writeln('  DateTime _getInitialDate(String fieldName) {');
    buffer.writeln('    switch (fieldName) {');

    editableFields.forEach((key, value) {
      final camelKey = toCamel(key);
      final type = _getFieldType(value);

      if (type == 'DateTime') {
        buffer.writeln('      case \'$camelKey\':');
        buffer.writeln(
            '        return _${camelKey}Value != null ? DateTime.tryParse(_${camelKey}Value!) ?? DateTime.now() : DateTime.now();');
      }
    });

    buffer.writeln('      default:');
    buffer.writeln('        return DateTime.now();');
    buffer.writeln('    }');
    buffer.writeln('  }');
    buffer.writeln();
  }

  // Validation methods
  buffer.writeln(
    '  String? _validateNumberField(String? value, String fieldName, String type) {',
  );
  buffer.writeln('    if (value == null || value.isEmpty) {');
  buffer.writeln('      return \'Please enter \$fieldName\';');
  buffer.writeln('    }');
  buffer.writeln('    ');
  buffer.writeln('    if (type == \'int\' && int.tryParse(value) == null) {');
  buffer.writeln(
    '      return \'Please enter a valid integer for \$fieldName\';',
  );
  buffer.writeln('    }');
  buffer.writeln('    ');
  buffer.writeln(
    '    if (type == \'double\' && double.tryParse(value) == null) {',
  );
  buffer.writeln(
    '      return \'Please enter a valid number for \$fieldName\';',
  );
  buffer.writeln('    }');
  buffer.writeln('    ');
  buffer.writeln('    return null;');
  buffer.writeln('  }');
  buffer.writeln();

  // Helper برای parse nested fields
  if (_hasNestedField(editableFields)) {
    buffer.writeln(
      '  dynamic _parseNestedField(String value, String fieldName) {',
    );
    buffer.writeln('    try {');
    buffer.writeln('      // Try to parse as JSON');
    buffer.writeln('      return value; // For now, return as string');
    buffer.writeln(
      '      // TODO: Implement proper JSON parsing based on your needs',
    );
    buffer.writeln('    } catch (e) {');
    buffer.writeln('      return value; // Fallback to string');
    buffer.writeln('    }');
    buffer.writeln('  }');
    buffer.writeln();
  }

  buffer.writeln('}');

  return buffer.toString();
}

// شناسایی فیلدهای ID
Set<String> _identifyIdFields(Map<String, dynamic> jsonSchema) {
  final idFields = <String>{};
  final commonIdFields = ['id', 'uuid', '_id', 'uid', 'identifier'];

  for (final field in commonIdFields) {
    if (jsonSchema.containsKey(field)) {
      idFields.add(field);
    }
  }

  return idFields;
}

// گرفتن فیلدهای قابل ویرایش (غیر از ID)
Map<String, dynamic> _getEditableFields(
  Map<String, dynamic> jsonSchema,
  Set<String> idFields,
) {
  final editableFields = <String, dynamic>{};

  jsonSchema.forEach((key, value) {
    if (!idFields.contains(key)) {
      editableFields[key] = value;
    }
  });

  return editableFields;
}

String _toTitleCase(String text) {
  if (text.isEmpty) {
    return text;
  }

  final words = text
      .replaceAll('_', ' ')
      .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}')
      .toLowerCase()
      .split(' ')
      .where((word) => word.isNotEmpty);

  return words
      .map((word) => word[0].toUpperCase() + word.substring(1))
      .join(' ');
}

String _getFieldType(dynamic value) {
  if (value is int) {
    return 'int';
  }
  if (value is double) {
    return 'double';
  }
  if (value is bool) {
    return 'bool';
  }
  if (value is String) {
    // Check if it's a date string (YYYY-MM-DD or YYYY-MM-DDTHH:MM:SS)
    final dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}');
    if (dateRegex.hasMatch(value)) {
      return 'DateTime';
    }
    return 'String';
  }
  if (value is Map) {
    return 'Map';
  }
  if (value is List) {
    return 'List';
  }
  return 'String';
}

bool _isNestedField(dynamic value) {
  return value is Map ||
      (value is List && value.isNotEmpty && value.first is Map);
}

bool _hasDateTimeField(Map<String, dynamic> fields) {
  return fields.values.any((value) => _getFieldType(value) == 'DateTime');
}

bool _hasNestedField(Map<String, dynamic> fields) {
  return fields.values.any((value) => _isNestedField(value));
}

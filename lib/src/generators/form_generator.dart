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
  final idFields = _identifyIdFields(jsonSchema, className);
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

    if (_isNestedField(value)) return;

    if (type == 'bool') {
      buffer.writeln('  bool _${camelKey}Value = false;');
    } else if (type == 'DateTime') {
      buffer.writeln('  String? _${camelKey}Value;');
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

    if (_isNestedField(value)) return;

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

    if (type != 'bool' && !_isNestedField(value)) {
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

    if (isNested) return;

    if (type == 'bool') {
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
      buffer.writeln('            AppInput(');
      buffer.writeln('              controller: _${camelKey}Controller,');
      buffer.writeln('              labelText: \'$label\',');
      buffer.writeln('              keyboardType: TextInputType.number,');
      buffer.writeln(
        '              validator: (value) => _validateNumberField(value, \'$label\', \'$type\'),',
      );
      buffer.writeln('            ),');
    } else {
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

  // فیلدهای ID
  for (var idField in idFields) {
    final camelIdField = toCamel(idField);
    buffer.writeln('        $camelIdField: widget.initialData?.$camelIdField,');
  }

  // فیلدهای قابل ویرایش
  editableFields.forEach((key, value) {
    final camelKey = toCamel(key);
    final type = _getFieldType(value);

    if (_isNestedField(value)) {
      // Pass existing nested data if available
      buffer.writeln('        $camelKey: widget.initialData?.$camelKey,');
      return;
    }

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

  // Date picker methods
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
    '      return \'\$fieldName must be a valid number\';',
  );
  buffer.writeln('    }');
  buffer.writeln('    ');
  buffer.writeln('    return null;');
  buffer.writeln('  }');

  buffer.writeln('}');

  return buffer.toString();
}

// شناسایی فیلدهای ID
Set<String> _identifyIdFields(Map<String, dynamic> jsonSchema,
    [String? className]) {
  final idField = identifyIdField(jsonSchema, className);
  return {idField};
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
    // Check if it\u0027s a date string (YYYY-MM-DD or YYYY-MM-DDTHH:MM:SS)
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

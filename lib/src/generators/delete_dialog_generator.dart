// tool/generators/delete_dialog_generator.dart
import '../helpers/naming_helpers.dart';

String generateDeleteDialog({
  required String className,
  required String feature,
  required String projectName,
}) {
  final pascalModel = toPascal(className);
  final snakeModel = toSnakeFromName(className);

  final buffer = StringBuffer();

  // Imports
  buffer.writeln("import 'package:flutter/material.dart';");
  buffer.writeln("import 'package:get/get.dart';");
  buffer.writeln(
    "import 'package:$projectName/features/$feature/presentation/controllers/${snakeModel}_controller.dart';",
  );
  buffer.writeln();

  // Class definition
  buffer.writeln('class Delete${pascalModel}Dialog extends StatelessWidget {');
  buffer.writeln('  final String id;');
  buffer.writeln('  final String name;');
  buffer.writeln();
  buffer.writeln('  const Delete${pascalModel}Dialog({');
  buffer.writeln('    super.key,');
  buffer.writeln('    required this.id,');
  buffer.writeln('    required this.name,');
  buffer.writeln('  });');
  buffer.writeln();
  buffer.writeln('  @override');
  buffer.writeln('  Widget build(BuildContext context) {');
  buffer.writeln('    return AlertDialog(');
  buffer.writeln('      title: const Text(\'Delete $pascalModel\'),');
  buffer.writeln(
    '      content: Text(\'Are you sure you want to delete \\"\$name\\"?\'),',
  );
  buffer.writeln('      actions: [');
  buffer.writeln('        TextButton(');
  buffer.writeln('          onPressed: () => Get.back(),');
  buffer.writeln('          child: const Text(\'Cancel\'),');
  buffer.writeln('        ),');
  buffer.writeln('        ElevatedButton(');
  buffer.writeln('          style: ElevatedButton.styleFrom(');
  buffer.writeln('            backgroundColor: Colors.red,');
  buffer.writeln('          ),');
  buffer.writeln('          onPressed: () {');
  buffer.writeln(
    '            Get.find<${pascalModel}Controller>().delete$pascalModel(id);',
  );
  buffer.writeln('            Get.back();');
  buffer.writeln('          },');
  buffer.writeln(
    '          child: const Text(\'Delete\', style: TextStyle(color: Colors.white)),',
  );
  buffer.writeln('        ),');
  buffer.writeln('      ],');
  buffer.writeln('    );');
  buffer.writeln('  }');
  buffer.writeln('}');
  buffer.writeln();

  // Helper function
  buffer.writeln(
    'void showDelete${pascalModel}Dialog(BuildContext context, String id, String name) {',
  );
  buffer.writeln('  showDialog(');
  buffer.writeln('    context: context,');
  buffer.writeln(
    '    builder: (context) => Delete${pascalModel}Dialog(id: id, name: name),',
  );
  buffer.writeln('  );');
  buffer.writeln('}');

  return buffer.toString();
}

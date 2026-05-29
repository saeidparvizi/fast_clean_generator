// tool/generators/edit_page_generator.dart
import '../helpers/naming_helpers.dart';

String generateEditScreen({
  required String className,
  required String feature,
  required String projectName,
  required Map<String, dynamic> jsonSchema,
}) {
  final pascalModel = toPascal(className);
  final snakeModel = toSnakeFromName(className);
  // final camelModel = toCamel(className);

  final buffer = StringBuffer();

  // Imports
  buffer.writeln("import 'package:flutter/material.dart';");
  buffer.writeln("import 'package:get/get.dart';");
  buffer.writeln(
    "import 'package:$projectName/features/$feature/presentation/controllers/${snakeModel}_controller.dart';",
  );
  buffer.writeln(
    "import 'package:$projectName/features/$feature/presentation/widgets/${snakeModel}_form.dart';",
  );
  buffer.writeln();

  // Class definition
  buffer.writeln('class Edit${pascalModel}Screen extends StatelessWidget {');
  buffer.writeln('  const Edit${pascalModel}Screen({super.key});');
  buffer.writeln();

  buffer.writeln('  @override');
  buffer.writeln('  Widget build(BuildContext context) {');
  buffer.writeln(
    '    final controller = Get.find<${pascalModel}Controller>();',
  );
  buffer.writeln('    ');
  buffer.writeln('    return Scaffold(');
  buffer.writeln('      appBar: AppBar(');
  buffer.writeln('        title: const Text(\'Edit $pascalModel\'),');
  buffer.writeln('        leading: IconButton(');
  buffer.writeln('          icon: const Icon(Icons.arrow_back),');
  buffer.writeln('          onPressed: () => Get.back(),');
  buffer.writeln('        ),');
  buffer.writeln('      ),');
  buffer.writeln('      body: Padding(');
  buffer.writeln('        padding: const EdgeInsets.all(16.0),');
  buffer.writeln('        child: ${pascalModel}Form(');
  buffer.writeln('          initialData: controller.item,');
  buffer.writeln('          onSubmit: (updated$pascalModel) {');
  buffer.writeln('            controller.updateItem(updated$pascalModel);');
  buffer.writeln('            controller.update$pascalModel();');
  buffer.writeln('          },');
  buffer.writeln('        ),');
  buffer.writeln('      ),');
  buffer.writeln('    );');
  buffer.writeln('  }');
  buffer.writeln('}');

  return buffer.toString();
}

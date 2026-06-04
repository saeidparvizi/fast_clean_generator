// tool/generators/page_generator.dart
import '../helpers/naming_helpers.dart';

String generateListScreen({
  required String className,
  required String feature,
  required String projectName,
  required List<String> crudMethods,
  required Map<String, dynamic> jsonSchema,
}) {
  final pascalModel = toPascal(className);
  final snakeModel = toSnakeFromName(className);
  final pluralPascalModel = pluralize(pascalModel);
  final pluralSnakeModel = toSnakeFromName(pluralPascalModel);

  final idField = identifyIdField(jsonSchema);

  final buffer = StringBuffer();

  // Imports برای صفحه لیست
  buffer.writeln("import 'package:flutter/material.dart';");
  buffer.writeln("import 'package:get/get.dart';");
  buffer.writeln("import 'package:$projectName/core/widgets/appbar.dart';");
  buffer.writeln(
    "import 'package:$projectName/features/$feature/presentation/controllers/${pluralSnakeModel}_controller.dart';",
  );
  buffer.writeln(
    "import 'package:$projectName/features/$feature/domain/entities/${snakeModel}_entity.dart';",
  );
  buffer.writeln("import 'package:$projectName/core/routes/app_pages.dart';");

  if (crudMethods.contains('delete')) {
    buffer.writeln(
      "import 'package:$projectName/features/$feature/presentation/widgets/delete_${snakeModel}_dialog.dart';",
    );
  }

  buffer.writeln();

  // Class definition برای صفحه لیست
  buffer.writeln(
    'class ${pluralPascalModel}Screen extends GetView<${pluralPascalModel}Controller> {',
  );
  buffer.writeln('  const ${pluralPascalModel}Screen({super.key});');
  buffer.writeln();

  buffer.writeln('  @override');
  buffer.writeln('  Widget build(BuildContext context) {');
  buffer.writeln('    return Scaffold(');
  buffer.writeln('      appBar: AppAppbar(');
  buffer.writeln('        label: \'$pluralPascalModel\',');

  if (crudMethods.contains('add')) {
    buffer.writeln('        actions: [');
    buffer.writeln('          IconButton(');
    buffer.writeln('            icon: const Icon(Icons.add),');
    buffer.writeln(
      '            onPressed: () => Get.toNamed(AppRoutes.${snakeModel}Add),',
    );
    buffer.writeln('          ),');
    buffer.writeln('        ],');
  } else {
    buffer.writeln('        actions: [],');
  }

  buffer.writeln('      ),');
  buffer.writeln('      body: GetBuilder<${pluralPascalModel}Controller>(');
  buffer.writeln('        builder: (controller) {');
  buffer.writeln(
    '          if (controller.isLoading.value && controller.$pluralSnakeModel.isEmpty) {',
  );
  buffer.writeln(
    '            return const Center(child: CircularProgressIndicator());',
  );
  buffer.writeln('          }');
  buffer.writeln();
  buffer.writeln('          if (controller.error.value.isNotEmpty) {');
  buffer.writeln('            return Center(');
  buffer.writeln('              child: Text(controller.error.value),');
  buffer.writeln('            );');
  buffer.writeln('          }');
  buffer.writeln();
  buffer.writeln('          return ListView.builder(');
  buffer.writeln('            padding: const EdgeInsets.all(8),');
  buffer.writeln('            itemCount: controller.$pluralSnakeModel.length,');
  buffer.writeln('            itemBuilder: (context, index) {');
  buffer.writeln(
    '              final $snakeModel = controller.$pluralSnakeModel[index];',
  );
  buffer.writeln('              return Card(');
  buffer.writeln('                elevation: 2,');
  buffer.writeln(
      '                margin: const EdgeInsets.symmetric(vertical: 4),');
  buffer.writeln('                child: ListTile(');
  buffer
      .writeln('                  title: Text(\'#\${$snakeModel.$idField}\'),');
  buffer.writeln('                  subtitle: Text($snakeModel.toString()),');
  buffer.writeln('                  trailing: Row(');
  buffer.writeln('                    mainAxisSize: MainAxisSize.min,');
  buffer.writeln('                    children: [');

  if (crudMethods.contains('get')) {
    buffer.writeln('                      IconButton(');
    buffer
        .writeln('                        icon: const Icon(Icons.visibility),');
    buffer.writeln(
      '                        onPressed: () => Get.toNamed(AppRoutes.$snakeModel, parameters: {\'id\': $snakeModel.$idField.toString()}),',
    );
    buffer.writeln('                      ),');
  }

  if (crudMethods.contains('update')) {
    buffer.writeln('                      IconButton(');
    buffer.writeln('                        icon: const Icon(Icons.edit),');
    buffer.writeln(
      '                        onPressed: () => Get.toNamed(AppRoutes.${snakeModel}Edit, parameters: {\'id\': $snakeModel.$idField.toString()}),',
    );
    buffer.writeln('                      ),');
  }

  if (crudMethods.contains('delete')) {
    buffer.writeln('                      IconButton(');
    buffer.writeln(
        '                        icon: const Icon(Icons.delete, color: Colors.red),');
    buffer.writeln(
      '                        onPressed: () => showDelete${pascalModel}Dialog(context, $snakeModel.$idField, $snakeModel.toString()),',
    );
    buffer.writeln('                      ),');
  }

  buffer.writeln('                    ],');
  buffer.writeln('                  ),');
  buffer.writeln('                ),');
  buffer.writeln('              );');
  buffer.writeln('            },');
  buffer.writeln('          );');
  buffer.writeln('        },');
  buffer.writeln('      ),');
  buffer.writeln('    );');
  buffer.writeln('  }');
  buffer.writeln('}');

  return buffer.toString();
}

// tool/generators/page_generator.dart (بخش تک‌آیتم - اصلاح شده)

String generateSingleScreen({
  required String className,
  required String feature,
  required String projectName,
  required List<String> crudMethods,
  required Map<String, dynamic> jsonSchema,
}) {
  final pascalModel = toPascal(className);
  final snakeModel = toSnakeFromName(className);
  // final camelModel = toCamel(className);

  final buffer = StringBuffer();

  // Imports برای صفحه تک‌آیتم
  buffer.writeln("import 'package:flutter/material.dart';");
  buffer.writeln("import 'package:get/get.dart';");
  buffer.writeln("import 'package:$projectName/core/widgets/appbar.dart';");
  buffer.writeln(
    "import 'package:$projectName/features/$feature/presentation/controllers/${snakeModel}_controller.dart';",
  );
  buffer.writeln(
    "import 'package:$projectName/features/$feature/domain/entities/${snakeModel}_entity.dart';",
  );

  if (crudMethods.contains('update')) {
    buffer.writeln("import 'package:$projectName/core/routes/app_pages.dart';");
    buffer.writeln(
      "import 'package:$projectName/features/$feature/presentation/widgets/${snakeModel}_form.dart';",
    );
  }

  buffer.writeln();

  // Class definition برای صفحه تک‌آیتم
  buffer.writeln(
    'class ${pascalModel}Screen extends GetView<${pascalModel}Controller> {',
  );
  buffer.writeln('  const ${pascalModel}Screen({super.key});');
  buffer.writeln();

  buffer.writeln('  @override');
  buffer.writeln('  Widget build(BuildContext context) {');
  buffer.writeln('    return Scaffold(');
  buffer.writeln('      appBar: AppAppbar(');
  buffer.writeln('        label: \'$pascalModel Details\',');
  buffer.writeln('        leading: IconButton(');
  buffer.writeln('          icon: const Icon(Icons.arrow_back),');
  buffer.writeln('          onPressed: () => Get.back(),');
  buffer.writeln('        ),');

  if (crudMethods.contains('update')) {
    buffer.writeln('        actions: [');
    buffer.writeln('          IconButton(');
    buffer.writeln('            icon: const Icon(Icons.edit),');
    buffer.writeln('            onPressed: () => Get.toNamed(');
    buffer.writeln('              AppRoutes.${snakeModel}Edit,');
    buffer.writeln(
      '              arguments: {\'$snakeModel\': Get.find<${pascalModel}Controller>().item},',
    );
    buffer.writeln('            ),');
    buffer.writeln('          ),');
    buffer.writeln('        ],');
  }

  buffer.writeln('      ),');
  buffer.writeln('      body: GetBuilder<${pascalModel}Controller>(');
  buffer.writeln('        builder: (controller) {');
  buffer.writeln(
    '          if (controller.isLoading.value && controller.item == null) {',
  );
  buffer.writeln(
    '            return const Center(child: CircularProgressIndicator());',
  );
  buffer.writeln('          }');
  buffer.writeln();
  buffer.writeln('          if (controller.error.value.isNotEmpty) {');
  buffer.writeln('            return Center(');
  buffer.writeln('              child: Text(controller.error.value),');
  buffer.writeln('            );');
  buffer.writeln('          }');
  buffer.writeln();
  buffer.writeln('          final ${snakeModel}Data = controller.item;');
  buffer.writeln('          if (${snakeModel}Data == null) {');
  buffer.writeln(
    '            return const Center(child: Text(\'$pascalModel not found\'));',
  );
  buffer.writeln('          }');
  buffer.writeln();
  buffer.writeln('          return SingleChildScrollView(');
  buffer.writeln('            padding: const EdgeInsets.all(16.0),');
  buffer.writeln('            child: Column(');
  buffer.writeln('              crossAxisAlignment: CrossAxisAlignment.start,');
  buffer.writeln('              children: [');

  // نمایش فیلدها براساس JSON schema
  jsonSchema.forEach((key, value) {
    final camelKey = toCamel(key);
    final title = toTitleCase(key);

    buffer.writeln(
        '                _buildDetailRow(\'$title\', ${snakeModel}Data.$camelKey?.toString() ?? "N/A"),');
  });

  buffer.writeln('              ],');
  buffer.writeln('            ),');
  buffer.writeln('          );');
  buffer.writeln('        },');
  buffer.writeln('      ),');
  buffer.writeln('    );');
  buffer.writeln('  }');
  buffer.writeln();
  buffer.writeln('  Widget _buildDetailRow(String label, String value) {');
  buffer.writeln('    return Padding(');
  buffer.writeln('      padding: const EdgeInsets.symmetric(vertical: 8.0),');
  buffer.writeln('      child: Row(');
  buffer.writeln('        crossAxisAlignment: CrossAxisAlignment.start,');
  buffer.writeln('        children: [');
  buffer.writeln(
      '          Text(\'\$label: \', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),');
  buffer.writeln(
      '          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),');
  buffer.writeln('        ],');
  buffer.writeln('      ),');
  buffer.writeln('    );');
  buffer.writeln('  }');
  buffer.writeln('}');

  return buffer.toString();
}

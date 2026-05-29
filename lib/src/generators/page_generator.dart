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

  // Add FAB if add method exists
  if (crudMethods.contains('add')) {
    buffer.writeln('        actions: [');
    buffer.writeln('          IconButton(');
    buffer.writeln('            icon: const Icon(Icons.add),');
    buffer.writeln(
      '            onPressed: () => Get.toNamed(AppRoutes.${snakeModel}Add),',
    );
    buffer.writeln('          ),');
    buffer.writeln('        ],');
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
  buffer.writeln('            itemCount: controller.$pluralSnakeModel.length,');
  buffer.writeln('            itemBuilder: (context, index) {');
  buffer.writeln(
    '              final $snakeModel = controller.$pluralSnakeModel[index];',
  );
  buffer.writeln('              return ListTile(');
  buffer.writeln('                title: Text($snakeModel.toString()),');
  buffer.writeln('                trailing: Row(');
  buffer.writeln('                  mainAxisSize: MainAxisSize.min,');
  buffer.writeln('                  children: [');

  if (crudMethods.contains('get')) {
    buffer.writeln('                    IconButton(');
    buffer.writeln('                      icon: const Icon(Icons.visibility),');
    buffer.writeln(
      '                      onPressed: () => Get.toNamed(AppRoutes.$snakeModel, parameters: {\'id\': $snakeModel.$idField.toString()}),',
    );
    buffer.writeln('                    ),');
  }

  if (crudMethods.contains('update')) {
    buffer.writeln('                    IconButton(');
    buffer.writeln('                      icon: const Icon(Icons.edit),');
    buffer.writeln(
      '                      onPressed: () => Get.toNamed(AppRoutes.${snakeModel}Edit, parameters: {\'id\': $snakeModel.$idField.toString()}),',
    );
    buffer.writeln('                    ),');
  }

  if (crudMethods.contains('delete')) {
    buffer.writeln('                    IconButton(');
    buffer.writeln('                      icon: const Icon(Icons.delete),');
    buffer.writeln(
      '                      onPressed: () => _showDeleteDialog(context, controller, $snakeModel),',
    );
    buffer.writeln('                    ),');
  }

  buffer.writeln('                  ],');
  buffer.writeln('                ),');
  buffer.writeln('              );');
  buffer.writeln('            },');
  buffer.writeln('          );');
  buffer.writeln('        },');
  buffer.writeln('      ),');
  buffer.writeln('    );');
  buffer.writeln('  }');
  buffer.writeln();

  // Delete Dialog method
  if (crudMethods.contains('delete')) {
    buffer.writeln(
      '  void _showDeleteDialog(BuildContext context, ${pluralPascalModel}Controller controller, ${pascalModel}Entity $snakeModel) {',
    );
    buffer.writeln('    showDialog(');
    buffer.writeln('      context: context,');
    buffer.writeln('      builder: (context) => AlertDialog(');
    buffer.writeln('        title: const Text(\'Delete $pascalModel\'),');
    buffer.writeln(
      '        content: Text(\'Are you sure you want to delete \\"\${$snakeModel.toString()}\\"?\'),',
    );
    buffer.writeln('        actions: [');
    buffer.writeln('          TextButton(');
    buffer.writeln('            onPressed: () => Get.back(),');
    buffer.writeln('            child: const Text(\'Cancel\'),');
    buffer.writeln('          ),');
    buffer.writeln('          ElevatedButton(');
    buffer.writeln('            style: ElevatedButton.styleFrom(');
    buffer.writeln('              backgroundColor: Colors.red,');
    buffer.writeln('            ),');
    buffer.writeln('            onPressed: () {');
    buffer.writeln(
      '              controller.delete$pascalModel($snakeModel.$idField!);',
    );
    buffer.writeln('              Get.back();');
    buffer.writeln('            },');
    buffer.writeln(
      '            child: const Text(\'Delete\', style: TextStyle(color: Colors.white)),',
    );
    buffer.writeln('          ),');
    buffer.writeln('        ],');
    buffer.writeln('      ),');
    buffer.writeln('    );');
    buffer.writeln('  }');
  }

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

    buffer.writeln('                Text(');
    buffer.writeln(
      '                  \'$title: \${${snakeModel}Data.$camelKey?.toString() ?? "N/A"}\',',
    );
    buffer.writeln('                  style: const TextStyle(fontSize: 16),');
    buffer.writeln('                ),');
    buffer.writeln('                const SizedBox(height: 8),');
  });

  buffer.writeln('              ],');
  buffer.writeln('            ),');
  buffer.writeln('          );');
  buffer.writeln('        },');
  buffer.writeln('      ),');
  buffer.writeln('    );');
  buffer.writeln('  }');
  buffer.writeln('}');

  return buffer.toString();
}

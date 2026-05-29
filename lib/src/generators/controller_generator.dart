// tool/generators/controller_generator.dart
import '../helpers/naming_helpers.dart';

String generateListController({
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
  // final camelPlural = toCamel(pluralPascalModel);

  final buffer = StringBuffer();

  // Imports برای لیست
  buffer.writeln("import 'package:get/get.dart';");
  buffer.writeln(
    "import 'package:$projectName/features/$feature/domain/entities/${snakeModel}_entity.dart';",
  );

  // Import use cases براساس CRUD methods
  final useCaseImports = _generateUseCaseImportsForList(
    feature,
    className,
    crudMethods,
    projectName,
  );
  for (final import in useCaseImports) {
    buffer.writeln(import);
  }

  buffer.writeln();

  // Class definition برای لیست
  buffer.writeln(
    'class ${pluralPascalModel}Controller extends GetxController {',
  );
  buffer.writeln();

  // Constructor
  _generateConstructorForList(buffer, className, crudMethods);
  buffer.writeln();

  // Use case fields
  _generateUseCaseFieldsForList(buffer, className, crudMethods);
  buffer.writeln();

  // State variables برای لیست
  buffer.writeln('  // State');
  buffer.writeln(
    '  final RxList<${pascalModel}Entity> $pluralSnakeModel = <${pascalModel}Entity>[].obs;',
  );
  buffer.writeln('  final RxBool isLoading = false.obs;');
  buffer.writeln('  final RxString error = \'\'.obs;');
  buffer.writeln();

  // onInit method - اصلاح شده
  _generateOnInitForList(buffer, className, crudMethods);
  buffer.writeln();

  // Methods - اصلاح شده با Map parameters
  _generateMethodsForList(buffer, className, crudMethods, jsonSchema);

  buffer.writeln('}');

  return buffer.toString();
}

// Helper functions برای لیست - اصلاح imports
List<String> _generateUseCaseImportsForList(
  String feature,
  String model,
  List<String> crudMethods,
  String projectName,
) {
  final snakeModel = toSnakeFromName(model);
  final pluralSnakeModel = toSnakeFromName(pluralize(model));

  final imports = <String>[];

  // برای لیست: list, add, update, delete
  if (crudMethods.contains('list')) {
    imports.add(
      "import 'package:$projectName/features/$feature/domain/usecases/${pluralSnakeModel}_usecase.dart';",
    );
  }

  if (crudMethods.contains('add')) {
    imports.add(
      "import 'package:$projectName/features/$feature/domain/usecases/add_${snakeModel}_usecase.dart';",
    );
  }

  if (crudMethods.contains('update')) {
    imports.add(
      "import 'package:$projectName/features/$feature/domain/usecases/update_${snakeModel}_usecase.dart';",
    );
  }

  if (crudMethods.contains('delete')) {
    imports.add(
      "import 'package:$projectName/features/$feature/domain/usecases/delete_${snakeModel}_usecase.dart';",
    );
  }

  imports.add("import 'package:$projectName/core/utils/utils.dart';");

  return imports;
}

void _generateUseCaseFieldsForList(
  StringBuffer buffer,
  String model,
  List<String> crudMethods,
) {
  final pascalModel = toPascal(model);
  final pluralPascalModel = pluralize(pascalModel);

  buffer.writeln('  // Use Cases');

  if (crudMethods.contains('list')) {
    buffer.writeln(
      '  final ${pluralPascalModel}UseCase ${toCamel(pluralPascalModel)}UseCase;',
    );
  }

  if (crudMethods.contains('add')) {
    buffer.writeln(
      '  final Add${pascalModel}UseCase add${pascalModel}UseCase;',
    );
  }

  if (crudMethods.contains('update')) {
    buffer.writeln(
      '  final Update${pascalModel}UseCase update${pascalModel}UseCase;',
    );
  }

  if (crudMethods.contains('delete')) {
    buffer.writeln(
      '  final Delete${pascalModel}UseCase delete${pascalModel}UseCase;',
    );
  }
}

void _generateConstructorForList(
  StringBuffer buffer,
  String model,
  List<String> crudMethods,
) {
  final pascalModel = toPascal(model);
  final pluralPascalModel = pluralize(pascalModel);
  final camelPlural = toCamel(pluralPascalModel);

  buffer.write('  ${pluralPascalModel}Controller({');

  final params = <String>[];
  if (crudMethods.contains('list')) {
    params.add('required this.${camelPlural}UseCase');
  }
  if (crudMethods.contains('add')) {
    params.add('required this.add${pascalModel}UseCase');
  }
  if (crudMethods.contains('update')) {
    params.add('required this.update${pascalModel}UseCase');
  }
  if (crudMethods.contains('delete')) {
    params.add('required this.delete${pascalModel}UseCase');
  }

  buffer.write(params.join(', '));
  buffer.writeln('});');
}

void _generateOnInitForList(
  StringBuffer buffer,
  String model,
  List<String> crudMethods,
) {
  final pascalModel = toPascal(model);
  final pluralPascalModel = pluralize(pascalModel);
  // final camelPlural = toCamel(pluralPascalModel);

  buffer.writeln('  @override');
  buffer.writeln('  void onInit() {');

  if (crudMethods.contains('list')) {
    buffer.writeln('    get$pluralPascalModel();'); // اصلاح شده: getUsers()
  }

  buffer.writeln('    super.onInit();');
  buffer.writeln('  }');
}

// tool/generators/controller_generator.dart (بخش لیست - اصلاح شده)

void _generateMethodsForList(
  StringBuffer buffer,
  String model,
  List<String> crudMethods,
  Map<String, dynamic> jsonSchema,
) {
  final pascalModel = toPascal(model);
  final pluralPascalModel = pluralize(pascalModel);
  final pluralSnakeModel = toSnakeFromName(pluralPascalModel);
  final camelPlural = toCamel(pluralPascalModel);
  final camelModel = toCamel(model);

  // شناسایی فیلد ID از JSON schema
  final idField = identifyIdField(jsonSchema);

  // Get all (list) method
  if (crudMethods.contains('list')) {
    buffer.writeln('  Future<void> get$pluralPascalModel() async {');
    buffer.writeln('    try {');
    buffer.writeln('      isLoading.value = true;');
    buffer.writeln('      error.value = \'\';');
    buffer.writeln('      ');
    buffer.writeln('      final result = await ${camelPlural}UseCase({});');
    buffer.writeln('      ');
    buffer.writeln('      result.fold(');
    buffer.writeln('        (failure) => error.value = failure.toString(),');
    buffer.writeln('        (data) => $pluralSnakeModel.value = data,');
    buffer.writeln('      );');
    buffer.writeln('    } catch (e) {');
    buffer.writeln('      error.value = e.toString();');
    buffer.writeln('    } finally {');
    buffer.writeln('      isLoading.value = false;');
    buffer.writeln('    }');
    buffer.writeln('  }');
    buffer.writeln();
  }

  // Add method - اصلاح شده (بدون toJson)
  if (crudMethods.contains('add')) {
    buffer.writeln(
      '  Future<void> add$pascalModel(${pascalModel}Entity $camelModel) async {',
    );
    buffer.writeln('    try {');
    buffer.writeln('      isLoading.value = true;');
    buffer.writeln('      error.value = \'\';');
    buffer.writeln('      ');
    buffer.writeln('      // Create map from entity properties');
    buffer.writeln('      final Map<String, dynamic> ${camelModel}Map = {');

    // تولید map از فیلدهای موجود در JSON schema
    jsonSchema.forEach((key, value) {
      final camelKey = toCamel(key);
      buffer.writeln("        '$key': $camelModel.$camelKey,");
    });

    buffer.writeln('      };');
    buffer.writeln('      ');
    buffer.writeln('      final result = await add${pascalModel}UseCase({');
    buffer.writeln('        \'$camelModel\': ${camelModel}Map,');
    buffer.writeln('      });');
    buffer.writeln('      ');
    buffer.writeln('      result.fold(');
    buffer.writeln('        (failure) => error.value = failure.toString(),');
    buffer.writeln('        (data) {');
    buffer.writeln('          $pluralSnakeModel.add(data);');
    buffer.writeln('          Get.back();');
    buffer.writeln(
      '          Get.snackbar(\'Success\', \'$pascalModel added successfully\');',
    );
    buffer.writeln('        },');
    buffer.writeln('      );');
    buffer.writeln('    } catch (e) {');
    buffer.writeln('      error.value = e.toString();');
    buffer.writeln('    } finally {');
    buffer.writeln('      isLoading.value = false;');
    buffer.writeln('    }');
    buffer.writeln('  }');
    buffer.writeln();
  }

  // Delete method - استفاده از فیلد ID شناسایی شده
  if (crudMethods.contains('delete')) {
    final idField = identifyIdField(jsonSchema);

    buffer.writeln(
      '  Future<void> delete$pascalModel(${jsonSchema[idField].runtimeType} id) async {',
    );
    buffer.writeln('    isLoading.value = true;');
    buffer.writeln('    error.value = \'\';');
    buffer.writeln('    ');
    buffer.writeln('    final result = await delete${pascalModel}UseCase({');
    buffer.writeln('      \'$idField\': id,');
    buffer.writeln('    });');
    buffer.writeln('    result.fold(');

    buffer.writeln('       (failure) {');
    buffer.writeln('        isLoading.value = false;');
    buffer.writeln('        error.value = failure.message;');
    buffer.writeln('         },');
    buffer.writeln('      (data) {');
    buffer.writeln('        isLoading.value = false;');
    // حذف براساس فیلد ID شناسایی شده
    if (idField == 'id') {
      buffer.writeln(
        '        $pluralSnakeModel.removeWhere((item) => item.id == id);',
      );
    } else if (idField == 'uuid') {
      buffer.writeln(
        '        $pluralSnakeModel.removeWhere((item) => item.uuid == id);',
      );
    } else if (idField == '_id') {
      buffer.writeln(
        '        $pluralSnakeModel.removeWhere((item) => item._id == id);',
      );
    } else {
      buffer.writeln('        // Using generic identifier removal');
      buffer.writeln(
        '        $pluralSnakeModel.removeWhere((item) => item.id == id || item.uuid == id || item._id == id);',
      );
    }
    buffer.writeln(
      "        Utils.showMessage(message: '$pascalModel deleted successfully');",
    );
    buffer.writeln('      },');
    buffer.writeln('    );');
    buffer.writeln('}');
    buffer.writeln();
  }

  // Update method - اصلاح شده (بدون toJson)
  if (crudMethods.contains('update') && crudMethods.contains('list')) {
    buffer.writeln(
      '  Future<void> update$pascalModel(${pascalModel}Entity $camelModel) async {',
    );
    buffer.writeln('    try {');
    buffer.writeln('      isLoading.value = true;');
    buffer.writeln('      error.value = \'\';');
    buffer.writeln('      ');
    buffer.writeln('      // Create map from entity properties');
    buffer.writeln('      final Map<String, dynamic> ${camelModel}Map = {');

    // تولید map از فیلدهای موجود در JSON schema
    jsonSchema.forEach((key, value) {
      final camelKey = toCamel(key);
      buffer.writeln("        '$key': $camelModel.$camelKey,");
    });

    buffer.writeln('      };');
    buffer.writeln('      ');
    buffer.writeln('      final result = await update${pascalModel}UseCase({');
    buffer.writeln('        \'$camelModel\': ${camelModel}Map,');
    buffer.writeln('      });');
    buffer.writeln('      ');
    buffer.writeln('      result.fold(');
    buffer.writeln('        (failure) => error.value = failure.toString(),');
    buffer.writeln('        (data) {');

    // آپدیت براساس فیلد ID شناسایی شده
    if (idField == 'id') {
      buffer.writeln(
        '          final index = $pluralSnakeModel.indexWhere((item) => item.id == data.id);',
      );
    } else if (idField == 'uuid') {
      buffer.writeln(
        '          final index = $pluralSnakeModel.indexWhere((item) => item.uuid == data.uuid);',
      );
    } else if (idField == '_id') {
      buffer.writeln(
        '          final index = $pluralSnakeModel.indexWhere((item) => item._id == data._id);',
      );
    } else {
      buffer.writeln('          // Try to find item by any identifier');
      buffer.writeln('          int index = -1;');
      buffer.writeln('          if (data.id != null) {');
      buffer.writeln(
        '            index = $pluralSnakeModel.indexWhere((item) => item.id == data.id);',
      );
      buffer.writeln(
        '          } else if (data.uuid != null && index == -1) {',
      );
      buffer.writeln(
        '            index = $pluralSnakeModel.indexWhere((item) => item.uuid == data.uuid);',
      );
      buffer.writeln('          } else if (data._id != null && index == -1) {');
      buffer.writeln(
        '            index = $pluralSnakeModel.indexWhere((item) => item._id == data._id);',
      );
      buffer.writeln('          }');
    }

    buffer.writeln(
      '          if (index != -1) $pluralSnakeModel[index] = data;',
    );
    buffer.writeln('          Get.back();');
    buffer.writeln(
      '          Get.snackbar(\'Success\', \'$pascalModel updated successfully\');',
    );
    buffer.writeln('        },');
    buffer.writeln('      );');
    buffer.writeln('    } catch (e) {');
    buffer.writeln('      error.value = e.toString();');
    buffer.writeln('    } finally {');
    buffer.writeln('      isLoading.value = false;');
    buffer.writeln('    }');
    buffer.writeln('  }');
  }
}

// tool/generators/controller_generator.dart (بخش تک‌آیتم)

// tool/generators/controller_generator.dart (بخش تک‌آیتم - اصلاح شده)

String generateSingleController({
  required String className,
  required String feature,
  required String projectName,
  required List<String> crudMethods,
  required Map<String, dynamic> jsonSchema,
}) {
  final pascalModel = toPascal(className);
  final snakeModel = toSnakeFromName(className);
  // final camelModel = toCamel(className);

  // شناسایی فیلد ID
  final idField = identifyIdField(jsonSchema);

  final buffer = StringBuffer();

  // Imports برای تک‌آیتم
  buffer.writeln("import 'package:get/get.dart';");
  buffer.writeln(
    "import 'package:$projectName/features/$feature/domain/entities/${snakeModel}_entity.dart';",
  );

  // Import use cases براساس CRUD methods
  final useCaseImports = _generateUseCaseImportsForSingle(
    feature,
    className,
    crudMethods,
    projectName,
  );
  for (final import in useCaseImports) {
    buffer.writeln(import);
  }

  buffer.writeln();

  // Class definition برای تک‌آیتم
  buffer.writeln('class ${pascalModel}Controller extends GetxController {');
  buffer.writeln();

  // Constructor
  _generateConstructorForSingle(buffer, className, crudMethods);
  buffer.writeln();

  // State variables برای تک‌آیتم
  buffer.writeln('  // State');
  buffer.writeln('  ${pascalModel}Entity? item;');
  buffer.writeln('  String? id;');
  buffer.writeln('  final RxBool isLoading = false.obs;');
  buffer.writeln('  final RxString error = \'\'.obs;');
  buffer.writeln();

  // Use case fields
  _generateUseCaseFieldsForSingle(buffer, className, crudMethods);
  buffer.writeln();

  // onInit method - اصلاح شده با منطق جدید
  _generateOnInitForSingle(buffer, className, crudMethods, idField);
  buffer.writeln();

  // Methods - اصلاح شده
  _generateMethodsForSingle(
    buffer,
    className,
    crudMethods,
    jsonSchema,
    idField,
  );

  buffer.writeln('}');

  return buffer.toString();
}

void _generateOnInitForSingle(
  StringBuffer buffer,
  String model,
  List<String> crudMethods,
  String idField,
) {
  final pascalModel = toPascal(model);
  final snakeModel = toSnakeFromName(model);

  buffer.writeln('  @override');
  buffer.writeln('  void onInit() {');
  buffer.writeln('    final argument = Get.arguments;');
  buffer.writeln('    final parameters = Get.parameters;');
  buffer.writeln('    ');
  buffer.writeln(
    '    if (argument != null && argument is Map && argument.containsKey(\'$snakeModel\')) {',
  );
  buffer.writeln('      item = argument[\'$snakeModel\'];');
  buffer.writeln('    }');
  buffer.writeln('    ');
  buffer.writeln('    id = parameters[\'$idField\'];');
  buffer.writeln('    ');
  buffer.writeln('    if (item == null && id != null && id!.isNotEmpty) {');

  if (crudMethods.contains('get')) {
    buffer.writeln('      get$pascalModel(id!);');
  }

  buffer.writeln('    }');
  buffer.writeln('    ');
  buffer.writeln('    super.onInit();');
  buffer.writeln('  }');
}

void _generateMethodsForSingle(
  StringBuffer buffer,
  String model,
  List<String> crudMethods,
  Map<String, dynamic> jsonSchema,
  String idField,
) {
  final pascalModel = toPascal(model);
  // final snakeModel = toSnakeFromName(model);
  final camelModel = toCamel(model);

  // Get single method
  if (crudMethods.contains('get')) {
    buffer.writeln('  Future<void> get$pascalModel(String id) async {');
    buffer.writeln('    try {');
    buffer.writeln('      isLoading.value = true;');
    buffer.writeln('      error.value = \'\';');
    buffer.writeln('      ');
    buffer.writeln('      final result = await get${pascalModel}UseCase({');
    buffer.writeln('        \'$idField\': id,');
    buffer.writeln('      });');
    buffer.writeln('      ');
    buffer.writeln('      result.fold(');
    buffer.writeln('        (failure) => error.value = failure.toString(),');
    buffer.writeln('        (data) {');
    buffer.writeln('          item = data;');
    buffer.writeln('          update();');
    buffer.writeln('        },');
    buffer.writeln('      );');
    buffer.writeln('    } catch (e) {');
    buffer.writeln('      error.value = e.toString();');
    buffer.writeln('    } finally {');
    buffer.writeln('      isLoading.value = false;');
    buffer.writeln('    }');
    buffer.writeln('  }');
    buffer.writeln();
  }

  // Update method - اصلاح شده
  if (crudMethods.contains('update')) {
    buffer.writeln('  Future<void> update$pascalModel() async {');
    buffer.writeln('    if (item == null) return;');
    buffer.writeln('    ');
    buffer.writeln('    try {');
    buffer.writeln('      isLoading.value = true;');
    buffer.writeln('      error.value = \'\';');
    buffer.writeln('      ');
    buffer.writeln('      // Create map from entity properties');
    buffer.writeln('      final Map<String, dynamic> ${camelModel}Map = {');

    // تولید map از فیلدهای موجود در JSON schema
    jsonSchema.forEach((key, value) {
      final camelKey = toCamel(key);
      buffer.writeln("        '$key': item!.$camelKey,");
    });

    buffer.writeln('      };');
    buffer.writeln('      ');
    buffer.writeln('      final result = await update${pascalModel}UseCase({');
    buffer.writeln('        \'$camelModel\': ${camelModel}Map,');
    buffer.writeln('      });');
    buffer.writeln('      ');
    buffer.writeln('      result.fold(');
    buffer.writeln('        (failure) => error.value = failure.toString(),');
    buffer.writeln('        (data) {');
    buffer.writeln('          item = data;');
    buffer.writeln('          update();');
    buffer.writeln('          Get.back();');
    buffer.writeln(
      '          Get.snackbar(\'Success\', \'$pascalModel updated successfully\');',
    );
    buffer.writeln('        },');
    buffer.writeln('      );');
    buffer.writeln('    } catch (e) {');
    buffer.writeln('      error.value = e.toString();');
    buffer.writeln('    } finally {');
    buffer.writeln('      isLoading.value = false;');
    buffer.writeln('    }');
    buffer.writeln('  }');
  }

  // Helper method برای آپدیت item
  buffer.writeln();
  buffer.writeln('  void updateItem(${pascalModel}Entity newItem) {');
  buffer.writeln('    item = newItem;');
  buffer.writeln('    update();');
  buffer.writeln('  }');
}

// Helper functions برای تک‌آیتم - اصلاح imports
List<String> _generateUseCaseImportsForSingle(
  String feature,
  String model,
  List<String> crudMethods,
  String projectName,
) {
  // final pascalModel = toPascal(model);
  final snakeModel = toSnakeFromName(model);

  final imports = <String>[];

  // برای تک‌آیتم: get, update
  if (crudMethods.contains('get')) {
    imports.add(
      "import 'package:$projectName/features/$feature/domain/usecases/get_${snakeModel}_usecase.dart';",
    );
  }

  if (crudMethods.contains('update')) {
    imports.add(
      "import 'package:$projectName/features/$feature/domain/usecases/update_${snakeModel}_usecase.dart';",
    );
  }

  return imports;
}

void _generateUseCaseFieldsForSingle(
  StringBuffer buffer,
  String model,
  List<String> crudMethods,
) {
  final pascalModel = toPascal(model);

  buffer.writeln('  // Use Cases');

  if (crudMethods.contains('get')) {
    buffer.writeln(
      '  final Get${pascalModel}UseCase get${pascalModel}UseCase;',
    );
  }

  if (crudMethods.contains('update')) {
    buffer.writeln(
      '  final Update${pascalModel}UseCase update${pascalModel}UseCase;',
    );
  }
}

void _generateConstructorForSingle(
  StringBuffer buffer,
  String model,
  List<String> crudMethods,
) {
  final pascalModel = toPascal(model);

  buffer.write('  ${pascalModel}Controller({');

  final params = <String>[];
  if (crudMethods.contains('get')) {
    params.add('required this.get${pascalModel}UseCase');
  }
  if (crudMethods.contains('update')) {
    params.add('required this.update${pascalModel}UseCase');
  }

  buffer.write(params.join(', '));
  buffer.writeln('});');
}

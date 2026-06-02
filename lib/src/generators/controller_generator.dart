// tool/generators/controller_generator.dart
import 'dart:io';
import '../helpers/naming_helpers.dart';

class ControllerGenerator {
  ControllerGenerator._();

  static Future<String> generateList({
    required String className,
    required String feature,
    required String projectName,
    required List<String> crudMethods,
    required Map<String, dynamic> jsonSchema,
    required String controllerPath,
  }) async {
    final file = File(controllerPath);
    String existingContent = '';
    if (file.existsSync()) {
      existingContent = await file.readAsString();
    }

    if (existingContent.isEmpty) {
      return _generateNewListController(
          className, feature, projectName, crudMethods, jsonSchema);
    }

    return _updateExistingController(existingContent, className, feature,
        projectName, crudMethods, jsonSchema,
        isList: true);
  }

  static Future<String> generateSingle({
    required String className,
    required String feature,
    required String projectName,
    required List<String> crudMethods,
    required Map<String, dynamic> jsonSchema,
    required String controllerPath,
  }) async {
    final file = File(controllerPath);
    String existingContent = '';
    if (file.existsSync()) {
      existingContent = await file.readAsString();
    }

    if (existingContent.isEmpty) {
      return _generateNewSingleController(
          className, feature, projectName, crudMethods, jsonSchema);
    }

    return _updateExistingController(existingContent, className, feature,
        projectName, crudMethods, jsonSchema,
        isList: false);
  }

  static String _generateNewListController(
      String className,
      String feature,
      String projectName,
      List<String> crudMethods,
      Map<String, dynamic> jsonSchema) {
    final pascalModel = toPascal(className);
    final snakeModel = toSnakeFromName(className);
    final pluralPascalModel = pluralize(pascalModel);
    final pluralSnakeModel = toSnakeFromName(pluralPascalModel);

    final buffer = StringBuffer();
    buffer.writeln("import 'package:get/get.dart';");
    buffer.writeln(
        "import 'package:$projectName/features/$feature/domain/entities/${snakeModel}_entity.dart';");

    final imports = _generateUseCaseImports(
        feature, className, crudMethods, projectName,
        isList: true);
    for (final imp in imports) {
      buffer.writeln(imp);
    }
    buffer.writeln();

    buffer.writeln(
        'class ${pluralPascalModel}Controller extends GetxController {');
    buffer.writeln();
    _writeConstructor(buffer, pluralPascalModel, className, crudMethods,
        isList: true);
    buffer.writeln();
    _writeUseCaseFields(buffer, className, crudMethods, isList: true);
    buffer.writeln();

    buffer.writeln('  // State');
    buffer.writeln(
        '  final RxList<${pascalModel}Entity> $pluralSnakeModel = <${pascalModel}Entity>[].obs;');
    buffer.writeln('  final RxBool isLoading = false.obs;');
    buffer.writeln('  final RxString error = \'\'.obs;');
    buffer.writeln();

    _writeOnInit(buffer, pluralPascalModel, crudMethods, isList: true);
    buffer.writeln();

    _writeMethods(buffer, className, feature, crudMethods, jsonSchema,
        isList: true);
    buffer.writeln('}');
    return buffer.toString();
  }

  static String _generateNewSingleController(
      String className,
      String feature,
      String projectName,
      List<String> crudMethods,
      Map<String, dynamic> jsonSchema) {
    final pascalModel = toPascal(className);
    final snakeModel = toSnakeFromName(className);
    final idField = identifyIdField(jsonSchema);

    final buffer = StringBuffer();
    buffer.writeln("import 'package:get/get.dart';");
    buffer.writeln(
        "import 'package:$projectName/features/$feature/domain/entities/${snakeModel}_entity.dart';");

    final imports = _generateUseCaseImports(
        feature, className, crudMethods, projectName,
        isList: false);
    for (final imp in imports) {
      buffer.writeln(imp);
    }
    buffer.writeln();

    buffer.writeln('class ${pascalModel}Controller extends GetxController {');
    buffer.writeln();
    _writeConstructor(buffer, pascalModel, className, crudMethods,
        isList: false);
    buffer.writeln();

    buffer.writeln('  // State');
    buffer.writeln('  ${pascalModel}Entity? item;');
    buffer.writeln('  String? id;');
    buffer.writeln('  final RxBool isLoading = false.obs;');
    buffer.writeln('  final RxString error = \'\'.obs;');
    buffer.writeln();

    _writeUseCaseFields(buffer, className, crudMethods, isList: false);
    buffer.writeln();

    _writeOnInit(buffer, pascalModel, crudMethods,
        isList: false, idField: idField, snakeModel: snakeModel);
    buffer.writeln();

    _writeMethods(buffer, className, feature, crudMethods, jsonSchema,
        isList: false, idField: idField);
    buffer.writeln('}');
    return buffer.toString();
  }

  static String _updateExistingController(
      String content,
      String className,
      String feature,
      String projectName,
      List<String> crudMethods,
      Map<String, dynamic> jsonSchema,
      {required bool isList}) {
    var updatedContent = content;

    // 1. Merge Imports
    final newImports = _generateUseCaseImports(
        feature, className, crudMethods, projectName,
        isList: isList);
    for (final imp in newImports) {
      if (!updatedContent.contains(imp)) {
        updatedContent = '$imp\n$updatedContent';
      }
    }

    // 2. Merge Use Case Fields
    final fieldBuffer = StringBuffer();
    _writeUseCaseFields(fieldBuffer, className, crudMethods, isList: isList);
    final newFields = fieldBuffer.toString().split('\n');
    for (final field in newFields) {
      final trimmed = field.trim();
      if (trimmed.isNotEmpty &&
          trimmed != '// Use Cases' &&
          !updatedContent.contains(trimmed)) {
        // Insert after the start of class
        final classMatch =
            RegExp(r'class\s+\w+Controller\s+extends\s+GetxController\s*\{')
                .firstMatch(updatedContent);
        if (classMatch != null) {
          updatedContent =
              '${updatedContent.substring(0, classMatch.end)}\n  $trimmed${updatedContent.substring(classMatch.end)}';
        }
      }
    }

    // 3. Update Constructor
    updatedContent = _updateConstructorInString(
        updatedContent, className, crudMethods, isList);

    // 4. Merge Methods
    final methodBuffer = StringBuffer();
    _writeMethods(methodBuffer, className, feature, crudMethods, jsonSchema,
        isList: isList);
    final newMethods = methodBuffer.toString().split('\n\n');
    for (final method in newMethods) {
      final trimmedMethod = method.trim();
      if (trimmedMethod.isEmpty) continue;

      // Check for method existence using a simpler check
      final sigMatch =
          RegExp(r'Future<void>\s+(\w+)\(').firstMatch(trimmedMethod);
      if (sigMatch != null) {
        final methodName = sigMatch.group(1);
        if (updatedContent.contains('Future<void> $methodName(')) continue;
      }

      // Append before the LAST closing brace of the class
      final lastBraceIndex = updatedContent.lastIndexOf('}');
      if (lastBraceIndex != -1) {
        updatedContent =
            '${updatedContent.substring(0, lastBraceIndex)}\n  $trimmedMethod\n${updatedContent.substring(lastBraceIndex)}';
      }
    }

    return updatedContent;
  }

  static String _updateConstructorInString(
      String content, String className, List<String> crudMethods, bool isList) {
    final pascal =
        isList ? pluralize(toPascal(className)) : toPascal(className);
    // Be more flexible with whitespaces
    final pattern =
        RegExp(pascal + r'Controller\s*\(\s*\{([\s\S]*?)\}\s*\)\s*;');

    return content.replaceFirstMapped(pattern, (match) {
      final existingParams = match.group(1) ?? '';
      final newParams = <String>[];
      final pascalModel = toPascal(className);

      if (isList) {
        if (crudMethods.contains('list')) {
          newParams
              .add('required this.${toCamel(pluralize(pascalModel))}UseCase');
        }
        if (crudMethods.contains('add')) {
          newParams.add('required this.add${pascalModel}UseCase');
        }
        if (crudMethods.contains('update')) {
          newParams.add('required this.update${pascalModel}UseCase');
        }
        if (crudMethods.contains('delete')) {
          newParams.add('required this.delete${pascalModel}UseCase');
        }
      } else {
        if (crudMethods.contains('get')) {
          newParams.add('required this.get${pascalModel}UseCase');
        }
        if (crudMethods.contains('update')) {
          newParams.add('required this.update${pascalModel}UseCase');
        }
      }

      final mergedParams = existingParams
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toSet();
      mergedParams.addAll(newParams);

      return '${pascal}Controller({${mergedParams.join(', ')}});';
    });
  }

  static List<String> _generateUseCaseImports(String feature, String model,
      List<String> crudMethods, String projectName,
      {required bool isList}) {
    final snakeModel = toSnakeFromName(model);
    final pluralSnakeModel = toSnakeFromName(pluralize(model));
    final imports = <String>[];

    if (isList) {
      if (crudMethods.contains('list')) {
        imports.add(
            "import 'package:$projectName/features/$feature/domain/usecases/${pluralSnakeModel}_usecase.dart';");
      }
      if (crudMethods.contains('add')) {
        imports.add(
            "import 'package:$projectName/features/$feature/domain/usecases/add_${snakeModel}_usecase.dart';");
      }
      if (crudMethods.contains('update')) {
        imports.add(
            "import 'package:$projectName/features/$feature/domain/usecases/update_${snakeModel}_usecase.dart';");
      }
      if (crudMethods.contains('delete')) {
        imports.add(
            "import 'package:$projectName/features/$feature/domain/usecases/delete_${snakeModel}_usecase.dart';");
      }
      imports.add("import 'package:$projectName/core/utils/utils.dart';");
    } else {
      if (crudMethods.contains('get')) {
        imports.add(
            "import 'package:$projectName/features/$feature/domain/usecases/get_${snakeModel}_usecase.dart';");
      }
      if (crudMethods.contains('update')) {
        imports.add(
            "import 'package:$projectName/features/$feature/domain/usecases/update_${snakeModel}_usecase.dart';");
      }
    }
    return imports;
  }

  static void _writeConstructor(StringBuffer buffer, String pascalClass,
      String model, List<String> crudMethods,
      {required bool isList}) {
    buffer.write('  ${pascalClass}Controller({');
    final params = <String>[];
    final pascalModel = toPascal(model);
    if (isList) {
      if (crudMethods.contains('list')) {
        params.add('required this.${toCamel(pluralize(pascalModel))}UseCase');
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
    } else {
      if (crudMethods.contains('get')) {
        params.add('required this.get${pascalModel}UseCase');
      }
      if (crudMethods.contains('update')) {
        params.add('required this.update${pascalModel}UseCase');
      }
    }
    buffer.write(params.join(', '));
    buffer.writeln('});');
  }

  static void _writeUseCaseFields(
      StringBuffer buffer, String model, List<String> crudMethods,
      {required bool isList}) {
    final pascalModel = toPascal(model);
    final pluralPascal = pluralize(pascalModel);
    if (isList) {
      if (crudMethods.contains('list')) {
        buffer.writeln(
            '  final $pluralPascal' 'UseCase ${toCamel(pluralPascal)}UseCase;');
      }
      if (crudMethods.contains('add')) {
        buffer.writeln(
            '  final Add${pascalModel}UseCase add${pascalModel}UseCase;');
      }
      if (crudMethods.contains('update')) {
        buffer.writeln(
            '  final Update${pascalModel}UseCase update${pascalModel}UseCase;');
      }
      if (crudMethods.contains('delete')) {
        buffer.writeln(
            '  final Delete${pascalModel}UseCase delete${pascalModel}UseCase;');
      }
    } else {
      if (crudMethods.contains('get')) {
        buffer.writeln(
            '  final Get${pascalModel}UseCase get${pascalModel}UseCase;');
      }
      if (crudMethods.contains('update')) {
        buffer.writeln(
            '  final Update${pascalModel}UseCase update${pascalModel}UseCase;');
      }
    }
  }

  static void _writeOnInit(
      StringBuffer buffer, String pascalClass, List<String> crudMethods,
      {required bool isList, String? idField, String? snakeModel}) {
    buffer.writeln('  @override');
    buffer.writeln('  void onInit() {');
    if (isList) {
      if (crudMethods.contains('list')) {
        buffer.writeln('    get$pascalClass();');
      }
    } else {
      buffer.writeln('    final argument = Get.arguments;');
      buffer.writeln('    final parameters = Get.parameters;');
      buffer.writeln(
          '    if (argument != null && argument is Map && argument.containsKey(\'$snakeModel\')) { item = argument[\'$snakeModel\']; }');
      buffer.writeln('    id = parameters[\'$idField\'];');
      buffer.writeln('    if (item == null && id != null && id!.isNotEmpty) {');
      if (crudMethods.contains('get')) {
        buffer.writeln('      get$pascalClass(id!);');
      }
      buffer.writeln('    }');
    }
    buffer.writeln('    super.onInit();');
    buffer.writeln('  }');
  }

  static void _writeMethods(StringBuffer buffer, String model, String feature,
      List<String> crudMethods, Map<String, dynamic> jsonSchema,
      {required bool isList, String? idField}) {
    final pascalModel = toPascal(model);
    final pluralPascal = pluralize(pascalModel);
    final pluralSnake = toSnakeFromName(pluralPascal);
    final camelPlural = toCamel(pluralPascal);
    final camelModel = toCamel(model);
    final actualIdField = idField ?? identifyIdField(jsonSchema);

    if (isList) {
      if (crudMethods.contains('list')) {
        buffer.writeln('  Future<void> get$pluralPascal() async {');
        buffer.writeln('    try { isLoading.value = true; error.value = \'\';');
        buffer.writeln('      final result = await ${camelPlural}UseCase({});');
        buffer.writeln(
            '      result.fold((failure) => error.value = failure.toString(), (data) => $pluralSnake.value = data);');
        buffer.writeln(
            '    } catch (e) { error.value = e.toString(); } finally { isLoading.value = false; }');
        buffer.writeln('  }\n');
      }
      if (crudMethods.contains('add')) {
        buffer.writeln(
            '  Future<void> add$pascalModel(${pascalModel}Entity $camelModel) async {');
        buffer.writeln('    try { isLoading.value = true; error.value = \'\';');
        buffer.writeln('      final Map<String, dynamic> ${camelModel}Map = {');
        jsonSchema.forEach((key, value) {
          buffer.writeln("        '$key': $camelModel.${toCamel(key)},");
        });
        buffer.writeln('      };');
        buffer.writeln(
            '      final result = await add${pascalModel}UseCase({\'$camelModel\': ${camelModel}Map});');
        buffer.writeln(
            '      result.fold((failure) => error.value = failure.toString(), (data) { $pluralSnake.add(data); Get.back(); Get.snackbar(\'Success\', \'$pascalModel added successfully\'); });');
        buffer.writeln(
            '    } catch (e) { error.value = e.toString(); } finally { isLoading.value = false; }');
        buffer.writeln('  }\n');
      }
      if (crudMethods.contains('delete')) {
        buffer.writeln('  Future<void> delete$pascalModel(dynamic id) async {');
        buffer.writeln('    isLoading.value = true; error.value = \'\';');
        buffer.writeln(
            '    final result = await delete${pascalModel}UseCase({\'$actualIdField\': id});');
        buffer.writeln(
            '    result.fold((failure) { isLoading.value = false; error.value = failure.message; }, (data) {');
        buffer.writeln(
            '      isLoading.value = false; $pluralSnake.removeWhere((item) => item.$actualIdField == id);');
        buffer.writeln(
            '      Utils.showMessage(message: \'$pascalModel deleted successfully\');');
        buffer.writeln('    });');
        buffer.writeln('  }\n');
      }
    } else {
      if (crudMethods.contains('get')) {
        buffer.writeln('  Future<void> get$pascalModel(String id) async {');
        buffer.writeln('    try { isLoading.value = true; error.value = \'\';');
        buffer.writeln(
            '      final result = await get${pascalModel}UseCase({\'$actualIdField\': id});');
        buffer.writeln(
            '      result.fold((failure) => error.value = failure.toString(), (data) { item = data; update(); });');
        buffer.writeln(
            '    } catch (e) { error.value = e.toString(); } finally { isLoading.value = false; }');
        buffer.writeln('  }\n');
      }
      if (crudMethods.contains('update')) {
        buffer.writeln('  Future<void> update$pascalModel() async {');
        buffer.writeln('    if (item == null) return;');
        buffer.writeln('    try { isLoading.value = true; error.value = \'\';');
        buffer.writeln('      final Map<String, dynamic> ${camelModel}Map = {');
        jsonSchema.forEach((key, value) {
          buffer.writeln("        '$key': item!.${toCamel(key)},");
        });
        buffer.writeln('      };');
        buffer.writeln(
            '      final result = await update${pascalModel}UseCase({\'$camelModel\': ${camelModel}Map});');
        buffer.writeln(
            '      result.fold((failure) => error.value = failure.toString(), (data) { item = data; update(); Get.back(); Get.snackbar(\'Success\', \'$pascalModel updated successfully\'); });');
        buffer.writeln(
            '    } catch (e) { error.value = e.toString(); } finally { isLoading.value = false; }');
        buffer.writeln('  }\n');
      }
      buffer.writeln(
          '  void updateItem(${pascalModel}Entity newItem) { item = newItem; update(); }');
    }
  }
}

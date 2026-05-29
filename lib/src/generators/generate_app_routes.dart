import 'dart:io';

import '../helpers/naming_helpers.dart';

/// محتوای جدید برای فایل app_routes.dart را تولید می‌کند
String generateAppRoutes({
  required String className,
  required String feature,
  required String projectName,
  required List<String> crudMethods,
}) {
  final pascalModel = toPascal(className);
  final snakeModel = toSnakeFromName(className);

  // مسیر فایل app_routes.dart
  const appRoutesPath = 'lib/core/routes/app_routes.dart';

  // خواندن محتوای فعلی
  final file = File(appRoutesPath);
  String existingContent = '';
  if (file.existsSync()) {
    existingContent = file.readAsStringSync();
  }

  // اگر فایل خالی بود یا وجود نداشت، ساختار اولیه را بساز
  if (existingContent.trim().isEmpty) {
    return _createNewAppRoutesFile(pascalModel, snakeModel, crudMethods);
  }

  // ویرایش فایل موجود
  return _updateExistingAppRoutesFile(
    existingContent,
    pascalModel,
    snakeModel,
    crudMethods,
  );
}

/// ساخت فایل app_routes.dart اگر از قبل وجود نداشته باشد
String _createNewAppRoutesFile(
  String pascalModel,
  String snakeModel,
  List<String> crudMethods,
) {
  final buffer = StringBuffer();

  buffer.writeln("part of 'app_pages.dart';");
  buffer.writeln();
  buffer.writeln('abstract class AppRoutes {');

  // اضافه کردن ثابت‌های پیش‌فرض (اختیاری، اما برای جلوگیری از خطا بهتر است)
  buffer.writeln("  static const unknown = '/unknown';");
  buffer.writeln();

  // اضافه کردن روت‌های جدید
  _writeRouteConstants(buffer, pascalModel, snakeModel, crudMethods);

  buffer.writeln('}');

  return buffer.toString();
}

/// آپدیت فایل موجود app_routes.dart
String _updateExistingAppRoutesFile(
  String existingContent,
  String pascalModel,
  String snakeModel,
  List<String> crudMethods,
) {
  final lines = existingContent.split('\n');
  final resultLines = <String>[];

  // پیدا کردن خطی که کلاس AppRoutes در آن بسته شده است (آکولاد بسته })
  int classEndIndex = -1;

  for (int i = lines.length - 1; i >= 0; i--) {
    if (lines[i].trim() == '}' && !lines[i].contains('//')) {
      // بررسی ساده: آخرین آکولاد بسته که کامنت نیست را به عنوان پایان کلاس در نظر می‌گیریم
      // (فرض بر این است که ساختار فایل استاندارد است)
      classEndIndex = i;
      break;
    }
  }

  if (classEndIndex == -1) {
    // اگر ساختار فایل خراب بود، محتوا را دست نزن
    return existingContent;
  }

  // کپی کردن خطوط تا قبل از پایان کلاس
  for (int i = 0; i < classEndIndex; i++) {
    resultLines.add(lines[i]);
  }

  // لیست ثابت‌هایی که باید اضافه شوند
  final newConstants = _getNewRouteConstants(
    existingContent,
    pascalModel,
    snakeModel,
    crudMethods,
  );

  // اضافه کردن ثابت‌های جدید قبل از آکولاد بسته
  if (newConstants.isNotEmpty) {
    // اگر خط قبلی خالی نیست، یک خط فاصله بیندازیم
    if (resultLines.isNotEmpty && resultLines.last.trim().isNotEmpty) {
      resultLines.add('');
    }

    // اضافه کردن کامنت برای تفکیک فیچر (اختیاری)
    resultLines.add('  //// $pascalModel');

    resultLines.addAll(newConstants);
  }

  // اضافه کردن آکولاد بسته
  resultLines.add(lines[classEndIndex]);

  return resultLines.join('\n');
}

/// تولید لیست ثابت‌های جدید بر اساس متدهای CRUD
List<String> _getNewRouteConstants(
  String existingContent,
  String pascalModel,
  String snakeModel,
  List<String> crudMethods,
) {
  final newConstants = <String>[];

  // الگوی نام‌گذاری: static const name = '/value';

  // 1. List Route (مثال: /products)
  final listConstName = '${snakeModel}s'; // مثلا products
  final listConstValue = '/${snakeModel}s';
  if (!existingContent.contains('static const $listConstName =')) {
    newConstants.add("  static const $listConstName = '$listConstValue';");
  }

  // 2. Get Route (مثال: /product)
  final constName = snakeModel; // مثلا products
  final constValue = '/$snakeModel';
  if (!existingContent.contains('static const $constName =')) {
    newConstants.add("  static const $constName = '$constValue';");
  }

  // 3. Add Route (مثال: /add-product)
  if (crudMethods.contains('add')) {
    final addConstName = '${snakeModel}Add'; // مثلا addProduct
    final addConstValue = '/$snakeModel/add'; // مثلا /add-product
    if (!existingContent.contains('static const $addConstName =')) {
      newConstants.add("  static const $addConstName = '$addConstValue';");
    }
  }

  // 4. Edit Route (مثال: /edit-product)
  if (crudMethods.contains('update')) {
    final editConstName = '${snakeModel}Edit'; // مثلا editProduct
    final editConstValue = '/$snakeModel/edit'; // مثلا /edit-product
    if (!existingContent.contains('static const $editConstName =')) {
      newConstants.add("  static const $editConstName = '$editConstValue';");
    }
  }

  return newConstants;
}

/// نوشتن ثابت‌ها در بافر (برای فایل جدید)
void _writeRouteConstants(
  StringBuffer buffer,
  String pascalModel,
  String snakeModel,
  List<String> crudMethods,
) {
  buffer.writeln('  //// $pascalModel');

  // List
  buffer.writeln("  static const ${snakeModel}s = '/${snakeModel}s';");

  // Get
  buffer.writeln("  static const $snakeModel = '/$snakeModel';");

  // Add
  if (crudMethods.contains('add')) {
    buffer.writeln("  static const ${snakeModel}Add = '/$snakeModel/add';");
  }

  // Edit
  if (crudMethods.contains('update')) {
    buffer.writeln("  static const ${snakeModel}Edit = '/$snakeModel/edit';");
  }
}

import 'package:test/test.dart';
import 'package:fast_clean_generator/src/generators/bindings_generator.dart';
import 'dart:io';

void main() {
  group('BindingGenerator Tests', () {
    const projectName = 'test_project';
    const feature = 'booking';
    const model = 'Task';
    late Directory tempDir;
    late String bindingPath;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('binding_test_');
      bindingPath = '${tempDir.path}/test_binding.dart';
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('generate should create a new binding file content', () async {
      final crudMethods = ['list', 'get'];
      final result = await BindingGenerator.generate(
        projectName: projectName,
        feature: feature,
        model: model,
        newCrudMethods: crudMethods,
        bindingFilePath: bindingPath,
      );

      expect(result, contains('class BookingBinding extends Bindings'));
      expect(result, contains('Get.lazyPut(() => BookingRemoteDataImp());'));
      expect(
          result,
          contains(
              'Get.lazyPut(() => TasksUseCase(repository: Get.find<BookingRepositoryImpl>()),);'));
      expect(
          result,
          contains(
              'Get.lazyPut(() => GetTaskUseCase(repository: Get.find<BookingRepositoryImpl>()),);'));

      // Check for both Plural and Singular Controllers
      expect(result, contains('Get.lazyPut(() => TasksController('));
      expect(result, contains('Get.lazyPut(() => TaskController('));
      expect(
          result,
          contains(
              "import 'package:test_project/features/booking/presentation/controllers/tasks_controller.dart';"));
      expect(
          result,
          contains(
              "import 'package:test_project/features/booking/presentation/controllers/task_controller.dart';"));
    });

    test('generate should merge with existing methods in file', () async {
      final file = File(bindingPath);
      file.writeAsStringSync('''
import 'package:get/get.dart';
class BookingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => GetTaskUseCase(repository: Get.find<BookingRepositoryImpl>()),);
  }
}
''');

      final crudMethods = ['list'];
      final result = await BindingGenerator.generate(
        projectName: projectName,
        feature: feature,
        model: model,
        newCrudMethods: crudMethods,
        bindingFilePath: bindingPath,
      );

      // Should contain both Get (existing) and List (new)
      expect(result, contains('GetTaskUseCase'));
      expect(result, contains('TasksUseCase'));
    });
  });
}

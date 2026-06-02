import 'dart:io';
import 'package:test/test.dart';
import 'package:fast_clean_generator/src/generators/remote_data_generator.dart';
import 'package:fast_clean_generator/src/generators/repository_generator.dart';
import 'package:fast_clean_generator/src/generators/repository_impl_generator.dart';
import 'package:fast_clean_generator/src/generators/app_pages_generator.dart';
import 'package:fast_clean_generator/src/generate_code.dart';
import 'package:fast_clean_generator/src/models/generate_options.dart';

void main() {
  group('Integration Generator Tests (File system dependent)', () {
    const projectName = 'test_project';
    const feature = 'booking';
    const className = 'Task';
    late Directory tempDir;
    late String originalCwd;

    setUp(() {
      originalCwd = Directory.current.path;
      tempDir = Directory.systemTemp.createTempSync('integration_test_');
      Directory.current = tempDir;

      // Create a dummy pubspec.yaml
      File('pubspec.yaml').writeAsStringSync('name: test_project');
      // Create required structure for some generators
      Directory('lib/core/routes').createSync(recursive: true);
      Directory('lib/core/utils').createSync(recursive: true);
      Directory('lib/core/data/network').createSync(recursive: true);
      Directory('lib/core/helpers').createSync(recursive: true);
      Directory('lib/core/use_case').createSync(recursive: true);
      Directory('lib/core/exceptions').createSync(recursive: true);
      Directory('lib/core/widgets').createSync(recursive: true);
    });

    tearDown(() {
      Directory.current = originalCwd;
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('generateRemoteData creates file and adds methods', () async {
      await generateRemoteData(
        projectName: projectName,
        feature: feature,
        className: className,
        crudMethods: ['get', 'list'],
      );

      final file = File(
          'lib/features/booking/data/data_sources/booking_remote_data.dart');
      expect(file.existsSync(), isTrue);

      final content = file.readAsStringSync();
      expect(content, contains('abstract class BookingRemoteData'));
      expect(content,
          contains('Future<TaskModel> getTask(Map<String, dynamic> params);'));
    });

    test('upsertRepository creates interface and adds methods', () async {
      await upsertRepository(
        projectName: projectName,
        feature: feature,
        className: className,
        crudMethods: ['add', 'delete'],
      );

      final file = File(
          'lib/features/booking/domain/repositories/booking_repository.dart');
      expect(file.existsSync(), isTrue);

      final content = file.readAsStringSync();
      expect(content, contains('abstract class BookingRepository'));
    });

    test('generateRepositoryImpl creates implementation and adds methods',
        () async {
      await generateRepositoryImpl(
        projectName: projectName,
        feature: feature,
        className: className,
        crudMethods: ['update'],
      );

      final file = File(
          'lib/features/booking/data/repositories/booking_repository_impl.dart');
      expect(file.existsSync(), isTrue);
    });

    test('generateFeatureAppPages creates and updates app_pages.dart', () {
      final appPagesPath = 'lib/core/routes/app_pages.dart';

      // 1. Create new
      final result1 = generateFeatureAppPages(
        feature: feature,
        projectName: projectName,
        routesFilePath: 'dummy.dart',
      );
      expect(result1, contains('class AppPages {'));
      expect(result1, contains('...bookingRoutes,'));

      File(appPagesPath).writeAsStringSync(result1);

      // 2. Update existing
      final result2 = generateFeatureAppPages(
        feature: 'auth',
        projectName: projectName,
        routesFilePath: 'dummy.dart',
      );
      expect(result2, contains('...bookingRoutes,'));
      expect(result2, contains('...authRoutes,'));
    });

    test('Incremental Generation: Add multiple classes to same feature',
        () async {
      final engine = GeneratorEngine();
      final options = GenerateOptions();

      // 1. Generate Cart in order feature
      await engine.generate(
        jsonOrPath: '{"id": 1, "total": 10.0}',
        rootClass: 'Cart',
        feature: 'order',
        crudMethods: ['list', 'get'],
        options: options,
      );

      // 2. Generate Payment in SAME order feature
      await engine.generate(
        jsonOrPath: '{"id": 1, "amount": 20.0}',
        rootClass: 'Payment',
        feature: 'order',
        crudMethods: ['list', 'add'],
        options: options,
      );

      // Verify Entity files
      expect(
          File('lib/features/order/domain/entities/cart_entity.dart')
              .existsSync(),
          isTrue);
      expect(
          File('lib/features/order/domain/entities/payment_entity.dart')
              .existsSync(),
          isTrue);

      // Verify Binding merge
      final bindingContent =
          File('lib/features/order/presentation/bindings/order_binding.dart')
              .readAsStringSync();
      expect(bindingContent, contains('CartsUseCase'));
      expect(bindingContent, contains('PaymentsUseCase'));

      // Verify Routes merge
      final routesContent = File('lib/features/order/routes/order_routes.dart')
          .readAsStringSync();
      expect(routesContent, contains('AppRoutes.carts'));
      expect(routesContent, contains('AppRoutes.payments'));

      // Verify Core AppPages merge
      final appPagesContent =
          File('lib/core/routes/app_pages.dart').readAsStringSync();
      expect(appPagesContent, contains('...orderRoutes'));

      // 3. Add a different feature
      await engine.generate(
        jsonOrPath: '{"id": 1}',
        rootClass: 'User',
        feature: 'auth',
        crudMethods: ['get'],
        options: options,
      );

      final finalAppPagesContent =
          File('lib/core/routes/app_pages.dart').readAsStringSync();
      expect(finalAppPagesContent, contains('...orderRoutes'));
      expect(finalAppPagesContent, contains('...authRoutes'));
    });

    test('Incremental CRUD: Verify all layers keep old methods', () async {
      final engine = GeneratorEngine();
      final options = GenerateOptions();
      const feature = 'order';
      const className = 'Cart';

      // 1. First run: Only 'list'
      await engine.generate(
        jsonOrPath: '{"id": 1, "total": 10.0}',
        rootClass: className,
        feature: feature,
        crudMethods: ['list'],
        options: options,
      );

      final repoPath =
          'lib/features/order/domain/repositories/order_repository.dart';
      final repoImplPath =
          'lib/features/order/data/repositories/order_repository_impl.dart';
      final remoteDataPath =
          'lib/features/order/data/data_sources/order_remote_data.dart';

      expect(File(repoPath).readAsStringSync(), contains('getCarts'));
      expect(File(repoImplPath).readAsStringSync(), contains('getCarts'));
      expect(File(remoteDataPath).readAsStringSync(), contains('getCarts'));

      // 2. Second run: Add 'get' method
      await engine.generate(
        jsonOrPath: '{"id": 1, "total": 10.0}',
        rootClass: className,
        feature: feature,
        crudMethods: ['get'],
        options: options,
      );

      final updatedRepo = File(repoPath).readAsStringSync();
      final updatedRepoImpl = File(repoImplPath).readAsStringSync();
      final updatedRemoteData = File(remoteDataPath).readAsStringSync();

      // Verify BOTH methods exist in all layers
      expect(updatedRepo, contains('getCarts'),
          reason: 'Repository should keep getCarts');
      expect(updatedRepo, contains('getCart'),
          reason: 'Repository should add getCart');

      expect(updatedRepoImpl, contains('getCarts'),
          reason: 'RepositoryImpl should keep getCarts');
      expect(updatedRepoImpl, contains('getCart'),
          reason: 'RepositoryImpl should add getCart');

      expect(updatedRemoteData, contains('getCarts'),
          reason: 'RemoteData should keep getCarts');
      expect(updatedRemoteData, contains('getCart'),
          reason: 'RemoteData should add getCart');
    });

    test('Incremental CRUD: Adding "add" method to an existing "list" feature',
        () async {
      final engine = GeneratorEngine();
      final options = GenerateOptions();

      // 1. First run: Only 'list'
      await engine.generate(
        jsonOrPath: '{"id": 1, "name": "Task"}',
        rootClass: 'Task',
        feature: 'todo',
        crudMethods: ['list'],
        options: options,
      );

      final controllerPath =
          'lib/features/todo/presentation/controllers/tasks_controller.dart';
      final initialContent = File(controllerPath).readAsStringSync();
      expect(initialContent, contains('Future<void> getTasks()'));
      expect(initialContent, isNot(contains('Future<void> addTask')));

      // 2. Second run: Add 'add' method
      await engine.generate(
        jsonOrPath: '{"id": 1, "name": "Task"}',
        rootClass: 'Task',
        feature: 'todo',
        crudMethods: ['add'],
        options: options,
      );

      final updatedContent = File(controllerPath).readAsStringSync();

      // CRITICAL CHECK: Does it have BOTH methods?
      expect(updatedContent, contains('Future<void> getTasks()'),
          reason: 'Should NOT delete existing list method');
      expect(updatedContent, contains('Future<void> addTask'),
          reason: 'Should ADD the new add method');
    });
  });
}

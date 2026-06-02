import 'dart:io';
import 'package:test/test.dart';
import 'package:fast_clean_generator/src/generate_code.dart';
import 'package:fast_clean_generator/src/models/generate_options.dart';

void main() {
  group('Incremental Generation Tests', () {
    late Directory tempDir;
    late String originalCwd;
    const projectName = 'test_project';

    setUp(() {
      originalCwd = Directory.current.path;
      tempDir = Directory.systemTemp.createTempSync('incremental_test_');
      Directory.current = tempDir;

      // Setup basic project structure
      File('pubspec.yaml').writeAsStringSync('name: $projectName');
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

    test('Add a second class to an existing feature', () async {
      final engine = GeneratorEngine();
      final options = GenerateOptions();

      // 1. Generate first class: Cart
      const cartJson = '{"id": 1, "total": 100.0}';
      await engine.generate(
        jsonOrPath: cartJson,
        rootClass: 'Cart',
        feature: 'order',
        crudMethods: ['list', 'get'],
        options: options,
      );

      // Verify Cart exists
      expect(File('lib/features/order/domain/entities/cart_entity.dart').existsSync(), isTrue);
      expect(File('lib/features/order/presentation/bindings/order_binding.dart').existsSync(), isTrue);

      // 2. Generate second class: Payment in the SAME feature
      const paymentJson = '{"id": 1, "amount": 100.0, "status": "pending"}';
      await engine.generate(
        jsonOrPath: paymentJson,
        rootClass: 'Payment',
        feature: 'order',
        crudMethods: ['list', 'add'],
        options: options,
      );

      // Verify both Entities exist
      expect(File('lib/features/order/domain/entities/cart_entity.dart').existsSync(), isTrue, reason: 'CartEntity should persist');
      expect(File('lib/features/order/domain/entities/payment_entity.dart').existsSync(), isTrue, reason: 'PaymentEntity should be created');

      // Verify Binding contains BOTH (This is where logic often fails)
      final bindingContent = File('lib/features/order/presentation/bindings/order_binding.dart').readAsStringSync();
      
      // Checking for Cart injections
      expect(bindingContent, contains('CartsUseCase'), reason: 'Binding should still contain Cart usecases');
      expect(bindingContent, contains('CartsController'), reason: 'Binding should still contain Cart controller');
      
      // Checking for Payment injections
      expect(bindingContent, contains('PaymentsUseCase'), reason: 'Binding should now contain Payment usecases');
      expect(bindingContent, contains('PaymentsController'), reason: 'Binding should now contain Payment controller');

      // Verify Routes contain BOTH
      final routesContent = File('lib/features/order/routes/order_routes.dart').readAsStringSync();
      expect(routesContent, contains('AppRoutes.carts'), reason: 'Routes should still contain carts');
      expect(routesContent, contains('AppRoutes.payments'), reason: 'Routes should now contain payments');
    });
  });
}

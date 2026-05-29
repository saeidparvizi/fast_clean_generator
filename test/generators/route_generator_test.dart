import 'package:test/test.dart';
import 'package:fast_clean_generator/src/generators/route_generator.dart';
import 'dart:io';

void main() {
  group('RouteGenerator Tests', () {
    const projectName = 'test_project';
    const feature = 'booking';
    const className = 'Task';
    const routesFilePath = 'test_routes.dart';

    tearDown(() {
      final file = File(routesFilePath);
      if (file.existsSync()) {
        file.deleteSync();
      }
    });

    test('generateFeatureRoutes creates a new routes file', () {
      final result = generateFeatureRoutes(
        className: className,
        feature: feature,
        projectName: projectName,
        crudMethods: ['list', 'add'],
        routesFilePath: routesFilePath,
      );

      expect(result, contains('List<GetPage> bookingRoutes = ['));
      expect(result, contains('AppRoutes.tasks'));
      expect(result, contains('AppRoutes.taskAdd'));
      expect(
          result,
          contains(
              "import 'package:test_project/features/booking/presentation/pages/tasks_screen.dart';"));
    });

    test('generateFeatureRoutes appends to existing routes file', () {
      final file = File(routesFilePath);
      file.writeAsStringSync('''
import 'package:get/get.dart';
List<GetPage> bookingRoutes = [
  GetPage(name: '/existing', page: () => Container()),
];
''');

      final result = generateFeatureRoutes(
        className: className,
        feature: feature,
        projectName: projectName,
        crudMethods: ['list'],
        routesFilePath: routesFilePath,
      );

      expect(result, contains("GetPage(name: '/existing'"));
      expect(result, contains('AppRoutes.tasks'));
    });
  });
}

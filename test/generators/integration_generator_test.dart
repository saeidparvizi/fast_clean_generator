import 'dart:io';
import 'package:test/test.dart';
import 'package:fast_clean_generator/src/generators/remote_data_generator.dart';
import 'package:fast_clean_generator/src/generators/repository_generator.dart';
import 'package:fast_clean_generator/src/generators/repository_impl_generator.dart';
import 'package:fast_clean_generator/src/generators/app_pages_generator.dart';

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
  });
}

import 'dart:io';
import 'package:args/command_runner.dart';
import '../helpers/file_helpers.dart';
import '../helpers/project_helpers.dart';
import '../helpers/terminal_style.dart';
import '../generators/core_generators.dart';

class InitProjectCommand extends Command {
  @override
  String get name => 'init';

  @override
  String get description =>
      'Initializes a new Flutter project with Clean Architecture structure and core files.';

  InitProjectCommand() {
    argParser.addOption(
      'http',
      abbr: 'n',
      help: 'Choose the networking library to use.',
      allowed: ['get', 'dio'],
      defaultsTo: 'get',
    );
  }

  @override
  Future<void> run() async {
    print(
        TerminalStyle.bold('🚀 Initializing Clean Architecture Structure...'));

    final projectName = detectProjectName();
    print(TerminalStyle.info('Project Name: $projectName'));

    final httpLibrary = argResults?['http'] as String? ?? 'get';
    print(
        TerminalStyle.info('Networking Library: ${httpLibrary.toUpperCase()}'));

    // 1. Create Core Directories
    _createDirectories();

    // 2. Create Core Files
    await _createCoreFiles(httpLibrary);

    // 3. Update pubspec.yaml dependencies
    await _updatePubspec(httpLibrary);

    print(TerminalStyle.success('\n✅ Project initialized successfully!'));
    print(TerminalStyle.info('Run "flutter pub get" to install dependencies.'));
    print(TerminalStyle.info(
        'Then you can start generating features using "fcg generate"'));
  }

  void _createDirectories() {
    final dirs = [
      'lib/core/data/network',
      'lib/core/exceptions',
      'lib/core/helpers',
      'lib/core/routes',
      'lib/core/use_case',
      'lib/core/utils',
      'lib/core/widgets',
      'lib/core/theme',
      'lib/core/translations',
      'lib/features',
    ];

    print(TerminalStyle.info('\n📂 Creating Directories...'));
    for (final dir in dirs) {
      Directory(dir).createSync(recursive: true);
      print('  ✓ Created: $dir');
    }
  }

  Future<void> _createCoreFiles(String httpLibrary) async {
    print(TerminalStyle.info('\n📄 Generating Core Files...'));

    final files = {
      'lib/core/exceptions/failure.dart': CoreGenerator.generateFailure(),
      'lib/core/exceptions/server_exception.dart':
          CoreGenerator.generateServerException(),
      'lib/core/use_case/use_case.dart': CoreGenerator.generateUseCase(),
      'lib/core/utils/repository_executor.dart':
          CoreGenerator.generateRepositoryExecutor(),
      'lib/core/utils/utils.dart': CoreGenerator.generateUtils(),
      'lib/core/data/network/api_provider.dart': httpLibrary == 'dio'
          ? CoreGenerator.generateDioProvider()
          : CoreGenerator.generateApiProvider(),
      'lib/core/helpers/api_helper.dart': httpLibrary == 'dio'
          ? CoreGenerator.generateDioHelper()
          : CoreGenerator.generateApiHelper(),
      'lib/core/routes/app_routes.dart':
          CoreGenerator.generateInitialAppRoutes(),
      'lib/core/routes/app_pages.dart': CoreGenerator.generateInitialAppPages(),
      'lib/core/widgets/input.dart': CoreGenerator.generateAppInput(),
      'lib/core/widgets/appbar.dart': CoreGenerator.generateAppAppbar(),
      'lib/core/theme/app_colors.dart': CoreGenerator.generateAppColors(),
      'lib/core/theme/app_theme.dart': CoreGenerator.generateAppTheme(),
      'lib/core/translations/app_translations.dart':
          CoreGenerator.generateAppTranslations(),
      'lib/core/translations/en_us.dart': CoreGenerator.generateEnUs(),
    };

    for (final entry in files.entries) {
      final file = File(entry.key);
      if (file.existsSync()) {
        print(TerminalStyle.warning(
            '  ⚠ Skipped (Already exists): ${entry.key}'));
        continue;
      }
      await writeFile(entry.key, entry.value);
      print(TerminalStyle.success('  ✓ Generated: ${entry.key}'));
    }

    // Special handling for main.dart (we want to overwrite the default Flutter main.dart)
    final mainDartPath = 'lib/main.dart';
    await writeFile(mainDartPath, CoreGenerator.generateMainDart());
    print(TerminalStyle.success(
        '  ✓ Updated: $mainDartPath (Set up GetMaterialApp)'));
  }

  Future<void> _updatePubspec(String httpLibrary) async {
    print(TerminalStyle.info('\n📦 Updating pubspec.yaml dependencies...'));

    final file = File('pubspec.yaml');
    if (!file.existsSync()) {
      print(TerminalStyle.error('✕ pubspec.yaml not found!'));
      return;
    }

    final lines = await file.readAsLines();
    final dependenciesToAdd = {
      'get': '^4.6.6',
      'dartz': '^0.10.1',
      'equatable': '^2.0.5',
      if (httpLibrary == 'dio') 'dio': '^5.4.1',
    };

    int dependenciesLineIndex = -1;
    final existingDeps = <String>{};

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line == 'dependencies:') {
        dependenciesLineIndex = i;
      }
      // Simple check to see if dependency already exists
      for (final dep in dependenciesToAdd.keys) {
        if (line.startsWith('$dep:')) {
          existingDeps.add(dep);
        }
      }
    }

    if (dependenciesLineIndex == -1) {
      lines.add('dependencies:');
      dependenciesLineIndex = lines.length - 1;
    }

    bool changed = false;
    int insertOffset = 1;
    for (final entry in dependenciesToAdd.entries) {
      if (!existingDeps.contains(entry.key)) {
        lines.insert(dependenciesLineIndex + insertOffset,
            '  ${entry.key}: ${entry.value}');
        print('  + Added dependency: ${entry.key}');
        changed = true;
        insertOffset++;
      }
    }

    if (changed) {
      await file.writeAsString(lines.join('\n'));
      print(TerminalStyle.success('  ✓ pubspec.yaml updated.'));
    } else {
      print('  ℹ️ Dependencies already exist.');
    }
  }
}

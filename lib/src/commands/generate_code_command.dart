// lib/src/generate_code_command.dart

import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:fast_clean_generator/src/generate_code.dart';
import 'package:fast_clean_generator/src/models/generate_options.dart';
import 'package:fast_clean_generator/src/exceptions/generator_exception.dart';
import '../helpers/naming_helpers.dart';
import '../helpers/terminal_style.dart';

class GenerateCodeCommand extends Command {
  @override
  String get name => 'generate';

  @override
  String get description =>
      'Generates Flutter code based on a JSON schema with interactive prompts.';

  GenerateCodeCommand() {
    argParser.addOption(
      'json',
      abbr: 'j',
      help: 'The JSON file path or JSON string.',
    );
    argParser.addOption(
      'feature',
      abbr: 'f',
      help: 'The feature name (camelCase, e.g., booking).',
    );
    argParser.addOption(
      'class',
      abbr: 'c',
      help: 'The root class name (PascalCase, e.g., Payment).',
    );
    argParser.addOption(
      'crud',
      abbr: 'm',
      help: 'Comma separated CRUD methods (e.g., list,get,add).',
    );
    argParser.addOption(
      'components',
      abbr: 'o',
      help: 'Comma separated components or "all".',
    );
    argParser.addFlag(
      'headless',
      help: 'Run without interactive prompts.',
      negatable: false,
    );
  }

  @override
  Future<void> run() async {
    final isHeadless = argResults?['headless'] as bool? ?? false;

    if (!isHeadless) {
      print(TerminalStyle.bold(
          r'  _____           _     _____ _                       '));
      print(TerminalStyle.bold(
          r' |  ___|         | |   /  __ \ |                      '));
      print(TerminalStyle.bold(
          r' | |__  __ _ ___| |_  | /  \/ | ___  __ _ _ __       '));
      print(TerminalStyle.bold(
          r' |  __|/ _` / __| __| | |   | |/ _ \/ _` | ' "'" r'_ \      '));
      print(TerminalStyle.bold(
          r' | |  | (_| \__ \ |_  | \__/\ |  __/ (_| | | | |     '));
      print(TerminalStyle.bold(
          r' |_|   \__,_|___/\__|  \____/_|\___|\__,_|_| |_|     '));
      print('');
      print(TerminalStyle.bold(
          '   F A S T   C L E A N   G E N E R A T O R  [V1.2.6]'));
      print('');
    }

    // 1. JSON Schema
    String? jsonOrPath = argResults?['json'] as String?;

    // In some shell environments, quotes might be preserved, let's clean them
    if (jsonOrPath != null &&
        jsonOrPath.startsWith("'") &&
        jsonOrPath.endsWith("'")) {
      jsonOrPath = jsonOrPath.substring(1, jsonOrPath.length - 1);
    }

    if (jsonOrPath == null || jsonOrPath.isEmpty) {
      if (isHeadless) {
        // Default to schema.json in headless mode instead of throwing error
        jsonOrPath = 'tool/schema.json';
      } else {
        jsonOrPath = await _promptInput(
          'Enter the JSON file path or JSON string',
          required: false,
          defaultValue: 'tool/schema.json',
        );
      }
    }

    // 2. Feature Name
    String? featureName = argResults?['feature'] as String?;
    if (featureName == null || featureName.isEmpty) {
      if (isHeadless) {
        throw GenerationException(
            'Missing required --feature argument in headless mode.');
      }
      featureName = await _promptInput(
        'Enter the feature name (camelCase, e.g., booking)',
        validator: (v) => v.isNotEmpty && v == toCamel(v),
        errorMessage: 'Invalid camelCase format. Example: booking',
        required: true,
      );
    }

    // 3. Root Class
    String? rootClass = argResults?['class'] as String?;
    if (rootClass == null || rootClass.isEmpty) {
      if (isHeadless) {
        throw GenerationException(
            'Missing required --class argument in headless mode.');
      }
      rootClass = await _promptInput(
        'Enter the root class name (PascalCase, e.g., Payment)',
        validator: (v) => v.isNotEmpty && v == toPascal(v),
        errorMessage: 'Invalid PascalCase format. Example: Payment',
        required: true,
      );
    }

    // 4. CRUD Methods
    List<String> crudMethods;
    final crudArg = argResults?['crud'] as String?;
    if (crudArg != null && crudArg.isNotEmpty) {
      crudMethods =
          crudArg.split(',').map((e) => e.trim().toLowerCase()).toList();
    } else {
      if (isHeadless) {
        crudMethods = ['list', 'get', 'add', 'update', 'delete'];
      } else {
        crudMethods = await _promptCrudMethods();
      }
    }

    // 5. Components Options
    GenerateOptions options;
    final componentsArg = argResults?['components'] as String?;
    if (componentsArg != null && componentsArg.isNotEmpty) {
      final comps =
          componentsArg.split(',').map((e) => e.trim().toLowerCase()).toSet();
      final all = comps.contains('all');
      options = GenerateOptions(
        crudMethods: crudMethods,
        generateEntity: all || comps.contains('entity'),
        generateModel: all || comps.contains('model'),
        generateUseCases:
            all || comps.contains('usecase') || comps.contains('usecases'),
        generateRepository: all || comps.contains('repository'),
        generateBindings:
            all || comps.contains('binding') || comps.contains('bindings'),
        generateRemoteData:
            all || comps.contains('remotedata') || comps.contains('data'),
        generateController: all || comps.contains('controller'),
        generatePage: all || comps.contains('page'),
        generateForm: all || comps.contains('form'),
        generateRoute: all || comps.contains('route'),
      );
    } else {
      if (isHeadless) {
        options = GenerateOptions(crudMethods: crudMethods); // Default all true
      } else {
        options = _promptGenerationOptions();
      }
    }

    print(TerminalStyle.info('⏳ Starting code generation...'));

    try {
      final engine = GeneratorEngine();
      await engine.generate(
        jsonOrPath: jsonOrPath,
        rootClass: rootClass,
        feature: featureName,
        crudMethods: crudMethods,
        options: options,
      );

      print(TerminalStyle.success('\n🎉 Code generated successfully!'));
    } on GeneratorException catch (e) {
      print(TerminalStyle.error('\n💥 Generation failed: ${e.message}'));
      if (e.details != null) {
        print(TerminalStyle.warning('Details: ${e.details}'));
      }
    } catch (e) {
      print(TerminalStyle.error('\n💥 Unexpected error: $e'));
    }
  }

  // ──────────────────────────────────────
  // Prompt for general input
  // ──────────────────────────────────────
  Future<String> _promptInput(
    String prompt, {
    bool required = false,
    String? defaultValue,
    String? errorMessage,
    bool Function(String)? validator,
  }) async {
    while (true) {
      final defaultText = defaultValue != null
          ? TerminalStyle.info(' (default: $defaultValue)')
          : '';

      stdout.write('${TerminalStyle.bold('?')} $prompt$defaultText: ');
      String? input = stdin.readLineSync();

      if (input == null || input.isEmpty) {
        if (defaultValue != null) {
          print(TerminalStyle.info('✓ Using default value: $defaultValue'));
          return defaultValue;
        }
        if (required) {
          print(TerminalStyle.error('✕ This field is required.'));
          continue;
        }
        return '';
      }

      // Handle multiline JSON paste
      if (input.trim().startsWith('{') && !input.trim().endsWith('}')) {
        String fullInput = input;
        int balance = _countBraces(input);
        while (balance > 0) {
          final String? nextLine = stdin.readLineSync();
          if (nextLine == null) break;
          fullInput += '\n$nextLine';
          balance += _countBraces(nextLine);
        }
        input = fullInput;
      }

      if (validator != null && !validator(input)) {
        print(TerminalStyle.error('✕ $errorMessage'));
        continue;
      }

      return input;
    }
  }

  int _countBraces(String s) {
    int count = 0;
    for (int i = 0; i < s.length; i++) {
      if (s[i] == '{') count++;
      if (s[i] == '}') count--;
    }
    return count;
  }

  // ──────────────────────────────────────
  // Prompt for CRUD methods
  // ──────────────────────────────────────
  Future<List<String>> _promptCrudMethods() async {
    const crudMethods = ['list', 'get', 'add', 'update', 'delete'];
    const crudOptions = {
      '1': 'list',
      '2': 'get',
      '3': 'add',
      '4': 'update',
      '5': 'delete',
      '0': 'all'
    };

    print(
      TerminalStyle.bold('\n🛠️  Select CRUD Methods:'),
    );
    print('Choose operations to implement (comma separated, e.g., 1,2,3)');

    for (final entry in crudOptions.entries) {
      if (entry.key != '0') {
        print(
            '  ${TerminalStyle.info('[${entry.key}]')} ${entry.value[0].toUpperCase()}${entry.value.substring(1)}');
      }
    }
    print('  ${TerminalStyle.info('[0]')} All (Default)');
    print('  ${TerminalStyle.info('[q]')} Quit');

    while (true) {
      stdout.write('  ${TerminalStyle.bold('?')} Selection: ');
      final input = stdin.readLineSync()?.trim() ?? '';

      if (input.toLowerCase() == 'q') {
        throw Exception('Operation cancelled by user');
      }

      if (input.isEmpty || input == '0') {
        print('${TerminalStyle.success('✓')} Selected all CRUD methods');
        return List.from(crudMethods);
      }

      final selectedNumbers = input.split(',');
      final invalidInputs = <String>[];
      final validNumbers = <String>[];

      for (final number in selectedNumbers) {
        final trimmed = number.trim();
        if (trimmed.isNotEmpty) {
          if (crudOptions.containsKey(trimmed)) {
            if (trimmed != '0') validNumbers.add(trimmed);
          } else {
            invalidInputs.add(trimmed);
          }
        }
      }

      if (invalidInputs.isNotEmpty) {
        print(
          TerminalStyle.error(
            'Invalid input: ${invalidInputs.join(', ')}\n'
            'Please enter numbers between 0-5 separated by commas.',
          ),
        );
        continue;
      }

      if (validNumbers.isEmpty) {
        print(TerminalStyle.warning(
            'No valid methods selected. Using default (All).'));
        return List.from(crudMethods);
      }

      final uniqueNumbers = validNumbers.toSet().toList()..sort();
      final selectedMethods =
          uniqueNumbers.map((n) => crudOptions[n]!).toList();

      final methodNames = selectedMethods
          .map((m) => m[0].toUpperCase() + m.substring(1))
          .join(', ');
      print('${TerminalStyle.success('✓')} Selected: $methodNames');

      return selectedMethods;
    }
  }

  // ──────────────────────────────────────
  // Prompt for generation options
  // ──────────────────────────────────────
  GenerateOptions _promptGenerationOptions() {
    print(TerminalStyle.bold('\n⚙️  Generation Components:'));
    print('Select which components to generate (y: Yes, n: Skip, a: All)');
    print('─────────────────────────────────────');

    final optionsMap = <String, bool>{
      'Entity': true,
      'Model': true,
      'Use Cases': true,
      'Repository': true,
      'Bindings': true,
      'Remote Data': true,
      'Controller': true,
      'Page': true,
      'Form': true,
      'Route': true,
    };

    bool generateAll = false;

    for (final entry in optionsMap.entries) {
      final key = entry.key;
      stdout.write(
          '  ${TerminalStyle.bold('?')} Generate ${TerminalStyle.info(key)}? [Y/n/a] ');

      final answer = stdin.readLineSync()?.toLowerCase().trim();

      if (answer == 'a' || answer == 'all') {
        generateAll = true;
        print(
            '    ${TerminalStyle.success('✓')} Generating all remaining components.');
        break;
      } else if (answer == 'n' || answer == 'no') {
        optionsMap[key] = false;
        print('    ${TerminalStyle.warning('✕')} Skipped');
      } else {
        optionsMap[key] = true;
        print('    ${TerminalStyle.success('✓')} Included');
      }
    }

    if (generateAll) {
      optionsMap.updateAll((key, value) => true);
    }

    print('─────────────────────────────────────');

    return GenerateOptions(
      crudMethods: [],
      // will be filled from previous step
      generateEntity: optionsMap['Entity']!,
      generateModel: optionsMap['Model']!,
      generateUseCases: optionsMap['Use Cases']!,
      generateRepository: optionsMap['Repository']!,
      generateBindings: optionsMap['Bindings']!,
      generateRemoteData: optionsMap['Remote Data']!,
      generateController: optionsMap['Controller']!,
      generatePage: optionsMap['Page']!,
      generateForm: optionsMap['Form']!,
      generateRoute: optionsMap['Route']!,
    );
  }
}

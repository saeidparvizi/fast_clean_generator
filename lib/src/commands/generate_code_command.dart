// lib/src/generate_code_command.dart

import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:clean_arch_generator/src/generate_code.dart';
import 'package:clean_arch_generator/src/models/generate_options.dart';
import 'package:clean_arch_generator/src/exceptions/generator_exception.dart';
import '../helpers/naming_helpers.dart';

class GenerateCodeCommand extends Command {
  @override
  String get name => 'generate';

  @override
  String get description =>
      'Generates Flutter code based on a JSON schema with interactive prompts.';

  @override
  Future<void> run() async {
    print(TerminalStyle.bold('╔══════════════════════════════════════╗'));
    print(TerminalStyle.bold('║     Flutter Clean Arch Generator     ║'));
    print(TerminalStyle.bold('╚══════════════════════════════════════╝'));
    print('');

    // ──────────────────────────────────────────────
    // 1. Get JSON input (file path or direct json string)
    // ──────────────────────────────────────────────

    final jsonOrPath = await _promptInput(
      'Enter the JSON file path or JSON string (default: tool/model.json): ',
      required: false,
      defaultValue: 'tool/model.json',
    );

    final featureName = await _promptInput(
      'Enter the feature name (camelCase, e.g., booking): ',
      validator: (v) => v.isNotEmpty && v == toCamel(v),
      errorMessage: 'Invalid camelCase format. Example: booking',
      required: true,
    );

    final rootClass = await _promptInput(
      'Enter the root class name (PascalCase, e.g., Payment): ',
      validator: (v) => v.isNotEmpty && v == toPascal(v),
      errorMessage: 'Invalid PascalCase format. Example: Payment',
      required: true,
    );

    // ──────────────────────────────────────────────
    // 2. Feature name (folder name)
    // ──────────────────────────────────────────────

    final crudMethods = await _promptCrudMethods();

    // ──────────────────────────────────────────────
    // 3. Root class name (main entity/model name)
    // ──────────────────────────────────────────────
    final options = _promptGenerationOptions();

    // ──────────────────────────────────────────────
    // 4. Select desired CRUD operations
    // ──────────────────────────────────────────────
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
      final input = stdin.readLineSync();

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

      if (validator != null && !validator(input)) {
        print(TerminalStyle.error('✕ $errorMessage'));
        continue;
      }

      return input;
    }
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
      TerminalStyle.bold(
          '\nSelect CRUD methods (comma separated e.g., 1,2,3):'),
    );

    for (final entry in crudOptions.entries) {
      if (entry.key != '0') {
        print(
            '  ${TerminalStyle.info('[${entry.key}]')} ${entry.value[0].toUpperCase()}${entry.value.substring(1)}');
      }
    }
    print('  ${TerminalStyle.info('[0]')} All (Default)');
    print('  ${TerminalStyle.info('[q]')} Quit/Cancel');

    while (true) {
      stdout.write('Enter numbers: ');
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
    print(TerminalStyle.bold('\n⚙️  Generation Options:'));
    print('Select components to generate (y/n/a for all, default: y):');
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
      stdout.write('  Generate ${TerminalStyle.info(key)}? [Y/n/a] > ');

      final answer = stdin.readLineSync()?.toLowerCase().trim();

      if (answer == 'a' || answer == 'all') {
        generateAll = true;
        print(TerminalStyle.info('  ✓ Generating all components.'));
        break;
      } else if (answer == 'n' || answer == 'no') {
        optionsMap[key] = false;
        print(TerminalStyle.warning('  ✕ Skipped'));
      } else {
        optionsMap[key] = true;
        print(TerminalStyle.success('  ✓ Included'));
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

// ──────────────────────────────────────
// Terminal style helper (keeps colors in console)
// ──────────────────────────────────────
class TerminalStyle {
  TerminalStyle._();

  static const String reset = '\x1B[0m';
  static const String boldColor = '\x1B[1m';
  static const String red = '\x1B[31m';
  static const String green = '\x1B[32m';
  static const String yellow = '\x1B[33m';
  static const String cyan = '\x1B[36m';

  static String success(String msg) => '$green$msg$reset';

  static String error(String msg) => '$red$msg$reset';

  static String info(String msg) => '$cyan$msg$reset';

  static String warning(String msg) => '$yellow$msg$reset';

  static String bold(String msg) => '$boldColor$msg$reset';
}

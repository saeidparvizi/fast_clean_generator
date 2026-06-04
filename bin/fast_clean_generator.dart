import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:fast_clean_generator/src/commands/generate_code_command.dart';
import 'package:fast_clean_generator/src/commands/init_project_command.dart';

void main(List<String> args) async {
  final runner = CommandRunner<void>(
    'fast_clean_gen',
    'Flutter Clean Architecture Code Generator',
  );

  runner.addCommand(GenerateCodeCommand());
  runner.addCommand(InitProjectCommand());

  try {
    await runner.run(args);
  } on UsageException catch (e) {
    print(e);
    exit(1);
  }
}

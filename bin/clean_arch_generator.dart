import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:clean_arch_generator/src/commands/generate_code_command.dart';

void main(List<String> args) async {
  final runner = CommandRunner<void>(
    'clean_arch_generator',
    'Flutter Clean Architecture Code Generator',
  );

  runner.addCommand(GenerateCodeCommand());

  try {
    await runner.run(args);
  } on UsageException catch (e) {
    print(e);
    exit(1);
  }
}
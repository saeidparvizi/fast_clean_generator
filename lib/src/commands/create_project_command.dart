import 'dart:io';
import 'package:args/command_runner.dart';
import '../helpers/terminal_style.dart';
import 'init_project_command.dart';

class CreateProjectCommand extends Command {
  @override
  String get name => 'create';

  @override
  String get description => 'Creates a new Flutter project and initializes it with Clean Architecture.';

  @override
  String get invocation => 'fcg create <project_name> [options]';

  @override
  Future<void> run() async {
    if (argResults?.rest.isEmpty ?? true) {
      print(TerminalStyle.error('✕ Please provide a project name.'));
      print(TerminalStyle.info('Example: fcg create my_awesome_app'));
      return;
    }

    final projectName = argResults!.rest.first;
    final org = argResults?['org'] as String?;

    print(TerminalStyle.bold('🏗️ Creating Flutter project: $projectName...'));

    // 1. Run flutter create
    final flutterArgs = ['create', projectName];
    if (org != null) {
      flutterArgs.addAll(['--org', org]);
    }

    final result = await Process.run('flutter', flutterArgs);

    if (result.exitCode != 0) {
      print(TerminalStyle.error('✕ Flutter create failed:'));
      print(result.stderr);
      return;
    }

    print(TerminalStyle.success('✓ Flutter project created.'));

    // 2. Change directory to the new project
    Directory.current = Directory('${Directory.current.path}/$projectName');

    // 3. Run the Init logic
    print(TerminalStyle.bold('\n🛠️ Initializing Clean Architecture layers...'));
    final initCommand = InitProjectCommand();
    
    // We manually trigger the run logic of init command
    await initCommand.run();

    print(TerminalStyle.success('\n🌟 Your project is ready!'));
    print(TerminalStyle.info('Next steps:'));
    print('  1. cd $projectName');
    print('  2. fcg generate');
  }

  CreateProjectCommand() {
    argParser.addOption(
      'org',
      abbr: 'o',
      help: 'The organization responsible for your new Flutter project, in reverse domain name notation.',
      valueHelp: 'com.example',
    );
  }
}

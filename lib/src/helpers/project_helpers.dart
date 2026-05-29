import 'dart:io';
import '../exceptions/generator_exception.dart';

String detectProjectName() {
  final pubspecFile = File('pubspec.yaml');

  if (!pubspecFile.existsSync()) {
    throw ProjectException(
      'pubspec.yaml not found in current directory.',
      'Please run this command inside your Flutter project root folder.',
    );
  }

  try {
    final content = pubspecFile.readAsStringSync();
    final nameMatch = RegExp(r'^\s*name:\s*([a-z0-9_]+)', multiLine: true)
        .firstMatch(content);

    if (nameMatch != null && nameMatch.groupCount >= 1) {
      final name = nameMatch.group(1)!.trim();
      if (name.isNotEmpty) {
        return name;
      }
    }

    throw ProjectException(
      'Could not find "name:" field in pubspec.yaml.',
      'Make sure your pubspec.yaml has a valid project name.',
    );
  } catch (e) {
    if (e is ProjectException) rethrow;
    throw ProjectException(
      'Error reading pubspec.yaml.',
      'Details: $e',
    );
  }
}

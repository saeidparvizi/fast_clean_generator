/// Base class for all generator exceptions.
abstract class GeneratorException implements Exception {
  final String message;
  final String? details;

  GeneratorException(this.message, [this.details]);

  @override
  String toString() {
    if (details != null) return '$message\nDetails: $details';
    return message;
  }
}

/// Thrown when pubspec.yaml is missing or invalid.
class ProjectException extends GeneratorException {
  ProjectException(super.message, [super.details]);
}

/// Thrown when JSON schema is missing or invalid.
class JsonSchemaException extends GeneratorException {
  JsonSchemaException(super.message, [super.details]);
}

/// Thrown during code generation process.
class GenerationException extends GeneratorException {
  GenerationException(super.message, [super.details]);
}

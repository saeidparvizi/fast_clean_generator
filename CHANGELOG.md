## 1.1.0

- **New `init` Command**: Scaffolds a full Clean Architecture project structure with essential core files (`BaseUseCase`, `Failure`, `RepositoryExecutor`, etc.).
- **Recursive Class Generation**: Automatically generates all nested Entities and Models from a single JSON schema.
- **Safe Generation Engine**: The `init` command now detects existing files and skips them to protect your custom logic.
- **Smart Primitive Lists**: Full support for basic type lists (`List<String>`, `List<int>`, etc.) in code generation.
- **Enhanced Reliability**: Improved regex-based code injection for Bindings and Controllers to ensure perfect syntax during incremental updates.

## 1.0.5

- **Fixed Critical Re-generation Bug**: Bindings and Controllers now correctly merge new parameters and methods without breaking syntax or losing existing code.
- **Smart Primitive List Handling**: Automatically detects and handles lists of basic types (`List<String>`, `List<int>`, etc.) in Entities and Models.
- **Enhanced Code Injection**: Added a more robust Regex-based engine for injecting code into existing files, ensuring all closing braces and parentheses are preserved.
- **Improved Testing**: Added more than 8 new integration tests covering complex incremental generation scenarios.
- **Clean Architecture Refinement**: Removed unused date-string detection logic to keep the core lean and standard-compliant.

## 1.0.4

- Added a professional ASCII logo on startup.
- Enhanced JSON input handling to support multiline pasting directly in the terminal.

## 1.0.3

- Update default JSON path from `tool/model.json` to `tool/schema.json` for better professional convention.
- Sync example directory with new `schema.json` naming.

## 1.0.2

- Add documentation comments (Dartdoc) to public API.
- Add an example directory with a sample JSON schema.
- Improve package score on pub.dev.

## 1.0.1

- Fix repository URL mismatch in pubspec.yaml.
- Update documentation and meta information.

## 1.0.0

- Initial professional release as **fast_clean_generator**.
- Complete Clean Architecture layer generation (Data, Domain, Presentation).
- Full CRUD support (List, Get, Add, Update, Delete).
- Integrated GetX state management with plural/singular controller support.
- Automated routing updates for `app_routes.dart` and `app_pages.dart`.
- Interactive CLI with step-by-step prompts.
- Added comprehensive unit and integration tests.
- Standardized project structure and error handling.

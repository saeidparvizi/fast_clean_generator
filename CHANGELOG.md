## 1.2.6

- **Extended IDE Compatibility**: Updated `until-build` to support IntelliJ/Android Studio 2026.2 (build 262+) and 2026.3.
- **Version Bump**: Synced CLI and IDE plugin versions to 1.2.6.

## 1.2.5

- **Full Deprecation Fix**: Replaced `ProcessAdapter` with `ProcessListener` and `basePath` with `guessProjectDir()`.
- **Builder Pattern Compliance**: Migrated `GeneralCommandLine` property setters to builder-style `with...` methods.
- **Enhanced Compatibility**: Guaranteed zero deprecated API usages for IntelliJ/Android Studio up to 2026.1.

## 1.2.4

- **Zero Warning Guarantee**: Completely eliminated all deprecated API warnings for IntelliJ/Android Studio 2024, 2025, and 2026.
- **VFS Reliability**: Switched to `VfsUtil.findFileByIoFile` for more robust file system refreshes after generation.
- **GeneralCommandLine Fixes**: Replaced deprecated `setWorkDirectory` with modern `withWorkDirectory`.

## 1.2.3

- **Plugin Stability**: Switched to `DumbAwareAction` to allow generation during indexing.
- **Modern API Compliance**: Updated `GeneralCommandLine` and `ProjectDir` access to eliminate deprecated API warnings for IntelliJ 2024.2+.

## 1.2.2

- **Bug Fixes**: Resolved route injection issue in `AppPages`.
- **Improved ID Handling**: Enhanced identification logic for custom ID fields (e.g., `booking_id`).
- **Standardized Property Access**: Ensured all generated UI properties use consistent camelCase naming.
- **Plugin Compatibility**: Resolved deprecated API usages for IntelliJ/Android Studio 2024.2+.

## 1.2.1

- **Headless Mode Support**: Added CLI flags (`--json`, `--feature`, etc.) and a `--headless` mode to allow non-interactive code generation, enabling integration with IDE plugins and CI/CD pipelines.

## 1.2.0

- **Full Project Creation**: Introduced `fcg create` command to bootstrap a brand new Flutter project with Clean Architecture already configured.
- **Advanced Scaffolding**: Added automatic setup for Theme management (`app_colors`, `app_theme`) and Internationalization (`app_translations`, `en_us`).
- **Network Layer Unification**: Redesigned `ApiProvider` using Composition to ensure 100% compatibility with both GetConnect and Dio.
- **Enhanced Core UI**: Modernized `AppAppbar` and `AppInput` to be production-ready with standard Flutter parameters.
- **Critical Stability Fixes**: Resolved all type mismatches in generated Forms (especially for Date fields) and aligned base class naming conventions.
- **Stress Tested**: Verified the entire generation pipeline with 51 comprehensive tests covering deeply nested JSON and reserved keyword edge cases.

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

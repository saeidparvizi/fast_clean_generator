import 'dart:io';

import 'models/generate_options.dart';
import 'helpers/file_helpers.dart';
import 'helpers/json_helpers.dart';
import 'helpers/naming_helpers.dart';
import 'helpers/project_helpers.dart';
import 'generators/add_page_generator.dart';
import 'generators/app_pages_generator.dart';
import 'generators/bindings_generator.dart';
import 'generators/controller_generator.dart';
import 'generators/delete_dialog_generator.dart';
import 'generators/edit_page_generator.dart';
import 'generators/entity_generator.dart';
import 'generators/form_generator.dart';
import 'generators/model_generator.dart';
import 'generators/page_generator.dart';
import 'generators/remote_data_generator.dart';
import 'generators/repository_generator.dart';
import 'generators/repository_impl_generator.dart';
import 'generators/route_generator.dart';
import 'generators/usecase_generator.dart';
import 'generators/generate_app_routes.dart';

/// The core engine responsible for generating code based on provided options.
///
/// Use this class to programmatically trigger the code generation process.
class GeneratorEngine {
  /// Global project name (detected once)
  late String projectName;

  /// Main entry point for code generation logic.
  ///
  /// Takes a [jsonOrPath], [rootClass] name, [feature] name,
  /// and [crudMethods] to generate the full layer structure.
  Future<void> generate({
    required String jsonOrPath,
    required String rootClass,
    required String feature,
    required List<String> crudMethods,
    required GenerateOptions options,
  }) async {
    // Detect project name from pubspec.yaml (once)
    projectName = detectProjectName();
    print('Project name detected: $projectName');

    // Load and parse JSON schema
    final jsonSchema = await loadJson(jsonOrPath);
    print('JSON schema loaded successfully.');

    final className = rootClass; // e.g. "Support", "Ticket", etc.
    final snakeClass = toSnakeFromName(className);
    final pascalClass = toPascal(className);
    final pluralPascal = pluralize(pascalClass);
    final pluralSnake = toSnakeFromName(pluralPascal);

    // Directories (standard clean arch + getx)
    final baseDir = 'lib/features/$feature';
    final domainDir = '$baseDir/domain';
    final dataDir = '$baseDir/data';
    final presentationDir = '$baseDir/presentation';

    // ──────────────────────────────────────────────
    // 1. Entity
    // ──────────────────────────────────────────────
    if (options.generateEntity) {
      final entityContent = generateEntity(
        pascalClass,
        jsonSchema,
        {}, // fileBase - if nested models exist, fill it
      );

      final entityPath = '$domainDir/entities/${snakeClass}_entity.dart';
      await writeFile(entityPath, entityContent);
      print('Generated: $entityPath');
    }

    // ──────────────────────────────────────────────
    // 2. Model (fromJson / toJson)
    // ──────────────────────────────────────────────
    if (options.generateModel) {
      final modelContent = generateModel(
        className: pascalClass,
        feature: feature,
        projectName: projectName,
        data: jsonSchema,
        fileBase: {}, // fill if nested
      );

      final modelPath = '$dataDir/models/${snakeClass}_model.dart';
      await writeFile(modelPath, modelContent);
      print('Generated: $modelPath');
    }

    // ──────────────────────────────────────────────
    // 3. UseCases
    // ──────────────────────────────────────────────
    if (options.generateUseCases) {
      final useCaseFiles = await generateUseCases(
        projectName: projectName,
        className: className,
        feature: feature,
        crudMethods: crudMethods,
      );

      for (final entry in useCaseFiles.entries) {
        await writeFile(entry.key, entry.value);
        print('Generated: ${entry.key}');
      }
    }

    // ──────────────────────────────────────────────
    // 4. Repository interface
    // ──────────────────────────────────────────────
    if (options.generateRepository) {
      await upsertRepository(
        projectName: projectName,
        feature: feature,
        className: className,
        crudMethods: crudMethods,
      );
      print('Updated/Created repository interface');
    }

    // ──────────────────────────────────────────────
    // 5. Repository Impl
    // ──────────────────────────────────────────────
    if (options.generateRepository) {
      await generateRepositoryImpl(
        projectName: projectName,
        feature: feature,
        className: className,
        crudMethods: crudMethods,
      );
      print('Updated/Created repository implementation');
    }

    // ──────────────────────────────────────────────
    // 6. Remote Data Source
    // ──────────────────────────────────────────────
    if (options.generateRemoteData) {
      await generateRemoteData(
        projectName: projectName,
        feature: feature,
        className: className,
        crudMethods: crudMethods,
      );
      print('Updated/Created remote data source');
    }

    // ──────────────────────────────────────────────
    // 7. Controller (GetX)
    // ──────────────────────────────────────────────
    if (options.generateController) {
      // For list screen controller (handles list, add, update, delete)
      final listControllerPath =
          '$presentationDir/controllers/${pluralSnake}_controller.dart';

      if (crudMethods.contains('list') ||
          crudMethods.contains('add') ||
          crudMethods.contains('delete') ||
          File(listControllerPath).existsSync()) {
        final listController = await ControllerGenerator.generateList(
          className: className,
          feature: feature,
          projectName: projectName,
          crudMethods: crudMethods,
          jsonSchema: jsonSchema,
          controllerPath: listControllerPath,
        );

        await writeFile(listControllerPath, listController);
        print('Generated/Updated: $listControllerPath');
      }

      // For single item controller (get/update)
      final singleControllerPath =
          '$presentationDir/controllers/${snakeClass}_controller.dart';

      if (crudMethods.contains('get') ||
          crudMethods.contains('update') ||
          File(singleControllerPath).existsSync()) {
        final singleController = await ControllerGenerator.generateSingle(
          className: className,
          feature: feature,
          projectName: projectName,
          crudMethods: crudMethods,
          jsonSchema: jsonSchema,
          controllerPath: singleControllerPath,
        );

        await writeFile(singleControllerPath, singleController);
        print('Generated/Updated: $singleControllerPath');
      }
    }

    // ──────────────────────────────────────────────
    // 8. Pages & Widgets
    // ──────────────────────────────────────────────
    if (options.generatePage) {
      if (crudMethods.contains('list')) {
        final listPage = generateListScreen(
          className: className,
          feature: feature,
          projectName: projectName,
          crudMethods: crudMethods,
          jsonSchema: jsonSchema,
        );
        final listPagePath =
            '$presentationDir/pages/${pluralSnake}_screen.dart';
        await writeFile(listPagePath, listPage);
        print('Generated: $listPagePath');
      }

      if (crudMethods.contains('get')) {
        final singlePage = generateSingleScreen(
          className: className,
          feature: feature,
          projectName: projectName,
          crudMethods: crudMethods,
          jsonSchema: jsonSchema,
        );
        final singlePagePath =
            '$presentationDir/pages/${snakeClass}_screen.dart';
        await writeFile(singlePagePath, singlePage);
        print('Generated: $singlePagePath');
      }

      if (crudMethods.contains('add')) {
        final addPage = generateAddScreen(
          className: className,
          feature: feature,
          projectName: projectName,
        );
        final addPagePath =
            '$presentationDir/pages/add_${snakeClass}_screen.dart';
        await writeFile(addPagePath, addPage);
        print('Generated: $addPagePath');
      }

      if (crudMethods.contains('update')) {
        final editPage = generateEditScreen(
          className: className,
          feature: feature,
          projectName: projectName,
          jsonSchema: jsonSchema,
        );
        final editPagePath =
            '$presentationDir/pages/edit_${snakeClass}_screen.dart';
        await writeFile(editPagePath, editPage);
        print('Generated: $editPagePath');
      }
    }

    if (options.generateForm) {
      final formContent = generateForm(
        className: className,
        feature: feature,
        projectName: projectName,
        jsonSchema: jsonSchema,
      );
      final formPath = '$presentationDir/widgets/${snakeClass}_form.dart';
      await writeFile(formPath, formContent);
      print('Generated: $formPath');
    }

    // Delete Dialog (useful for list screens)
    if (crudMethods.contains('delete')) {
      final dialog = generateDeleteDialog(
        className: className,
        feature: feature,
        projectName: projectName,
      );
      final dialogPath =
          '$presentationDir/widgets/delete_${snakeClass}_dialog.dart';
      await writeFile(dialogPath, dialog);
      print('Generated: $dialogPath');
    }

    // ──────────────────────────────────────────────
    // 9. Routes & AppPages
    // ──────────────────────────────────────────────
    if (options.generateRoute) {
      // Feature routes file
      final routesPath = '$baseDir/routes/${feature}_routes.dart';
      final routesContent = generateFeatureRoutes(
        className: className,
        feature: feature,
        projectName: projectName,
        crudMethods: crudMethods,
        routesFilePath: routesPath,
      );
      await writeFile(routesPath, routesContent);
      print('Generated/Updated: $routesPath');

      // Update core app_routes.dart
      final appRoutesContent = generateAppRoutes(
        className: className,
        feature: feature,
        projectName: projectName,
        crudMethods: crudMethods,
      );
      await writeFile(
        'lib/core/routes/app_routes.dart',
        appRoutesContent,
      );
      print('Updated: lib/core/routes/app_routes.dart');

      // Update app_pages.dart
      final appPagesContent = generateFeatureAppPages(
        feature: feature,
        projectName: projectName,
        routesFilePath: routesPath,
      );

      await writeFile('lib/core/routes/app_pages.dart', appPagesContent);

      print('Updated: lib/core/routes/app_pages.dart');
    }

    // ──────────────────────────────────────────────
    // 10. Bindings
    // ──────────────────────────────────────────────
    if (options.generateBindings) {
      final bindingPath = '$presentationDir/bindings/${feature}_binding.dart';
      final bindingContent = await BindingGenerator.generate(
        projectName: projectName,
        feature: feature,
        model: className,
        newCrudMethods: crudMethods,
        bindingFilePath: bindingPath,
      );
      await writeFile(bindingPath, bindingContent);
      print('Generated/Updated: $bindingPath');
    }

    print('\nGeneration completed!');
    print('Feature: $feature');
    print('Class: $className');
    print('CRUD methods: ${crudMethods.join(', ')}');
  }
}

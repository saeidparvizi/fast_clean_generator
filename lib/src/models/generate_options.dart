/// Options to control which parts of the code to generate.
///
/// Each boolean flag toggles the generation of a specific component
/// in the Clean Architecture layers.
class GenerateOptions {
  /// The list of CRUD methods to implement (list, get, add, update, delete).
  final List<String> crudMethods;

  /// Whether to generate the Domain Entity.
  final bool generateEntity;

  /// Whether to generate the Data Model (JSON serialization).
  final bool generateModel;

  /// Whether to generate Domain UseCases.
  final bool generateUseCases;

  /// Whether to generate the Repository interface.
  final bool generateRepository;

  /// Whether to generate GetX Bindings.
  final bool generateBindings;

  /// Whether to generate the Remote Data Source.
  final bool generateRemoteData;

  /// Whether to generate GetX Controllers.
  final bool generateController;

  /// Whether to generate UI Pages/Screens.
  final bool generatePage;

  /// Whether to generate Widget Forms.
  final bool generateForm;

  /// Whether to generate Route definitions.
  final bool generateRoute;

  GenerateOptions({
    this.crudMethods = const ['list', 'get', 'add', 'update', 'delete'],
    this.generateEntity = true,
    this.generateModel = true,
    this.generateUseCases = true,
    this.generateRepository = true,
    this.generateBindings = true,
    this.generateRemoteData = true,
    this.generateController = true,
    this.generatePage = true,
    this.generateForm = true,
    this.generateRoute = true,
  });
}

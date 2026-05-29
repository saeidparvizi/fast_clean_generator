/// Options to control which parts of the code to generate
class GenerateOptions {
  final List<String> crudMethods;
  final bool generateEntity;
  final bool generateModel;
  final bool generateUseCases;
  final bool generateRepository;
  final bool generateBindings;
  final bool generateRemoteData;
  final bool generateController;
  final bool generatePage;
  final bool generateForm;
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

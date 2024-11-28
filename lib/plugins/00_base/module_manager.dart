class ModuleManager {
  static final ModuleManager _instance = ModuleManager._internal();

  // Separate maps for functions and instances
  final Map<String, dynamic> _instances = {};
  final Map<String, Function> _functions = {};

  factory ModuleManager() => _instance;
  ModuleManager._internal();

  /// Registers an instance with a specified name
  void registerInstance(String name, dynamic instance) {
    _instances[name] = instance;
  }

  /// Registers a function with a specified name
  void registerFunction(String name, Function function) {
    _functions[name] = function;
  }

  /// Retrieves an instance by name
  T? getInstance<T>(String name) {
    final instance = _instances[name];
    return instance as T?;
  }

  /// Retrieves a function by name
  T? getFunction<T>(String name) {
    final function = _functions[name];
    return function as T?;
  }
}

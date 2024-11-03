// plugins/base/module_manager.dart
class ModuleManager {
  static final ModuleManager _instance = ModuleManager._internal();
  final Map<String, dynamic> _modules = {}; // Store modules by name

  factory ModuleManager() => _instance;
  ModuleManager._internal();

  /// Registers a module with a specified name
  void registerModule(String name, dynamic module) {
    _modules[name] = module;
    print("Module registered: $name"); // Log module registration
  }

  /// Retrieves a registered module by name
  T? getModule<T>(String name) {
    final module = _modules[name];
    if (module != null) {
      print("Module retrieved: $name"); // Log module retrieval
    } else {
      print("Module not found: $name"); // Log if module doesn't exist
    }
    return module as T?;
  }
}

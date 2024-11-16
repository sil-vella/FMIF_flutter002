// plugins/base/module_manager.dart
class ModuleManager {
  static final ModuleManager _instance = ModuleManager._internal();
  final Map<String, dynamic> _modules = {}; // Store modules by name

  factory ModuleManager() => _instance;
  ModuleManager._internal();

  /// Registers a module with a specified name
  void registerModule(String name, dynamic module) {
    _modules[name] = module;
  }

  /// Retrieves a registered module by name
  T? getModule<T>(String name) {
    final module = _modules[name];

    return module as T?;
  }
}

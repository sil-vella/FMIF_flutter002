import '../../tools/logging/logger.dart';
import '../00_base/module_base.dart';

class ModuleManager {
  static final Logger _log = Logger(); // ✅ Use a static logger for static methods
  static final ModuleManager _instance = ModuleManager._internal();
  factory ModuleManager() => _instance;
  ModuleManager._internal();

  // ✅ Store modules with a key (moduleKey -> {customKey: ModuleInstance})
  final Map<String, Map<String, ModuleBase>> _modules = {};

  /// ✅ Register a module instance with an optional `instanceKey`
  void registerModule(ModuleBase module, {String? instanceKey}) {
    final key = instanceKey ?? module.runtimeType.toString();
    _modules.putIfAbsent(module.moduleKey, () => {})[key] = module;
    _log.info('Module instance registered: ${module.moduleKey} (Key: $key)');
  }

  /// ✅ Get all instances of a module
  List<T>? getModules<T extends ModuleBase>(String moduleKey) {
    _log.info('Fetching all instances of module: $moduleKey');
    return _modules[moduleKey]?.values.cast<T>().toList();
  }

  /// ✅ Get a specific module instance by key, or the latest if no key is provided
  T? getModuleInstance<T extends ModuleBase>(String moduleKey, [String? instanceKey]) {
    if (_modules[moduleKey] == null || _modules[moduleKey]!.isEmpty) {
      _log.error('❌ No instances found for module: $moduleKey');
      return null;
    }

    if (instanceKey != null) {
      _log.info('Fetching instance of module: $moduleKey with key: $instanceKey');
      return _modules[moduleKey]?[instanceKey] as T?;
    } else {
      _log.info('Fetching latest instance of module: $moduleKey');
      return _modules[moduleKey]!.values.last as T?;
    }
  }

  /// ✅ Get the latest instance of ANY module (no key required)
  T? getLatestModule<T extends ModuleBase>() {
    _log.info('Fetching latest instance of module type: ${T.toString()}');

    for (var moduleGroup in _modules.values) {
      for (var module in moduleGroup.values) {
        if (module is T) {
          return module;
        }
      }
    }

    _log.error('❌ No instance found for module type: ${T.toString()}');
    return null;
  }


  /// ✅ Deregister a specific module instance by key
  void deregisterModule(String moduleKey, {String? instanceKey}) {
    if (!_modules.containsKey(moduleKey)) {
      _log.error('Module key not found: $moduleKey');
      return;
    }

    if (instanceKey != null) {
      final removed = _modules[moduleKey]?.remove(instanceKey);
      if (removed != null) {
        removed.dispose();
        _log.info('Module instance deregistered: $moduleKey (Key: $instanceKey)');
      } else {
        _log.error('Module instance key not found: $instanceKey in $moduleKey');
      }
    } else {
      // ✅ If no instanceKey is provided, remove the last instance
      final lastKey = _modules[moduleKey]?.keys.last;
      if (lastKey != null) {
        final removed = _modules[moduleKey]?.remove(lastKey);
        removed?.dispose();
        _log.info('Module instance deregistered: $moduleKey (Key: $lastKey)');
      }
    }

    // ✅ Remove module key if no instances remain
    if (_modules[moduleKey]?.isEmpty ?? true) {
      _modules.remove(moduleKey);
      _log.info('All instances of $moduleKey removed.');
    }
  }

  /// Dispose all modules
  void dispose() {
    _log.info('Disposing all module instances.');
    for (var entry in _modules.entries) {
      for (var module in entry.value.values) {
        module.dispose();
        _log.info('Disposed module: ${entry.key}');
      }
    }
    _modules.clear();
    _log.info('All modules have been disposed.');
  }
}

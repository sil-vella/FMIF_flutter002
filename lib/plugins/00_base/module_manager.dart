import 'dart:developer' as dev;

class ModuleManager {
  static final ModuleManager _instance = ModuleManager._internal();

  // Separate maps for functions and instances
  final Map<String, dynamic> _instances = {};
  final Map<String, Function> _functions = {};

  factory ModuleManager() => _instance;

  ModuleManager._internal();

  /// Registers an instance, ensuring it's only registered once
  void registerInstance(String name, dynamic instance, {void Function(dynamic)? onInit}) {
    if (_instances.containsKey(name)) {
      dev.log(
        "Instance with name '$name' is already registered. Skipping registration.",
        level: 900, // Warning
      );
      return;
    }

    _instances[name] = instance;
    dev.log("Instance registered: $name");

    // Trigger the initialization hook if provided
    if (onInit != null) {
      onInit(instance);
    }
  }

  /// Registers a function, ensuring it's only registered once
  void registerFunction(String name, Function function) {
    if (_functions.containsKey(name)) {
      dev.log(
        "Function with name '$name' is already registered. Skipping registration.",
        level: 900, // Warning
      );
      return;
    }

    _functions[name] = function;
    dev.log("Function registered: $name");
  }

  /// Retrieves an instance by name
  T? getInstance<T>(String name) {
    if (!_instances.containsKey(name)) {
      dev.log(
        "Instance with name '$name' is not registered.",
        level: 900, // Warning
      );
      return null;
    }
    return _instances[name] as T?;
  }

  /// Retrieves a function by name
  T? getFunction<T>(String name) {
    if (!_functions.containsKey(name)) {
      dev.log(
        "Function with name '$name' is not registered.",
        level: 900, // Warning
      );
      return null;
    }
    return _functions[name] as T?;
  }

  /// Checks if an instance is registered by name
  bool isInstanceRegistered(String name) {
    return _instances.containsKey(name);
  }

  /// Checks if a function is registered by name
  bool isFunctionRegistered(String name) {
    return _functions.containsKey(name);
  }

  /// Unregisters an instance by name
  void unregisterInstance(String name) {
    if (_instances.containsKey(name)) {
      _instances.remove(name);
      dev.log("Instance unregistered: $name");
    } else {
      dev.log(
        "Attempted to unregister an instance with name '$name' that does not exist.",
        level: 900, // Warning
      );
      throw ArgumentError("Instance with name '$name' does not exist.");
    }
  }

  /// Unregisters a function by name
  void unregisterFunction(String name) {
    if (_functions.containsKey(name)) {
      _functions.remove(name);
      dev.log("Function unregistered: $name");
    } else {
      dev.log(
        "Attempted to unregister a function with name '$name' that does not exist.",
        level: 900, // Warning
      );
      throw ArgumentError("Function with name '$name' does not exist.");
    }
  }

  /// Clears all registered instances and functions
  void clearAll() {
    _instances.clear();
    _functions.clear();
    dev.log("All registered instances and functions have been cleared.");
  }

  /// Logs the current state of registered instances and functions
  void logState() {
    dev.log("Registered Instances: ${_instances.keys.toList()}");
    dev.log("Registered Functions: ${_functions.keys.toList()}");
  }
}

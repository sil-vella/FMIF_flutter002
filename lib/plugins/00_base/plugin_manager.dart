// plugins/base/plugin_manager.dart
import 'package:flutter/material.dart';
import 'app_plugin.dart';

class PluginManager {
  static final PluginManager _instance = PluginManager._internal();
  final List<AppPlugin> _registeredPlugins = [];

  factory PluginManager() => _instance;
  PluginManager._internal();

  void registerPlugin(AppPlugin plugin) {
    print("PluginManager: Registering plugin ${plugin.runtimeType}");
    _registeredPlugins.add(plugin);
  }

  void runOnStartup() {
    print("PluginManager: Running onStartup for all registered plugins...");
    for (var plugin in _registeredPlugins) {
      print("PluginManager: Calling onStartup for ${plugin.runtimeType}");
      plugin.onStartup();
    }
  }

  void initializeAllPlugins(BuildContext context) {
    print("PluginManager: Initializing all registered plugins...");
    for (var plugin in _registeredPlugins) {
      print("PluginManager: Initializing ${plugin.runtimeType}");
      plugin.initialize(context);
    }
  }
}

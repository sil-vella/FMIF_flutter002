// plugins/base/plugin_manager.dart
import 'package:flutter/material.dart';
import 'app_plugin.dart';

class PluginManager {
  static final PluginManager _instance = PluginManager._internal();
  final List<AppPlugin> _registeredPlugins = [];

  factory PluginManager() => _instance;
  PluginManager._internal();

  /// Registers a plugin without initializing it immediately
  void registerPlugin(AppPlugin plugin) {
    _registeredPlugins.add(plugin);
  }

  /// Calls the onStartup hook for all registered plugins
  void runOnStartup() {
    for (var plugin in _registeredPlugins) {
      plugin.onStartup(); // Call the onStartup method for each plugin
    }
  }

  /// Initializes all registered plugins, passing the BuildContext
  void initializeAllPlugins(BuildContext context) {
    for (var plugin in _registeredPlugins) {
      plugin.initialize(context); // Pass BuildContext to each plugin
    }
  }
}

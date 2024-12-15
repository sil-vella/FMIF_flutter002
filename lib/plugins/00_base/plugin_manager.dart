// plugins/base/plugin_manager.dart
import 'package:flutter/material.dart';
import 'app_plugin.dart';

class PluginManager {
  static final PluginManager _instance = PluginManager._internal();
  final List<AppPlugin> _registeredPlugins = [];

  factory PluginManager() => _instance;
  PluginManager._internal();

  void registerPlugin(AppPlugin plugin) {
    _registeredPlugins.add(plugin);
  }

  void runOnStartup() {
    for (var plugin in _registeredPlugins) {
      plugin.onStartup();
    }
  }

  void initializeAllPlugins(BuildContext context) {
    for (var plugin in _registeredPlugins) {
      plugin.initialize(context);
    }
  }

  void disposeAllPlugins() {
    // Iterate over plugins and call dispose, while deregistering them
    for (var plugin in List.from(_registeredPlugins)) {
      plugin.dispose(); // Plugin handles its cleanup and deregisters itself
      deregisterPlugin(plugin);
    }
  }

  void deregisterPlugin(AppPlugin plugin) {
    _registeredPlugins.remove(plugin);
  }

  bool isPluginRegistered(AppPlugin plugin) {
    return _registeredPlugins.contains(plugin);
  }
}
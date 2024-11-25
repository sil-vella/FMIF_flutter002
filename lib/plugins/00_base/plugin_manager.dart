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
}

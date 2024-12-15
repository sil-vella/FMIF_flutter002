// plugins/base/plugin_manager.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/providers/app_state_provider.dart';
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

  void disposeAllPlugins(BuildContext context) {
    print("disposeall is reached"); // Debug log
    final appStateProvider = Provider.of<AppStateProvider>(context, listen: false);

    for (var plugin in List.from(_registeredPlugins)) {
      final pluginKey = "${plugin.runtimeType}State";
      print("disposeall pluginkey $pluginKey"); // Debug log
      // Reset plugin state in AppStateProvider
      if (appStateProvider.isPluginStateRegistered(pluginKey)) {
        print("if  appStateProvider.isPluginStateRegistered"); // Debug log
        appStateProvider.unregisterPluginState(pluginKey);
      }

      plugin.dispose(); // Plugin handles its cleanup
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

// plugins/base/plugin_manager.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/providers/app_state_provider.dart';
import 'app_plugins_base.dart';

class PluginManager {
  static final PluginManager _instance = PluginManager._internal();
  final List<AppPlugin> _registeredPlugins = [];

  factory PluginManager() => _instance;
  PluginManager._internal();

  void registerPlugin(AppPlugin plugin) {
    _registeredPlugins.add(plugin);
  }

  Future<void> runOnStartup() async {
    for (var plugin in _registeredPlugins) {
      plugin.onStartup();
    }
  }

  Future<void> initializeAllPlugins(BuildContext context) async {
    for (var plugin in _registeredPlugins) {
      await plugin.initialize(context);
    }
  }

  Future<void>  disposeAllPlugins(BuildContext context) async {
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

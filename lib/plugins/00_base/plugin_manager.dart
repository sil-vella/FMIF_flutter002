// plugins/base/plugin_manager.dart
import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/providers/app_state_provider.dart';
import 'app_plugins_base.dart';

class PluginManager {
  static final PluginManager _instance = PluginManager._internal();
  final Set<String> _registeredPluginNames = {}; // Tracks plugin names to prevent duplicates
  final List<AppPlugin> _registeredPlugins = [];

  factory PluginManager() => _instance;
  PluginManager._internal();

  void registerPlugin(AppPlugin plugin) {
    final pluginName = plugin.runtimeType.toString();
    if (_registeredPluginNames.contains(pluginName)) {
      dev.log('Plugin $pluginName is already registered.');
      return;
    }

    _registeredPlugins.add(plugin);
    _registeredPluginNames.add(pluginName);
    dev.log('Plugin $pluginName registered successfully.');
  }

  Future<void> runOnStartup() async {
    for (var plugin in _registeredPlugins) {
      await plugin.onStartup();
    }
  }

  Future<void> initializeAllPlugins(BuildContext context) async {
    for (var plugin in _registeredPlugins) {
      await plugin.initialize(context);
    }
  }

  Future<void> disposeAllPlugins(BuildContext context) async {
    dev.log("Dispose all plugins is reached.");
    final appStateProvider = Provider.of<AppStateProvider>(context, listen: false);

    for (var plugin in List.from(_registeredPlugins)) {
      final pluginKey = "${plugin.runtimeType}State";

      if (appStateProvider.isPluginStateRegistered(pluginKey)) {
        appStateProvider.unregisterPluginState(pluginKey);
      }

      await plugin.dispose(); // Plugin handles its cleanup
      deregisterPlugin(plugin);
    }
  }

  void deregisterPlugin(AppPlugin plugin) {
    final pluginName = plugin.runtimeType.toString();
    _registeredPlugins.remove(plugin);
    _registeredPluginNames.remove(pluginName);
    dev.log('Plugin $pluginName deregistered successfully.');
  }

  bool isPluginRegistered(AppPlugin plugin) {
    final pluginName = plugin.runtimeType.toString();
    return _registeredPluginNames.contains(pluginName);
  }
}


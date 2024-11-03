// plugins/shared_plugin/admobs_main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_state_provider.dart';
import '../00_base/app_plugin.dart';
import '../00_base/module_manager.dart';
import 'modules/connection_module.dart';

class ConnectToDb implements AppPlugin {
  ConnectToDb._internal();

  static final ConnectToDb _instance = ConnectToDb._internal();

  factory ConnectToDb() => _instance;

  @override
  void onStartup() {
    // Register ConnectionModule during startup
    print("Plugin onStartup - Registering ConnectionModule");
    registerModules(); // Register modules at startup
  }

  @override
  void initialize(BuildContext context) {
    print("ConnectToDb initialized");

    // Access app state if needed after the app context is available
    final appState = Provider.of<AppStateProvider>(context, listen: false);

    // Attempt to access another plugin's state (if necessary)
    final otherPluginState = appState.getPluginState<Map<String, dynamic>>("PluginBState");
    if (otherPluginState != null) {
      print("Accessed PluginBState: $otherPluginState");
    } else {
      print("PluginBState not available during ConnectToDb initialization.");
    }
  }

  @override
  void registerModules() {
    // Register a factory function for ConnectionModule
    ModuleManager().registerModule("ConnectionModule", (String baseUrl) => ConnectionModule(baseUrl));
  }
}

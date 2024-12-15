import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/providers/app_state_provider.dart';
import '../00_base/app_plugin.dart';
import '../00_base/module_manager.dart';
import 'modules/connection_module.dart';

class Api implements AppPlugin {
  Api._internal();

  static final Api _instance = Api._internal();

  factory Api() => _instance;

  @override
  void onStartup() {
    // Custom startup action with dynamic plugin name
    registerModules(); // Register modules at startup
  }

  @override
  void initialize(BuildContext context) {
    // Access app state if needed after the app context is available
    final appState = Provider.of<AppStateProvider>(context, listen: false);

    // Attempt to access another plugin's state (if necessary)
    final otherPluginState = appState.getPluginState<Map<String, dynamic>>("PluginBState");
    if (otherPluginState != null) {
    }
  }

  void registerModules() {
    // Register a factory function for ConnectionModule
    ModuleManager().registerFunction("ConnectionModule", (String baseUrl) => ConnectionModule(baseUrl));
  }

  @override
  void dispose() {
    // Unregister modules or clean up resources when disposing the plugin
    ModuleManager().unregisterFunction("ConnectionModule");
  }
}

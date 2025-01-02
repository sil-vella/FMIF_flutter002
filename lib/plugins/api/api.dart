import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/providers/app_state_provider.dart';
import '../00_base/app_plugins_base.dart';
import '../00_base/module_manager.dart';
import 'modules/connection_module.dart';

class Api implements AppPlugin {
  Api._internal();

  static final Api _instance = Api._internal();

  factory Api() => _instance;

  @override
  void onStartup() {
    // Register modules at startup
    try {
      registerModules();
      dev.log('Api plugin startup completed successfully.');
    } catch (e, stackTrace) {
      dev.log('Error during Api plugin startup: $e', level: 1000, stackTrace: stackTrace);
    }
  }

  @override
  Future<void> initialize(BuildContext context) async {
    try {
      final appState = Provider.of<AppStateProvider>(context, listen: false);

      // Attempt to access another plugin's state (if necessary)
      final otherPluginState = appState.getPluginState<Map<String, dynamic>>("PluginBState");
      if (otherPluginState != null) {
        dev.log('Successfully accessed PluginBState.');
      } else {
        dev.log('PluginBState not found.', level: 900); // Warning level
      }
    } catch (e, stackTrace) {
      dev.log('Error during Api plugin initialization: $e', level: 1000, stackTrace: stackTrace);
    }
  }

  void registerModules() {
    // Register a factory function for ConnectionModule
    try {
      ModuleManager().registerFunction(
        "ConnectionModule",
            (String baseUrl) => ConnectionModule(baseUrl),
      );
      dev.log('ConnectionModule registered successfully.');
    } catch (e, stackTrace) {
      dev.log('Error registering ConnectionModule: $e', level: 900, stackTrace: stackTrace);
    }
  }

  @override
  void dispose() {
    // Unregister modules or clean up resources when disposing the plugin
    try {
      if (ModuleManager().isFunctionRegistered("ConnectionModule")) {
        ModuleManager().unregisterFunction("ConnectionModule");
        dev.log('ConnectionModule unregistered successfully.');
      } else {
        dev.log('Attempted to unregister ConnectionModule, but it was not registered.', level: 900); // Warning level
      }
    } catch (e, stackTrace) {
      dev.log('Error during ConnectionModule unregistration: $e', level: 1000, stackTrace: stackTrace);
    }
  }
}

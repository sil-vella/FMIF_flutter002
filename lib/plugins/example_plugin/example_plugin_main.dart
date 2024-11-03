// plugins/shared_plugin/admobs_main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state_provider.dart';
import 'functions/example_plugin_helper.dart';
import '../00_base/app_plugin.dart';

class PluginExample implements AppPlugin {
  PluginExample._internal();

  static final PluginExample _instance = PluginExample._internal();

  factory PluginExample() => _instance;

  @override
  void onStartup() {
    // Custom startup action with dynamic plugin name
    print("${runtimeType} onStartup");
  }

  @override
  void initialize(BuildContext context) {
    print("PluginExample initialized");

    registerModules(); // Register any shared modules required by the plugin
    PluginHelper.registerNavigation(context); // Use helper class for navigation registration
    Provider.of<AppStateProvider>(context, listen: false)
        .registerPluginState("PluginBState", {"state_example": 0}); // Set plugin state

    PluginHelper.connectToDb(); // Use helper class for database connection
  }

  @override
  void registerModules() {
    // Define modules if needed
  }
}

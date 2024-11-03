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
    // Register plugin state with dynamic plugin name
    // Register plugin state with dynamic plugin name, using the default state from reset()
    Provider.of<AppStateProvider>(context, listen: false)
        .registerPluginState("${runtimeType}State", reset());
  }

  @override
  void registerModules() {
    // Define modules if needed
  }

  // Method to return the default state structure
  Map<String, dynamic> reset() {
    return {
      "key_one": 0,
      "key_two": "",
      "key_three": []
    };
  }
}

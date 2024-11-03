// plugins/shared_plugin/admobs_main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state_provider.dart';
import '../../services/shared_preferences_service.dart'; // Import the service
import 'functions/main_plugin_helper.dart';
import '../00_base/app_plugin.dart';

class MainPlugin implements AppPlugin {
  MainPlugin._internal();

  static final MainPlugin _instance = MainPlugin._internal();

  factory MainPlugin() => _instance;

  @override
  void onStartup() {
    print("${runtimeType} onStartup");
  }

  @override
  void initialize(BuildContext context) async {
    print("${runtimeType} initialized");

    registerModules();
    PluginHelper.registerNavigation(context);

    final pluginStateKey = "${runtimeType}State";
    final appStateProvider = Provider.of<AppStateProvider>(context, listen: false);

    // Retrieve the saved category as a String
    final savedCategory = SharedPreferencesService().getString("celeb_category") ?? "";

    // Use saved category if available, otherwise use the default state
    appStateProvider.registerPluginState(pluginStateKey, reset()..["celeb_category"] = savedCategory);
  }

  @override
  void registerModules() {
    // Define modules if needed
  }

  // Method to return the default state structure
  Map<String, dynamic> reset() {
    return {
      "play_state": "idle",
      "celeb_category": "",
      "celeb_name": "",
      "celeb_img_url": "",
      "celeb_facts": []
    };
  }
}

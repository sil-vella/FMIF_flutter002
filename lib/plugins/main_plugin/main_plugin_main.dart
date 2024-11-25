import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state_provider.dart';
import '../../services/shared_preferences_service.dart';
import 'functions/main_plugin_helper.dart';
import '../00_base/app_plugin.dart';

class MainPlugin implements AppPlugin {
  MainPlugin._internal();

  static final MainPlugin _instance = MainPlugin._internal();

  factory MainPlugin() => _instance;

  @override
  void onStartup() {
    // Add any non-context-dependent startup logic here
  }

  @override
  void initialize(BuildContext context) async {

    // Register modules
    registerModules();

    // Register AppBar items with context
    PluginHelper.registerAppbarItems(context);

    // Register navigation
    PluginHelper.registerNavigation(context);

    // Access and initialize app state
    final pluginStateKey = "${runtimeType}State";
    final appStateProvider = Provider.of<AppStateProvider>(context, listen: false);

    // Load saved category, if any
    final savedCategory = SharedPreferencesService().getString("celeb_category") ?? "";

    // Initialize only if plugin state is not yet registered
    if (!appStateProvider.isPluginStateRegistered(pluginStateKey)) {
      final initialState = reset();
      if (savedCategory.isNotEmpty) {
        initialState["celeb_category"] = savedCategory;
      }
      initialState["ad_counter"] = 0; // Initialize ad_counter here
      appStateProvider.registerPluginState(pluginStateKey, initialState);
    }
  }

  // Method to reset the plugin state to default while preserving ad_counter
  void resetPlayState(BuildContext context) {
    final appStateProvider = Provider.of<AppStateProvider>(context, listen: false);
    final pluginStateKey = "${runtimeType}State";

    // Retrieve current ad_counter
    final pluginState = appStateProvider.getPluginState<Map<String, dynamic>>(pluginStateKey) ?? {};
    final adCounter = pluginState['ad_counter'] ?? 0;

    // Reset the plugin state while preserving ad_counter
    final resetState = reset();
    resetState["ad_counter"] = adCounter;

    appStateProvider.registerPluginState(pluginStateKey, resetState);
  }

  void registerModules() {}

  // Default state
  Map<String, dynamic> reset() {
    return {
      "play_state": "idle",
      "celeb_name": "",
      "celeb_img_url": "",
      "celeb_facts": [],
      "plugin_anims": {},
      'flushing': false,
      'hint': false,
      'correct_anim': "",
      'incorrect_anim': "",
      // 'ad_counter' is not included here to avoid resetting it periodically
    };
  }
}

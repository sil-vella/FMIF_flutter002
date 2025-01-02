import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/providers/app_state_provider.dart';
import '../../services/shared_preferences_service.dart';
import '../00_base/module_manager.dart';
import 'functions/main_plugin_helper.dart';
import '../00_base/app_plugins_base.dart';
import 'modules/audio_module/audio_module.dart';

class MainPlugin implements AppPlugin {
  MainPlugin._internal();

  static final MainPlugin _instance = MainPlugin._internal();

  factory MainPlugin() => _instance;

  @override
  void onStartup() {
    // Add any non-context-dependent startup logic here
  }

  @override
  Future<void> initialize(BuildContext context) async {

    // Register modules
    registerModules();

    // Register AppBar items with context
    PluginHelper.registerAppbarItems(context);

    // Register all routes but include only '/prefs' in the drawer
    PluginHelper.registerNavigation(context, drawerRoutes: ['/play', '/prefs', '/levelup', '/leaderboard']);

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

  @override
  void dispose() {
  }

  void registerModules() {
    ModuleManager().registerInstance("AudioHelper", AudioHelper());

  }

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

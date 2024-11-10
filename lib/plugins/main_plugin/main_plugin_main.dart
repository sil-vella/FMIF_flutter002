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
    print("${runtimeType} onStartup");
  }

  @override
  void initialize(BuildContext context) async {
    print("${runtimeType} initialized");

    registerModules();
    PluginHelper.registerNavigation(context);

    final pluginStateKey = "${runtimeType}State";
    final appStateProvider = Provider.of<AppStateProvider>(context, listen: false);

    final savedCategory = SharedPreferencesService().getString("celeb_category") ?? "";

    // Register or reset the plugin state with default values, including any saved category
    appStateProvider.registerPluginState(pluginStateKey, reset()..["celeb_category"] = savedCategory);
  }

  // Method to reset the plugin state to default
  void resetPlayState(BuildContext context) {
    final appStateProvider = Provider.of<AppStateProvider>(context, listen: false);
    final pluginStateKey = "${runtimeType}State";
    final savedCategory = SharedPreferencesService().getString("celeb_category") ?? "";
    appStateProvider.registerPluginState(pluginStateKey, reset()..["celeb_category"] = savedCategory);
  }

  @override
  void registerModules() {
    // Define modules if needed
  }

  Map<String, dynamic> reset() {
    return {
      "play_state": "idle",
      "celeb_name": "",
      "celeb_img_url": "",
      "celeb_facts": [],
      "plugin_anims": {},
      'flushing': false,
    };
  }
}

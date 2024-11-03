// plugins/shared_plugin/admobs_main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_state_provider.dart';
import '../00_base/app_plugin.dart';
import '../00_base/module_manager.dart';
import 'modules/banner/banner_ad_widget.dart';

class AdmobsPlugin implements AppPlugin {
  AdmobsPlugin._internal();

  static final AdmobsPlugin _instance = AdmobsPlugin._internal();

  factory AdmobsPlugin() => _instance;

  @override
  void onStartup() {
    // Custom startup action with dynamic plugin name
    print("${runtimeType} onStartup");
    registerModules(); // Register modules at startup
  }

  @override
  void initialize(BuildContext context) {
    print("AdmobsPlugin initialized");

    // Register shared modules before accessing any states or services
    registerModules();

    final appState = Provider.of<AppStateProvider>(context, listen: false);

  }

  @override
  void registerModules() {
    // Register a factory function for AdmobsPlugin
    ModuleManager().registerModule("BannerModule", () => BannerAdWidget());
  }
}

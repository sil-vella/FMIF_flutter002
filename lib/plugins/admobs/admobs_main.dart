// plugins/shared_plugin/admobs_main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_state_provider.dart';
import '../00_base/app_plugin.dart';
import '../00_base/module_manager.dart';
import 'modules/banner/banner_ad_widget.dart';
import 'modules/interstitial/interstitial_ad_manager.dart';
import 'modules/interstitial/interstitial_ad_widget.dart';

class AdmobsPlugin implements AppPlugin {
  AdmobsPlugin._internal();

  static final AdmobsPlugin _instance = AdmobsPlugin._internal();

  factory AdmobsPlugin() => _instance;

  final InterstitialAdManager _interstitialAdManager = InterstitialAdManager();

  @override
  void onStartup() {
    print("AdmobsPlugin onStartup: Registering modules and preloading interstitial ad.");
    registerModules(); // Register modules at startup

    // Preload interstitial ad
    _interstitialAdManager.loadInterstitialAd();
    print("AdmobsPlugin: Interstitial ad preloading initiated.");
  }

  @override
  void initialize(BuildContext context) {
    print("AdmobsPlugin initialize: Registering modules and ensuring ad preload.");
    registerModules();

    final appState = Provider.of<AppStateProvider>(context, listen: false);

    // Ensure interstitial ad is preloaded
    _interstitialAdManager.loadInterstitialAd();
  }

  @override
  void registerModules() {
    // Register a factory function for BannerModule
    ModuleManager().registerModule("BannerModule", () => BannerAdWidget());

    // Register a factory function for InterstitialModule
    ModuleManager().registerModule("InterstitialModule", () {
      return InterstitialAdWidget(manager: _interstitialAdManager); // Pass the manager
    });
  }

}

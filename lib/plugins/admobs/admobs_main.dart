import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
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

    // Initialize AdMob SDK with test device ID
    _initializeAdMob();

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

  void _initializeAdMob() {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize Google Mobile Ads
    MobileAds.instance.initialize();

    // Set up test device IDs
    const String testDeviceId = "7DF149AB78F0BC466F2AED45CE5A9D84"; // Replace with your test device ID
    MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(testDeviceIds: [testDeviceId]),
    );

    print("AdMob initialized with test device ID: $testDeviceId");
  }
}

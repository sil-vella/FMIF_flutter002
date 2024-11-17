import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import '../../providers/app_state_provider.dart';
import '../../utils/consts/config.dart';
import '../00_base/app_plugin.dart';
import '../00_base/module_manager.dart';
import 'modules/banner/banner_ad.dart';
import 'modules/interstitial/interstitial_ad.dart';  // Import the InterstitialAdModule

class AdmobsPlugin implements AppPlugin {
  AdmobsPlugin._internal();

  static final AdmobsPlugin _instance = AdmobsPlugin._internal();

  factory AdmobsPlugin() => _instance;

  final InterstitialAdService _interstitialAdService = InterstitialAdService(
    adUnitId: Config.admobsInterstitial01, // Fetch the Ad Unit ID from Config
  );

  void showInterstitialAd() {
    _interstitialAdService.showAd(); // Show the interstitial ad
  }

  @override
  void onStartup() {
    print("AdmobsPlugin onStartup: Registering modules and preloading interstitial ad.");

    // Initialize AdMob SDK with test device ID
    _initializeAdMob();

    registerModules(); // Register modules at startup

    // Preload the interstitial ad
    _interstitialAdService.loadAd();
  }

  @override
  void initialize(BuildContext context) {
    print("AdmobsPlugin initialize: Registering modules and ensuring ad preload.");
    registerModules();

    final appState = Provider.of<AppStateProvider>(context, listen: false);
  }

  @override
  void registerModules() {
    // Register a factory function for BannerModule and InterstitialAdService
    ModuleManager().registerModule("BannerModule", () => BannerAdModule());

    // Register InterstitialAdService
    ModuleManager().registerModule("InterstitialAdService", () => _interstitialAdService);
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

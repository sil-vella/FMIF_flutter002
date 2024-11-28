import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import '../../providers/app_state_provider.dart';
import '../../utils/consts/config.dart';
import '../00_base/app_plugin.dart';
import '../00_base/module_manager.dart';
import 'modules/banner/banner_ad.dart';
import 'modules/interstitial/interstitial_ad.dart';
import 'modules/rewarded/rewarded_ad.dart'; // Import the RewardedAdModule

class AdmobsPlugin implements AppPlugin {
  AdmobsPlugin._internal();

  static final AdmobsPlugin _instance = AdmobsPlugin._internal();

  factory AdmobsPlugin() => _instance;

  final InterstitialAdService _interstitialAdService = InterstitialAdService(
    adUnitId: Config.admobsInterstitial01, // Fetch the Ad Unit ID from Config
  );

  final RewardedAdService _rewardedAdService = RewardedAdService(
    adUnitId: Config.admobsRewarded01, // Fetch the Rewarded Ad Unit ID from Config
  );

  void showInterstitialAd() {
    _interstitialAdService.showAd(); // Show the interstitial ad
  }

  void showRewardedAd({
    required AppStateProvider appStateProvider,
    required BuildContext context,
  }) {
    _rewardedAdService.showAd(
      appStateProvider: appStateProvider,
      context: context,
    ); // Show the rewarded ad
  }

  @override
  void onStartup() {

    // Initialize AdMob SDK with test device ID
    _initializeAdMob();

    registerModules(); // Register modules at startup

    // Preload ads
    _interstitialAdService.loadAd();
    _rewardedAdService.loadAd();
  }

  @override
  void initialize(BuildContext context) {
    registerModules();
  }

  void registerModules() {
    // Register a factory function for BannerModule
    ModuleManager().registerFunction("BannerModule", () => BannerAdModule());

    // Register InterstitialAdService as an instance
    ModuleManager().registerInstance("InterstitialAdService", _interstitialAdService);

    // Register RewardedAdService as an instance
    ModuleManager().registerInstance("RewardedAdService", _rewardedAdService);
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

  }
}

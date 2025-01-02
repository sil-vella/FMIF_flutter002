import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import '../../services/providers/app_state_provider.dart';
import '../../utils/consts/config.dart';
import '../00_base/app_plugins_base.dart';
import '../00_base/module_manager.dart';
import 'modules/banner/banner_ad.dart';
import 'modules/interstitial/interstitial_ad.dart';
import 'modules/rewarded/rewarded_ad.dart';

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

  /// Displays an interstitial ad
  void showInterstitialAd() {
    _interstitialAdService.showAd(); // Show the interstitial ad
  }

  /// Displays a rewarded ad
  void showRewardedAd({
    required AppStateProvider appStateProvider,
    required BuildContext context,
  }) {
    _rewardedAdService.showAd(
      appStateProvider: appStateProvider,
      context: context,
    ); // Show the rewarded ad
  }

  void _setupAdListeners(AppStateProvider appStateProvider) {
    _interstitialAdService.isAdDismissed.addListener(() {
      if (_interstitialAdService.isAdDismissed.value) {
        // Add a 5-second delay before updating the state
        Future.delayed(const Duration(seconds: 5), () {
          appStateProvider.updatePluginState("AdmobsPluginState", {
            "interstitial01": {"isShowing": false},
          });
          // Reset the ValueNotifier to avoid duplicate triggers
          _interstitialAdService.isAdDismissed.value = false;
        });
      }
    });
  }

  @override
  void onStartup() {

  }

  @override
  Future<void> initialize(BuildContext context) async {
    final appStateProvider = Provider.of<AppStateProvider>(context, listen: false);
    _setupAdListeners(appStateProvider);
    _initializeAdMob();
    registerModules();
    _interstitialAdService.loadAd(); // Preloading interstitial ad
    _rewardedAdService.loadAd();    // Preloading rewarded ad
  }



  /// Registers modules with the ModuleManager
  void registerModules() {
    ModuleManager().registerFunction("BannerModule", () => BannerAdModule());
    ModuleManager().registerInstance("InterstitialAdService", _interstitialAdService);
    ModuleManager().registerInstance("RewardedAdService", _rewardedAdService);
  }

  /// Initializes AdMob SDK
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

  @override
  void dispose() {
    // Dispose interstitial ad service
    _interstitialAdService.dispose();
    // Dispose rewarded ad service
    _rewardedAdService.dispose();

    // Unregister modules using appropriate unregister methods
    ModuleManager().unregisterFunction("BannerModule");
    ModuleManager().unregisterInstance("InterstitialAdService");
    ModuleManager().unregisterInstance("RewardedAdService");
  }
}

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import '../../../../../core/00_base/module_base.dart';
import '../../../../../core/managers/module_manager.dart';
import '../../../../../core/managers/services_manager.dart';
import '../../../../../core/services/shared_preferences.dart';
import '../../../../../tools/logging/logger.dart';
import '../../../../main_plugin/modules/main_helper_module/main_helper_module.dart';

class RewardedAdModule extends ModuleBase {
  static final Logger _log = Logger();
  final String adUnitId;
  RewardedAd? _rewardedAd;
  bool _isAdReady = false;

  /// ✅ Constructor with module key
  RewardedAdModule(this.adUnitId) : super("admobs_rewarded_ad_module") {
    _log.info('RewardedAdModule created');
    loadAd(); // ✅ Load ad on initialization
  }

  /// ✅ Loads the rewarded ad
  Future<void> loadAd() async {
    _log.info('📢 Loading Rewarded Ad for ID: $adUnitId');
    RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isAdReady = true;
          _log.info('✅ Rewarded Ad Loaded for ID: $adUnitId.');
        },
        onAdFailedToLoad: (error) {
          _isAdReady = false;
          _log.error('❌ Failed to load Rewarded Ad for ID: $adUnitId. Error: ${error.message}');
        },
      ),
    );
  }

  /// ✅ Shows the rewarded ad with callbacks
  Future<void> showAd(BuildContext context, {VoidCallback? onUserEarnedReward, VoidCallback? onAdDismissed}) async {
    final servicesManager = Provider.of<ServicesManager>(context, listen: false);
    final sharedPref = servicesManager.getService<SharedPrefManager>();

    if (sharedPref == null) {
      _log.error('❌ SharedPreferences service not available.');
      return;
    }

    if (_isAdReady && _rewardedAd != null) {
      _log.info('🎬 Showing Rewarded Ad for ID: $adUnitId');

      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (Ad ad) {
          onAdDismissed?.call(); // ✅ Call callback when ad is closed
          _rewardedAd?.dispose(); // ✅ Dispose when ad is closed
          _rewardedAd = null;
          _isAdReady = false;
          loadAd(); // ✅ Preload next ad
          _log.info('✅ Rewarded Ad dismissed and disposed.');
        },
        onAdFailedToShowFullScreenContent: (Ad ad, AdError error) {
          _rewardedAd?.dispose(); // ✅ Dispose on failure
          _rewardedAd = null;
          _isAdReady = false;
          loadAd();
          _log.error('❌ Failed to show Rewarded Ad: $error');
        },
      );

      _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          onUserEarnedReward?.call(); // ✅ Give reward to user

          // ✅ Increment rewarded ad views in SharedPreferences
          int rewardedViews = sharedPref.getInt('rewarded_ad_views') ?? 0;
          sharedPref.setInt('rewarded_ad_views', rewardedViews + 1);
          _log.info('🏆 Rewarded ad watched. Total views: ${rewardedViews + 1}');
        },
      );
    } else {
      _log.error('❌ Rewarded Ad not ready for ID: $adUnitId.');
    }
  }

  /// ✅ Disposes of the rewarded ad
  @override
  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _log.info('🗑 Rewarded Ad Module disposed for ID: $adUnitId.');
    super.dispose();
  }
}

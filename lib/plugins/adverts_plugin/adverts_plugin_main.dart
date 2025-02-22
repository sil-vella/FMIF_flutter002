import 'package:flush_me_im_famous/plugins/adverts_plugin/modules/admobs/banner/banner_ad.dart';
import 'package:flush_me_im_famous/plugins/adverts_plugin/modules/admobs/interstitial/interstitial_ad.dart';
import 'package:flush_me_im_famous/plugins/adverts_plugin/modules/admobs/rewarded/rewarded_ad.dart';
import 'package:flutter/material.dart';
import '../../core/00_base/module_base.dart';
import '../../core/00_base/plugin_base.dart';
import '../../core/managers/hooks_manager.dart';
import '../../core/managers/module_manager.dart';
import '../../core/managers/navigation_manager.dart';
import '../../core/managers/services_manager.dart';
import '../../core/managers/state_manager.dart';
import '../../tools/logging/logger.dart';
import '../../utils/consts/config.dart';

class AdvertsPlugin extends PluginBase {
  final ServicesManager servicesManager;
  final StateManager stateManager; // ✅ Add StateManager
  final interstitialAdUnitId = Config.admobsInterstitial01;
  final rewardedAdUnitId = Config.admobsRewarded01;

  AdvertsPlugin(
      HooksManager hooksManager, ModuleManager moduleManager, NavigationContainer navigationContainer,
      this.stateManager) // ✅ Pass StateManager
      : servicesManager = ServicesManager(),
        super(hooksManager, moduleManager) {

    // ✅ Register hooks
    hookMap.addAll({
      'app_startup': () {
        _preLoadAds(); // ✅ Initialize ads on startup
      },
    });
  }

  /// ✅ Define initial states for this plugin
  @override
  Map<String, Map<String, dynamic>> getInitialStates() {
    return {};
  }

  /// ✅ Register Ad-related modules with specific instance keys
  @override
  Map<String?, ModuleBase> createModules() {
    return {
      'admobs_banner_ad_module': BannerAdModule(), // ✅ Hardcoded key
      null: InterstitialAdModule(interstitialAdUnitId), // ✅ Pass `adUnitId`
      null: RewardedAdModule(rewardedAdUnitId), // ✅ Pass `adUnitId`
    };
  }

  /// ✅ Preload all ads to ensure fast loading
  /// ✅ Preload all ads to ensure fast loading
  Future<void> _preLoadAds() async {
    final bannerAdModule = moduleManager.getModuleInstance<BannerAdModule>('admobs_banner_ad_module');
    final interstitialAdModule = moduleManager.getLatestModule<InterstitialAdModule>(); // ✅ Works for auto keys
    final rewardedAdModule = moduleManager.getLatestModule<RewardedAdModule>(); // ✅ Works for auto keys

    if (bannerAdModule != null) {
      await bannerAdModule.loadBannerAd(Config.admobsTopBanner);
      await bannerAdModule.loadBannerAd(Config.admobsBottomBanner);
      log.info('✅ Banner Ads preloaded.');
    } else {
      log.error('❌ Failed to preload Banner Ads: Module not found.');
    }

    if (interstitialAdModule != null) {
      await interstitialAdModule.loadAd();
      log.info('✅ Interstitial Ad preloaded.');
    } else {
      log.error('❌ Failed to preload Interstitial Ad: Module not found.');
    }

    if (rewardedAdModule != null) {
      await rewardedAdModule.loadAd();
      log.info('✅ Rewarded Ad preloaded.');
    } else {
      log.error('❌ Failed to preload Rewarded Ad: Module not found.');
    }
  }


}

import '../../../../../core/00_base/module_base.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../../../tools/logging/logger.dart';

class BannerAdModule extends ModuleBase {
  static final Logger _log = Logger(); // ✅ Use a static logger for static methods
  final Map<String, BannerAd?> _banners = {}; // Store multiple ads

  /// ✅ Call `super` to set moduleKey & auto-register
  BannerAdModule() : super("banner_ad_module") {
    _log.info('📢 BannerAdModule initialized and auto-registered.');
  }

  /// ✅ Loads the banner ad with a specified ad unit ID
  Future<void> loadBannerAd(String adUnitId) async {
    _log.info('📢 Loading Banner Ad for ID: $adUnitId');

    final bannerAd = BannerAd(
      adUnitId: adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => _log.info('✅ Banner Ad Loaded for ID: $adUnitId.'),
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          _log.error('❌ Failed to load Banner Ad for ID: $adUnitId. Error: ${error.message}');
          ad.dispose();
        },
      ),
    );

    await bannerAd.load();
    _banners[adUnitId] = bannerAd;
  }

  Widget getBannerWidget(String adUnitId, BuildContext context, {String? widgetKey}) {
    final key = widgetKey ?? DateTime.now().millisecondsSinceEpoch.toString();

    if (!_banners.containsKey(key)) {
      _log.info('📢 Creating new Banner Ad for Widget Key: $key');

      final newBannerAd = BannerAd(
        adUnitId: adUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (_) => _log.info('✅ Banner Ad Loaded for Widget Key: $key'),
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            _log.error('❌ Failed to load Banner Ad. Error: ${error.message}');
            ad.dispose();
          },
        ),
      )..load();

      _banners[key] = newBannerAd;
    }

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: _banners[key]!.size.height.toDouble(),
      child: AdWidget(ad: _banners[key]!),
    );
  }



  /// ✅ Disposes of the banner ad
  void disposeBannerAd(String adUnitId) {
    if (_banners.containsKey(adUnitId)) {
      _banners[adUnitId]?.dispose();
      _banners.remove(adUnitId);
      _log.info('🗑 Banner Ad Disposed for ID: $adUnitId.');
    } else {
      _log.error('⚠️ Tried to dispose non-existing Banner Ad for ID: $adUnitId.');
    }
  }

  /// ✅ Override `dispose()` to clean up before module deregisters
  @override
  void dispose() {
    _log.info('🗑 Disposing all Banner Ads...');
    for (final ad in _banners.values) {
      ad?.dispose();
    }
    _banners.clear();
    super.dispose(); // ✅ Calls `ModuleBase.dispose()` to auto-deregister
  }
}

// plugins/banner_ad_module.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../../utils/consts/config.dart';
import '../../../00_base/module_manager.dart';

class BannerAdModule extends StatelessWidget {
  BannerAdModule({Key? key}) : super(key: key);

  // Use the ad unit ID from Config, depending on platform
  final String adUnitId = Platform.isAndroid
      ? Config.admobsBottomBanner01 // Replace with Config for Android
      : Config.admobsBottomBanner01; // Replace with Config for iOS as well

  late final BannerAd _bannerAd = BannerAd(
    adUnitId: adUnitId,
    size: AdSize.banner,
    request: const AdRequest(),
    listener: BannerAdListener(
      onAdLoaded: (Ad ad) => print('Banner Ad loaded.'),
      onAdFailedToLoad: (Ad ad, LoadAdError error) {
        print('Failed to load Banner Ad: $error');
        ad.dispose();
      },
    ),
  );

  @override
  Widget build(BuildContext context) {
    _bannerAd.load(); // Load the ad immediately

    return SizedBox(
      width: _bannerAd.size.width.toDouble(),
      height: _bannerAd.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd),
    );
  }

  void dispose() {
    _bannerAd.dispose(); // Clean up when the widget is disposed
  }
}

/// Register the BannerAdModule with the ModuleManager
void registerBannerAdModule() {
  ModuleManager().registerModule('BannerAdModule', BannerAdModule());
}

// services/admobs/banner_ad_manager.dart
import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../../utils/consts/config.dart'; // Import Config

class BannerAdManager {
  // Use the ad unit ID from Config, depending on platform
  final String adUnitId = Platform.isAndroid
      ? Config.admobsBottomBanner01 // Replace with Config for Android
      : Config.admobsBottomBanner01; // Replace with Config for iOS as well

  BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
        },
      ),
    );
  }
}

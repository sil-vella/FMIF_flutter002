// services/admobs/interstitial_ad_manager.dart
import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../../utils/consts/config.dart'; // Import Config

class InterstitialAdManager {
  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;

  // Use Config to set the ad unit ID based on the platform
  final String adUnitId = Platform.isAndroid
      ? Config.admobsInterstitial01 // Android ad unit ID from Config
      : Config.admobsInterstitial01; // iOS ad unit ID from Config

  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _isAdLoaded = true;
          _setUpAdCallbacks();
        },
        onAdFailedToLoad: (LoadAdError error) {
          _isAdLoaded = false;
        },
      ),
    );
  }

  void _setUpAdCallbacks() {
    _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) {
      },
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        ad.dispose();
        _isAdLoaded = false;
        loadInterstitialAd(); // Preload another ad for next use
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        ad.dispose();
        _isAdLoaded = false;
      },

    );
  }

  void showInterstitialAd() {
    if (_isAdLoaded && _interstitialAd != null) {
      _interstitialAd?.show();
    }
  }

  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isAdLoaded = false;
  }
}

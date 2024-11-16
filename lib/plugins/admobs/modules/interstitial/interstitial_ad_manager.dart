// services/admobs/interstitial_ad_manager.dart
import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../../utils/consts/config.dart'; // Import Config

class InterstitialAdManager {
  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;

  final String adUnitId = Platform.isAndroid
      ? Config.admobsInterstitial01
      : Config.admobsInterstitial01;

  void loadInterstitialAd() {
    print("Loading interstitial ad...");
    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _isAdLoaded = true;
          print("Interstitial ad loaded successfully: _isAdLoaded=$_isAdLoaded");
          _setUpAdCallbacks();
        },
        onAdFailedToLoad: (LoadAdError error) {
          _isAdLoaded = false;
          print("Failed to load interstitial ad: $error");
        },
      ),
    );
  }

  void _setUpAdCallbacks() {
    _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) {
        print("Interstitial ad displayed.");
      },
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        print("Interstitial ad dismissed.");
        ad.dispose();
        _isAdLoaded = false;
        loadInterstitialAd(); // Preload another ad
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        print("Interstitial ad failed to show: $error");
        ad.dispose();
        _isAdLoaded = false;
      },
    );
  }

  void showInterstitialAd() {
    if (_isAdLoaded && _interstitialAd != null) {
      print("Showing interstitial ad...");
      _interstitialAd?.show();
    } else {
      print("Interstitial ad not ready: _isAdLoaded=$_isAdLoaded, _interstitialAd=$_interstitialAd");
    }
  }

  void dispose() {
    print("Disposing interstitial ad.");
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isAdLoaded = false;
  }
}

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
          print("Interstitial ad successfully loaded: _isAdLoaded=$_isAdLoaded");
          _setUpAdCallbacks();
        },
        onAdFailedToLoad: (LoadAdError error) {
          _isAdLoaded = false;
          print("Interstitial ad failed to load: $error");
        },
      ),
    );
  }

  Future<void> showInterstitialAdWithDelay({int retryDelayInSeconds = 2, int maxRetries = 3}) async {
    int retryCount = 0;

    while (!_isAdLoaded || _interstitialAd == null) {
      if (retryCount >= maxRetries) {
        print("Max retries reached. Ad could not be displayed.");
        return;
      }

      print("Ad not ready, retrying after $retryDelayInSeconds seconds (attempt ${retryCount + 1})...");
      await Future.delayed(Duration(seconds: retryDelayInSeconds));
      retryCount++;
    }

    // Once the ad is ready
    print("Ad is ready, displaying...");
    _interstitialAd?.show();
  }

  void showInterstitialAd() {
    if (_isAdLoaded && _interstitialAd != null) {
      print("Showing interstitial ad...");
      _interstitialAd?.show();
    } else {
      print("Interstitial ad not ready: _isAdLoaded=$_isAdLoaded, _interstitialAd=$_interstitialAd");
      if (!_isAdLoaded) {
        print("Triggering ad reload since no ad is loaded.");
        loadInterstitialAd(); // Reload the ad if not ready
      }
    }
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

  void dispose() {
    print("Disposing interstitial ad.");
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isAdLoaded = false;
  }
}

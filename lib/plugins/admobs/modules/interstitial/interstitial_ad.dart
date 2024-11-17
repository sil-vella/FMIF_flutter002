import 'package:google_mobile_ads/google_mobile_ads.dart';

class InterstitialAdService {
  InterstitialAd? _interstitialAd;

  /// The Ad Unit ID (Fetched from Config)
  final String adUnitId;

  InterstitialAdService({required this.adUnitId});

  /// Load the interstitial ad
  void loadAd() {
    print("Loading interstitial ad...");
    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          print("Interstitial ad loaded successfully.");
          _interstitialAd = ad;

          _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (InterstitialAd ad) {
              print("Interstitial ad displayed.");
            },
            onAdImpression: (InterstitialAd ad) {
              print("Interstitial ad impression recorded.");
            },
            onAdDismissedFullScreenContent: (InterstitialAd ad) {
              print("Interstitial ad dismissed.");
              ad.dispose();
              _interstitialAd = null;
              loadAd(); // Preload another ad
            },
            onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
              print("Failed to show interstitial ad: $error");
              ad.dispose();
              _interstitialAd = null;
              loadAd(); // Preload another ad
            },
            onAdClicked: (InterstitialAd ad) {
              print("Interstitial ad clicked.");
            },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          print("Failed to load interstitial ad: $error");
        },
      ),
    );
  }

  /// Show the interstitial ad
  void showAd() {
    if (_interstitialAd != null) {
      print("Showing interstitial ad...");
      _interstitialAd!.show();
    } else {
      print("Interstitial ad is not ready.");
      loadAd(); // Attempt to reload the ad
    }
  }

  /// Dispose the interstitial ad
  void disposeAd() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
  }
}

import 'package:google_mobile_ads/google_mobile_ads.dart';

class InterstitialAdService {
  InterstitialAd? _interstitialAd;
  final String adUnitId;
  bool _isAdReady = false;

  InterstitialAdService({required this.adUnitId});

  // Load the interstitial ad
  void loadAd() {
    print("Loading interstitial ad...");
    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          print("Interstitial ad loaded successfully.");
          _interstitialAd = ad;
          _isAdReady = true; // Set the ad as ready

          // Set up the full-screen content callback
          _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              print("Interstitial ad displayed.");
            },
            onAdImpression: (ad) {
              print("Interstitial ad impression recorded.");
            },
            onAdDismissedFullScreenContent: (ad) {
              print("Interstitial ad dismissed.");
              ad.dispose();
              _interstitialAd = null;
              loadAd(); // Preload another ad
              _isAdReady = false;
            },
            onAdFailedToShowFullScreenContent: (ad, err) {
              print("Failed to show interstitial ad: $err");
              ad.dispose();
              _interstitialAd = null;
              loadAd(); // Preload another ad
              _isAdReady = false;
            },
            onAdClicked: (ad) {
              print("Interstitial ad clicked.");
            },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          print("Failed to load interstitial ad: $error");
          _isAdReady = false;
        },
      ),
    );
  }

  // Show the interstitial ad if it is ready
  void showAd() {
    if (_isAdReady) {
      print("Showing interstitial ad...");
      _interstitialAd!.show();
    } else {
      print("Interstitial ad is not ready, attempting to load it again.");
      loadAd(); // Reload if the ad is not ready
    }
  }

  // Dispose the interstitial ad
  void disposeAd() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isAdReady = false;
  }
}

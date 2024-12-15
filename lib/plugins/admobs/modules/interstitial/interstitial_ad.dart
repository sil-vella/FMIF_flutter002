import 'package:google_mobile_ads/google_mobile_ads.dart';

class InterstitialAdService {
  InterstitialAd? _interstitialAd;
  final String adUnitId;
  bool _isAdReady = false;

  InterstitialAdService({required this.adUnitId});

  // Load the interstitial ad
  void loadAd() {
    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isAdReady = true; // Set the ad as ready

          // Set up the full-screen content callback
          _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
            },
            onAdImpression: (ad) {
            },
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null;
              loadAd(); // Preload another ad
              _isAdReady = false;
            },
            onAdFailedToShowFullScreenContent: (ad, err) {
              ad.dispose();
              _interstitialAd = null;
              loadAd(); // Preload another ad
              _isAdReady = false;
            },
            onAdClicked: (ad) {
            },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          _isAdReady = false;
        },
      ),
    );
  }

  // Show the interstitial ad if it is ready
  void showAd() {
    if (_isAdReady) {
      _interstitialAd!.show();
    } else {
      loadAd(); // Reload if the ad is not ready
    }
  }

  // Dispose the interstitial ad
  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isAdReady = false;
  }
}

import '../../../../../core/00_base/module_base.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../../../tools/logging/logger.dart';

class InterstitialAdModule extends ModuleBase {
  static final Logger _log = Logger(); // ✅ Use a static logger for static methods
  final String adUnitId;
  InterstitialAd? _interstitialAd;
  bool _isAdReady = false;

  /// ✅ Constructor with module key
  InterstitialAdModule(this.adUnitId) : super("admobs_interstitial_ad_module") {
    _log.info('InterstitialAdModule created for Ad Unit: $adUnitId');
    loadAd(); // ✅ Load ad on initialization
  }

  /// ✅ Loads the interstitial ad
  Future<void> loadAd() async {
    _log.info('📢 Loading Interstitial Ad for ID: $adUnitId');
    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isAdReady = true;
          _log.info('✅ Interstitial Ad Loaded for ID: $adUnitId.');
        },
        onAdFailedToLoad: (error) {
          _isAdReady = false;
          _log.error('❌ Failed to load Interstitial Ad for ID: $adUnitId. Error: ${error.message}');
        },
      ),
    );
  }

  /// ✅ Shows the interstitial ad
  Future<void> showAd() async {
    if (_isAdReady && _interstitialAd != null) {
      _log.info('🎬 Showing Interstitial Ad for ID: $adUnitId');
      _interstitialAd!.show();
      _interstitialAd = null;
      _isAdReady = false;
      loadAd(); // ✅ Preload next ad
    } else {
      _log.error('❌ Interstitial Ad not ready for ID: $adUnitId.');
    }
  }

  /// ✅ Disposes of the interstitial ad
  @override
  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _log.info('🗑 Interstitial Ad Module disposed for ID: $adUnitId.');
    super.dispose();
  }
}

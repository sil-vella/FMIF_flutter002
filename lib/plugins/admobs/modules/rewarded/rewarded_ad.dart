import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../../services/providers/app_state_provider.dart';
import '../../../main_plugin/functions/play_functions.dart';

class RewardedAdService {
  final String adUnitId;
  RewardedAd? _rewardedAd;
  bool _isAdReady = false;

  RewardedAdService({required this.adUnitId});

  void loadAd() {
    RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isAdReady = true;
          _setAdCallbacks(ad);
        },
        onAdFailedToLoad: (error) {
          _isAdReady = false;
        },
      ),
    );
  }

  void showAd({
    required AppStateProvider appStateProvider,
    required BuildContext context,
  }) {
    if (_isAdReady && _rewardedAd != null) {
      _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          // Pass AppStateProvider and BuildContext to PlayFunctions
          PlayFunctions.onRewardEarned(appStateProvider, context);
        },
      );
      _isAdReady = false;
      loadAd(); // Preload the next ad
    } else {
      loadAd(); // Attempt to load a new ad
    }
  }




  void _setAdCallbacks(RewardedAd ad) {
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
      },
    );
  }

  void dispose() {
    _rewardedAd?.dispose();
  }
}

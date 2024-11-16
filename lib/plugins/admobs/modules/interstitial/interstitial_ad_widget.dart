// services/admobs/interstitial_ad_widget.dart
import 'package:flutter/material.dart';
import 'interstitial_ad_manager.dart';

class InterstitialAdWidget extends StatelessWidget {
  const InterstitialAdWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final InterstitialAdManager adManager = InterstitialAdManager();
    adManager.loadInterstitialAd(); // Load the ad when the widget builds

    return ElevatedButton(
      onPressed: () {
        adManager.showInterstitialAd();
      },
      child: const Text("Show Interstitial Ad"),
    );
  }
}

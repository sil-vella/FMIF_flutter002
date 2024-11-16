// services/admobs/interstitial_ad_widget.dart
import 'package:flutter/material.dart';
import 'interstitial_ad_manager.dart';

class InterstitialAdWidget extends StatelessWidget {
  final InterstitialAdManager manager; // Define the manager parameter

  const InterstitialAdWidget({Key? key, required this.manager}) : super(key: key); // Ensure it's required

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        print("InterstitialAdWidget: Button pressed, attempting to show ad.");
        manager.showInterstitialAd(); // Use the provided manager to show the ad
      },
      child: const Text("Show Interstitial Ad"),
    );
  }
}

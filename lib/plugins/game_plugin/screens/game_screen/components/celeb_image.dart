import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../../tools/logging/logger.dart';

class CelebImage extends StatelessWidget {
  final String imageUrl;
  final Function onImageLoaded;
  final String currentCategory;
  final int currentLevel;

  const CelebImage({
    Key? key,
    required this.imageUrl,
    required this.onImageLoaded,
    required this.currentCategory,
    required this.currentLevel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Construct the background image path
    String backgroundImagePath = 'assets/images/backgrounds/lev$currentLevel/$currentCategory/main_background_$currentCategory.png';

    return Stack(
      fit: StackFit.expand,
      children: [
        // Full background image
        Image.asset(
          backgroundImagePath,
          fit: BoxFit.cover, // Covers the full screen
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            Logger().error("⚠️ Possible issue loading background image: $backgroundImagePath | Error: $error");

            // Delayed check to confirm if the image is truly missing
            Future.delayed(Duration(milliseconds: 500), () {
              final file = File(backgroundImagePath);
              if (!file.existsSync()) {
                Logger().error("❌ Confirmed missing: $backgroundImagePath");
              } else {
                Logger().info("✅ Image exists after delay, likely a temporary issue: $backgroundImagePath");
              }
            });

            return Container(color: Colors.black); // Fallback background
          },
        ),

        // Centered cached network image at 10% width
        Align(
          alignment: Alignment.center,
          child: FractionallySizedBox(
            widthFactor: 0.2, // 10% of the screen width
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.contain, // Maintain aspect ratio
              placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) {
                Logger().error("⚠️ Possible issue loading network image: $imageUrl | Error: $error");

                // Verify if the network image is actually failing or if it's a temporary issue
                Future.delayed(Duration(milliseconds: 500), () {
                  // Ideally, we'd check for a valid response, but we log instead for debugging
                  Logger().info("📡 Retrying image load: $imageUrl");
                });

                return Image.asset('assets/images/icon.png', fit: BoxFit.contain); // Fallback image
              },
              imageBuilder: (context, imageProvider) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Logger().info("📸 Image Loaded: $imageUrl");
                  onImageLoaded();
                });
                return Image(image: imageProvider, fit: BoxFit.contain);
              },
            ),
          ),
        ),
      ],
    );
  }
}

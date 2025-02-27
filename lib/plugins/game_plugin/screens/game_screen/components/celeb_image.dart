import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../../tools/logging/logger.dart';

class CelebImage extends StatelessWidget {
  final String imageUrl;
  final Function(ImageProvider) onImageLoaded; // ✅ Now passes ImageProvider
  final String currentCategory;
  final int currentLevel;

  const CelebImage({
    Key? key,
    required this.imageUrl,
    required this.onImageLoaded, // ✅ Callback for passing cached image
    required this.currentCategory,
    required this.currentLevel,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
// Ensure category and level are valid
// Ensure category and level are valid
    String safeCategory = currentCategory.isNotEmpty ? currentCategory : "default";
    int safeLevel = currentLevel > 0 ? currentLevel : 1;

// Construct the background image paths
    String backgroundImagePath = currentCategory.isNotEmpty
        ? 'assets/images/backgrounds/lev$safeLevel/$safeCategory/main_background_$safeCategory.png'
        : 'assets/images/backgrounds/main_background_default.png';

    String backgroundImageOverlayPath = currentCategory.isNotEmpty
        ? 'assets/images/backgrounds/lev$safeLevel/$safeCategory/main_background_overlay_$safeCategory.png'
        : 'assets/images/backgrounds/main_background_overlay_default.png';

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
        Align(
          alignment: Alignment.center,
          child: FractionallySizedBox(
            widthFactor: 0.2, // 10% of the screen width
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.contain,
              placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) {
                Logger().error("⚠️ Possible issue loading network image: $imageUrl | Error: $error");
                return Image.asset('assets/images/icon.png', fit: BoxFit.contain);
              },
              imageBuilder: (context, imageProvider) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Logger().info("📸 Image Loaded and cached: $imageUrl");
                  onImageLoaded(imageProvider); // ✅ Pass cached image back to GameScreenState
                });
                return Image(image: imageProvider, fit: BoxFit.contain);
              },
            ),
          ),
        ),

        Image.asset(
          backgroundImageOverlayPath,
          fit: BoxFit.cover, // Covers the full screen
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            Logger().error("⚠️ Possible issue loading background image: $backgroundImageOverlayPath | Error: $error");

            // Delayed check to confirm if the image is truly missing
            Future.delayed(Duration(milliseconds: 500), () {
              final file = File(backgroundImagePath);
              if (!file.existsSync()) {
                Logger().error("❌ Confirmed missing: $backgroundImageOverlayPath");
              } else {
                Logger().info("✅ Image exists after delay, likely a temporary issue: $backgroundImageOverlayPath");
              }
            });

            return Container(color: Colors.black); // Fallback background
          },
        ),
      ],
    );
  }
}

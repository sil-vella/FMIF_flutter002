import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../../tools/logging/logger.dart';

class CelebImage extends StatelessWidget {
  final String imageUrl;
  final Function onImageLoaded; // Callback to be triggered when image is loaded

  const CelebImage({Key? key, required this.imageUrl, required this.onImageLoaded}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: double.infinity,
        height: double.infinity, // Takes full height and width
        fit: BoxFit.cover,
        placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
        errorWidget: (context, url, error) {
          Logger().error("❌ Image failed to load: $imageUrl | Using fallback...");
          return Image.asset('assets/images/icon.png', fit: BoxFit.cover);
        },
        imageBuilder: (context, imageProvider) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Logger().info("📸 Image Loaded: $imageUrl");
            // Call the callback when the image is loaded
            onImageLoaded();
          });
          return Image(image: imageProvider, fit: BoxFit.cover);
        },
      ),
    );
  }
}

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_state_provider.dart';
import '../main_plugin_main.dart';

class AfterMathAnimComponent extends StatelessWidget {
  const AfterMathAnimComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pluginStateKey = "${MainPlugin().runtimeType}State";

    // Check the current playState
    final String? playState = context.select<AppStateProvider, String?>(
          (appStateProvider) {
        final pluginState =
            appStateProvider.getPluginState<Map<String, dynamic>>(pluginStateKey) ?? {};
        return pluginState['play_state'] as String?;
      },
    );

    // List of GIF asset paths
    final List<String> gifAssetPaths = [
      'assets/correct_aftermath_background_gifs/fire001.gif',
      'assets/correct_aftermath_background_gifs/explosion001.gif',
      'assets/correct_aftermath_background_gifs/pyramid-head001.gif',
      'assets/correct_aftermath_background_gifs/silent-hill-nurse001.gif',
      'assets/correct_aftermath_background_gifs/out_of_screen001.gif'
    ];

    if (playState == 'aftermath_correct') {
      final randomGifPath = gifAssetPaths[Random().nextInt(gifAssetPaths.length)];
      final double borderThickness = MediaQuery.of(context).size.width * 0.1;

      return Stack(
        children: [
          // Full-screen background image
          Positioned.fill(
            child: Opacity(
              opacity: 0.3,
              child: Image.asset(
                randomGifPath,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(Icons.error, color: Colors.red, size: 50),
                  );
                },
              ),
            ),
          ),
          // Top border
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: borderThickness,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black, // Full opacity
                    Colors.black.withOpacity(0), // Transparent
                  ],
                ),
              ),
            ),
          ),
          // Bottom border
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: borderThickness,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black, // Full opacity
                    Colors.black.withOpacity(0), // Transparent
                  ],
                ),
              ),
            ),
          ),
          // Left border
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            width: borderThickness,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.black, // Full opacity
                    Colors.black.withOpacity(0), // Transparent
                  ],
                ),
              ),
            ),
          ),
          // Right border
          Positioned(
            top: 0,
            bottom: 0,
            right: 0,
            width: borderThickness,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [
                    Colors.black, // Full opacity
                    Colors.black.withOpacity(0), // Transparent
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    // If the state is not `aftermath_correct`, return an empty widget
    return const SizedBox.shrink();
  }
}

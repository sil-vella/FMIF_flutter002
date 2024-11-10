import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_state_provider.dart';
import '../functions/play_functions.dart';

class AfterMathComponent extends StatefulWidget {
  const AfterMathComponent({Key? key}) : super(key: key);

  @override
  _AfterMathComponentState createState() => _AfterMathComponentState();
}

class _AfterMathComponentState extends State<AfterMathComponent> {
  String? randomImagePath;

  @override
  void initState() {
    super.initState();
    loadRandomImage();
  }

  void loadRandomImage() {
    final imagePaths = [
      'assets/after_animations/elmo-fire012.gif',
      // Add all image paths here
    ];

    if (imagePaths.isNotEmpty) {
      final randomIndex = Random().nextInt(imagePaths.length);
      setState(() {
        randomImagePath = imagePaths[randomIndex];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pluginStateKey = "MainPluginState";
    final appStateProvider = Provider.of<AppStateProvider>(context, listen: false);

    // Listen to play_state changes and only rebuild when play_state is aftermath
    final isAftermathState = context.select<AppStateProvider, bool>((appStateProvider) {
      final pluginState = appStateProvider.getPluginState<Map<String, dynamic>>(pluginStateKey) ?? {};
      return pluginState['play_state'] == 'aftermath';
    });

    // Only render component when in aftermath state
    if (!isAftermathState) {
      return SizedBox.shrink();
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final imageSize = screenWidth * 0.2;

    return Center(
      child: SizedBox(
        width: imageSize,
        height: imageSize,
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: randomImagePath != null
                  ? AssetImage(randomImagePath!)
                  : AssetImage('assets/app_images/default_celeb_head.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}

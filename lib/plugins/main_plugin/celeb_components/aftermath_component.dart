import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_state_provider.dart';
import '../functions/animation_helper.dart';
import '../functions/play_functions.dart';

class AfterMathComponent extends StatefulWidget {
  const AfterMathComponent({Key? key}) : super(key: key);

  @override
  _AfterMathComponentState createState() => _AfterMathComponentState();
}

class _AfterMathComponentState extends State<AfterMathComponent>
    with TickerProviderStateMixin {
  late final AnimationController slideUpController;
  String? randomImagePath;

  @override
  void initState() {
    super.initState();
    slideUpController = AnimationController(vsync: this, duration: Duration(seconds: 2));
    loadRandomImage();
  }

  @override
  void dispose() {
    slideUpController.dispose();
    super.dispose();
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

    // Reset and start the slideUp animation when the component is in the aftermath state
    slideUpController.reset();
    slideUpController.forward();

    final screenWidth = MediaQuery.of(context).size.width;
    final imageSize = screenWidth * 0.2;

    return Center(
      child: SizedBox(
        width: imageSize,
        height: imageSize,
        child: AnimationHelper.slideUpAndDown(
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: randomImagePath != null
                    ? AssetImage(randomImagePath!)
                    : AssetImage('assets/app_images/default_celeb_head.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          controller: slideUpController,
          onComplete: () => PlayFunctions.resetPluginPlayState(appStateProvider, pluginStateKey),
        ),
      ),
    );
  }
}
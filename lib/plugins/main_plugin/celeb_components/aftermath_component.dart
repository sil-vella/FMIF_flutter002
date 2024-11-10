import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_state_provider.dart';
import '../functions/animation_helper.dart';
import '../functions/play_functions.dart';
import '../main_plugin_main.dart';

class AfterMathComponent extends StatefulWidget {
  const AfterMathComponent({Key? key}) : super(key: key);

  @override
  _AfterMathComponentState createState() => _AfterMathComponentState();
}

class _AfterMathComponentState extends State<AfterMathComponent>
    with TickerProviderStateMixin {
  late final AnimationController slideUpAndDownController;
  late final AnimationController flyAwayController;
  late final AnimationHelper animationHelper;
  String? randomImagePath;

  @override
  void initState() {
    super.initState();
    animationHelper = AnimationHelper();
    slideUpAndDownController = AnimationController(vsync: this);
    flyAwayController = AnimationController(vsync: this);
    loadRandomImage();
  }

  @override
  void dispose() {
    slideUpAndDownController.dispose();
    flyAwayController.dispose();
    super.dispose();
  }

  void loadRandomImage() {
    // Define separate image paths for correct and incorrect aftermath states
    final correctImagePaths = [
      'assets/after_animations/elmo-fire012.gif',
      // Add other correct aftermath images here
    ];

    final incorrectImagePaths = [
      'assets/after_animations/elmo-fire012.gif',
      // Add other incorrect aftermath images here
    ];

    // Determine which list to use based on play_state
    final appStateProvider = Provider.of<AppStateProvider>(context, listen: false);
    final pluginStateKey = "${MainPlugin().runtimeType}State";
    final playState = appStateProvider.getPluginState<Map<String, dynamic>>(pluginStateKey)?['play_state'];

    final imagePaths = (playState == 'aftermath_correct') ? correctImagePaths : incorrectImagePaths;

    if (imagePaths.isNotEmpty) {
      final randomIndex = Random().nextInt(imagePaths.length);
      setState(() {
        randomImagePath = imagePaths[randomIndex];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appStateProvider = Provider.of<AppStateProvider>(context, listen: false);
    final pluginStateKey = "${MainPlugin().runtimeType}State";

    // Check if the play_state is aftermath_correct or aftermath_incorrect
    final isAftermathState = context.select<AppStateProvider, bool>((appStateProvider) {
      final pluginState = appStateProvider.getPluginState<Map<String, dynamic>>(pluginStateKey) ?? {};
      final playState = pluginState['play_state'];
      return playState == 'aftermath_correct' || playState == 'aftermath_incorrect';
    });

    if (!isAftermathState) {
      return SizedBox.shrink();
    }

    // Listen for animation settings from `plugin_anims`
    final List<String>? aftermathAnims = context.select<AppStateProvider, List<String>?>(
          (appStateProvider) {
        final pluginState = appStateProvider.getPluginState<Map<String, dynamic>>(pluginStateKey) ?? {};
        return List<String>.from(pluginState['plugin_anims']?['aftermath_anims'] ?? []);
      },
    );

    final screenWidth = MediaQuery.of(context).size.width;
    final imageSize = screenWidth * 0.3;

    Widget animatedChild = Container(
      width: imageSize,
      height: imageSize,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: randomImagePath != null
              ? AssetImage(randomImagePath!)
              : AssetImage('assets/app_images/default_celeb_head.png'),
          fit: BoxFit.cover,
        ),
      ),
    );

    // Apply animations based on contents of `aftermathAnims`
    if (aftermathAnims != null && aftermathAnims.contains('slideUpAndDown')) {
      animatedChild = animationHelper.slideUpAndDown(
        animatedChild,
        controller: slideUpAndDownController,
        duration: Duration(seconds: 4),
        begin: Offset(0.0, 1.0),
        middle: Offset(0.0, -0.3),
        end: Offset(0.0, 1.0),
        infinite: false,
        curve: Curves.easeIn,
        onComplete: () {
          PlayFunctions.resetPluginPlayState(appStateProvider, pluginStateKey);
        },
      );
    }

    if (aftermathAnims != null && aftermathAnims.contains('flyAway')) {
      animatedChild = animationHelper.flyAway(
        animatedChild,
        controller: flyAwayController,
        slideUpDuration: Duration(seconds: 2),
        pauseDuration: Duration(seconds: 2),
        flyAwayDuration: Duration(milliseconds: 1700),
        begin: Offset(0.0, 1.0),                    // Start below original position
        middle: Offset(0.0, -0.3),                  // Center position
        end: Offset(0.0, -6.0),                     // Move offscreen upwards
        initialSlideCurve: Curves.easeOutCubic,     // Gentle start to center
        flyAwayCurve: Curves.easeInCubic,           // Exponential lift-off
        infinite: false,
        onComplete: () {
          PlayFunctions.resetPluginPlayState(appStateProvider, pluginStateKey);
        },
      );
    }




    return Center(
      child: animatedChild,
    );
  }
}

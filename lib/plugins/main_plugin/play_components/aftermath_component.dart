import 'dart:math';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/providers/app_state_provider.dart';
import '../../00_base/module_manager.dart';
import '../functions/animation_helper.dart';
import '../functions/play_functions.dart';

class AfterMathComponent extends StatefulWidget {
  const AfterMathComponent({Key? key}) : super(key: key);

  @override
  AfterMathComponentState createState() => AfterMathComponentState();
}

class AfterMathComponentState extends State<AfterMathComponent> with TickerProviderStateMixin {
  late final AnimationController slideUpAndDownController;
  late final AnimationController flyAwayController;
  late final AnimationHelper animationHelper;

  String? animationImageUrl;

  // Hardcoded lists of animations
  final List<String> correctAnimations = [
    'assets/animations/after_animations/correct_anim/elmo-fire012.gif',
    'assets/animations/after_animations/correct_anim/skib.gif',
  ];

  final List<String> incorrectAnimations = [
    'assets/animations/after_animations/incorrect_anim/angel-wings-white.gif',
    'assets/animations/after_animations/incorrect_anim/rocket.gif',
  ];

  String? lastPlayState; // Keep track of the last play state

  @override
  void initState() {
    super.initState();
    animationHelper = AnimationHelper();
    slideUpAndDownController = AnimationController(vsync: this);
    flyAwayController = AnimationController(vsync: this);

    // Register controllers
    AnimationHelper.registerController(slideUpAndDownController);
    AnimationHelper.registerController(flyAwayController);
  }

  @override
  void dispose() {
    // Dispose controllers safely
    AnimationHelper.disposeController(slideUpAndDownController);
    AnimationHelper.disposeController(flyAwayController);
    super.dispose();
  }

  void _playAudioForAnimation(String playState, String animation) {
    final audioHelper = ModuleManager().getInstance<dynamic>("AudioHelper");

    if (playState == 'aftermath_correct') {
      if (animation.contains('skib.gif')) {
        audioHelper?.playSpecific(
          context,
          audioHelper.correctAfter,
          "skibidi",
        );
      } else {
        audioHelper?.playFromList(
          context,
          audioHelper.correctAfter,
        );
      }
    } else if (playState == 'aftermath_incorrect') {
      try {
        audioHelper?.playFromList(
          context,
          audioHelper.incorrectAfter,
        );
        dev.log('Played aftermath_incorrect sound.');
      } catch (e, stackTrace) {
        dev.log('Error playing aftermath_incorrect sound: $e', stackTrace: stackTrace);
      }
    }
  }

  void _selectRandomAnimation(String playState) {
    if (playState == 'aftermath_correct') {
      animationImageUrl = correctAnimations.isNotEmpty
          ? correctAnimations[Random().nextInt(correctAnimations.length)]
          : null;
    } else if (playState == 'aftermath_incorrect') {
      animationImageUrl = incorrectAnimations.isNotEmpty
          ? incorrectAnimations[Random().nextInt(incorrectAnimations.length)]
          : null;
    } else {
      animationImageUrl = null; // Reset if not in aftermath state
    }

    if (animationImageUrl != null) {
      _playAudioForAnimation(playState, animationImageUrl!); // Trigger audio for the chosen animation
    }
  }

  @override
  Widget build(BuildContext context) {
    final appStateProvider = Provider.of<AppStateProvider>(context, listen: false);
    final pluginStateKey = "MainPluginState";

    final playState = context.select<AppStateProvider, String?>((appStateProvider) {
      final pluginState = appStateProvider.getPluginState<Map<String, dynamic>>(pluginStateKey) ?? {};
      return pluginState['play_state'] as String?;
    });
    final audioHelper = ModuleManager().getInstance<dynamic>("AudioHelper");

    lastPlayState = playState;

    _selectRandomAnimation(playState!);

    final screenWidth = MediaQuery.of(context).size.width;
    final imageSize = screenWidth * 0.8;

    Widget animatedChild = animationImageUrl != null && animationImageUrl!.isNotEmpty
        ? Image.asset(
      animationImageUrl!,
      width: imageSize,
      height: imageSize,
      fit: BoxFit.contain,
    )
        : Container(
      width: imageSize,
      height: imageSize,
      color: Colors.grey,
      child: const Icon(Icons.error, color: Colors.red),
    );

    final aftermathAnims = context.select<AppStateProvider, List<String>?>((appStateProvider) {
      final pluginState = appStateProvider.getPluginState<Map<String, dynamic>>(pluginStateKey) ?? {};
      return List<String>.from(pluginState['plugin_anims']?['aftermath_anims'] ?? []);
    });

    if (aftermathAnims != null && aftermathAnims.contains('slideUpAndDown')) {
      animatedChild = animationHelper.slideUpAndDown(
        animatedChild,
        controller: slideUpAndDownController,
        duration: const Duration(seconds: 4),
        begin: const Offset(0.0, 1.0),
        middle: const Offset(0.0, -0.3),
        end: const Offset(0.0, 1.0),
        infinite: false,
        curve: Curves.easeIn,
        onComplete: () {
          PlayFunctions.resetPluginPlayState(appStateProvider, pluginStateKey, context);
        },
      );
    }

    if (aftermathAnims != null && aftermathAnims.contains('flyAway')) {
      animatedChild = animationHelper.flyAway(
        animatedChild,
        controller: flyAwayController,
        slideUpDuration: const Duration(seconds: 2),
        pauseDuration: const Duration(seconds: 2),
        flyAwayDuration: const Duration(milliseconds: 2400),
        begin: const Offset(0.0, 1.0),
        middle: const Offset(0.0, -0.3),
        end: const Offset(0.0, -6.0),
        initialSlideCurve: Curves.easeOutCubic,
        flyAwayCurve: Curves.easeInCubic,
        infinite: false,
        onComplete: () {
          audioHelper?.stopListSounds(audioHelper.incorrectAfter);
          PlayFunctions.resetPluginPlayState(appStateProvider, pluginStateKey, context);
        },
      );
    }

    // Adjust position for incorrect animations
    if (playState == 'aftermath_incorrect') {
      animatedChild = Transform.translate(
        offset: const Offset(0, 70),
        child: animatedChild,
      );
    }

    return Center(
      child: animatedChild,
    );
  }
}

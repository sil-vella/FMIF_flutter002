import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/providers/app_state_provider.dart';
import '../functions/animation_helper.dart';
import '../functions/audio_helper.dart';
import '../functions/play_functions.dart';
import '../main_plugin_main.dart';

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
  }

  @override
  void dispose() {
    slideUpAndDownController.dispose();
    flyAwayController.dispose();
    super.dispose();
  }

  void _playAudioForAnimation(String playState, String animation) {
    final audioHelper = AudioHelper();

    if (playState == 'aftermath_correct') {
      if (animation.contains('skib.gif')) {
        audioHelper.playEffectSound(audioHelper.correctAfter['skibidi']!, context);
      } else {
        final otherAudioKeys = audioHelper.correctAfter.keys
            .where((key) => key != 'skibidi')
            .toList();
        if (otherAudioKeys.isNotEmpty) {
          final randomKey = otherAudioKeys[Random().nextInt(otherAudioKeys.length)];
          audioHelper.playEffectSound(audioHelper.correctAfter[randomKey]!, context);
        }
      }
    } else if (playState == 'aftermath_incorrect') {
      if (animation.contains('rocket.gif')) {
        audioHelper.playEffectSound(audioHelper.incorrectAfter['aftermath_rocket_001']!, context);
      } else if (animation.contains('angel-wings-white.gif')) {
        audioHelper.playEffectSound(audioHelper.incorrectAfter['aftermath_wings_001']!, context);
      } else {
        final incorrectAudioKeys = audioHelper.incorrectAfter.keys
            .where((key) => key != 'aftermath_rocket_001' && key != 'aftermath_wings_001')
            .toList();
        if (incorrectAudioKeys.isNotEmpty) {
          final randomKey = incorrectAudioKeys[Random().nextInt(incorrectAudioKeys.length)];
          audioHelper.playEffectSound(audioHelper.incorrectAfter[randomKey]!, context);
        }
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

    AudioHelper().fadeOutAndStopEffectSounds(); // Fade out and stop sounds

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

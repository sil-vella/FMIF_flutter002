import 'package:FMIF/plugins/main_plugin/functions/play_functions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_state_provider.dart';
import '../functions/animation_helper.dart';
import '../main_plugin_main.dart';

class CelebHeadComponent extends StatefulWidget {
  const CelebHeadComponent({Key? key}) : super(key: key);

  @override
  _CelebHeadComponentState createState() => _CelebHeadComponentState();
}

class _CelebHeadComponentState extends State<CelebHeadComponent>
    with TickerProviderStateMixin {
  late final AnimationController bounceController;
  late final AnimationController sideToSideController;
  late final AnimationController pulseController;
  late final AnimationController shakeController;
  late final AnimationController dropController;

  bool _animationsStarted = false;

  @override
  void initState() {
    super.initState();
    bounceController = AnimationController(vsync: this, duration: Duration(seconds: 2));
    sideToSideController = AnimationController(vsync: this, duration: Duration(seconds: 3));
    pulseController = AnimationController(vsync: this, duration: Duration(seconds: 1));
    shakeController = AnimationController(vsync: this, duration: Duration(milliseconds: 40));
    dropController = AnimationController(vsync: this, duration: Duration(seconds: 2));
  }

  @override
  void dispose() {
    bounceController.dispose();
    sideToSideController.dispose();
    pulseController.dispose();
    shakeController.dispose();
    dropController.dispose();
    super.dispose();
  }

  void startControllers(List<String> animations) {
    for (String animationType in animations) {
      switch (animationType) {
        case 'bounce':
          bounceController.forward();
          break;
        case 'sideToSide':
          sideToSideController.forward();
          break;
        case 'pulse':
          pulseController.forward();
          break;
        case 'shakeAndDrop':
          shakeController.forward();
          dropController.forward();
          break;
      }
    }
  }

  void stopControllers() {
    bounceController.reset();
    sideToSideController.reset();
    pulseController.reset();
    shakeController.reset();
    dropController.reset();
  }

  void handlePlayStateChange(String? playState, List<String> activeAnimations) {
    if (playState == 'in_play' && !_animationsStarted) {
      startControllers(activeAnimations);
      _animationsStarted = true;
    } else if (playState == 'idle' && _animationsStarted) {
      stopControllers();
      _animationsStarted = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pluginStateKey = "${MainPlugin().runtimeType}State";
    final appStateProvider = Provider.of<AppStateProvider>(context, listen: false);

    final playState = context.select<AppStateProvider, String?>(
          (appStateProvider) {
        final pluginState = appStateProvider.getPluginState<Map<String, dynamic>>(pluginStateKey) ?? {};
        return pluginState['play_state'] as String?;
      },
    );

    final activeAnimations = context.select<AppStateProvider, List<String>>(
          (appStateProvider) {
        final pluginState = appStateProvider.getPluginState<Map<String, dynamic>>(pluginStateKey) ?? {};
        return List<String>.from(pluginState['plugin_anims']['head_anims'] ?? []);
      },
    );

    // Check if animations should start or stop based on the playState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      handlePlayStateChange(playState, activeAnimations);
    });

    final String? celebImgUrl = context.select<AppStateProvider, String?>(
          (appStateProvider) {
        final pluginState = appStateProvider.getPluginState<Map<String, dynamic>>(pluginStateKey) ?? {};
        return pluginState['celeb_img_url'] as String?;
      },
    );
    final bool isImageAvailable = celebImgUrl != null && celebImgUrl.isNotEmpty;

    final screenWidth = MediaQuery.of(context).size.width;
    final imageSize = screenWidth * 0.2;

    Widget animatedChild(Widget child) {
      for (String animationType in activeAnimations) {
        switch (animationType) {
          case 'bounce':
            child = AnimationHelper.bounce(
              child,
              controller: bounceController,
              onComplete: () => print("Bounce animation completed"),
            );
            break;
          case 'sideToSide':
            child = AnimationHelper.sideToSide(
              child,
              controller: sideToSideController,
            );
            break;
          case 'pulse':
            child = AnimationHelper.pulse(
              child,
              controller: pulseController,
              onComplete: () => print("Pulse animation completed"),
            );
            break;
          case 'shakeAndDrop':
            child = AnimationHelper.shakeAndDrop(
              child,
              shakeController: shakeController,
              dropController: dropController,
              onComplete: () => PlayFunctions.activateAftermath(appStateProvider, pluginStateKey),
            );
            break;
          default:
            break;
        }
      }
      return child;
    }

    return Center(
      child: SizedBox(
        width: imageSize,
        height: imageSize,
        child: isImageAvailable
            ? animatedChild(
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(celebImgUrl!),
                fit: BoxFit.cover,
              ),
            ),
          ),
        )
            : CircularProgressIndicator(), // Show a loader until the image is available
      ),
    );
  }
}

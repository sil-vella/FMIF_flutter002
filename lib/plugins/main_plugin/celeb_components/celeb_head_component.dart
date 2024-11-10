import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';

import '../../../providers/app_state_provider.dart';
import '../functions/animation_helper.dart';
import '../main_plugin_main.dart';
import '../functions/play_functions.dart';

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
  late final AnimationController slideUpController; // New slideUp controller
  late final AnimationHelper animationHelper;

  @override
  void initState() {
    super.initState();
    animationHelper = AnimationHelper();
    bounceController = AnimationController(vsync: this);
    sideToSideController = AnimationController(vsync: this);
    pulseController = AnimationController(vsync: this);
    shakeController = AnimationController(vsync: this);
    dropController = AnimationController(vsync: this);
    slideUpController = AnimationController(vsync: this); // Initialize slideUp controller
  }

  @override
  void dispose() {
    bounceController.dispose();
    sideToSideController.dispose();
    pulseController.dispose();
    shakeController.dispose();
    dropController.dispose();
    slideUpController.dispose(); // Dispose slideUp controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appStateProvider = Provider.of<AppStateProvider>(context, listen: false);
    final pluginStateKey = "${MainPlugin().runtimeType}State";

    // Check the play state and determine visibility
    final String? playState = context.select<AppStateProvider, String?>(
          (appStateProvider) {
        final pluginState = appStateProvider.getPluginState<Map<String, dynamic>>(pluginStateKey) ?? {};
        return pluginState['play_state'] as String?;
      },
    );

    // Hide the component if play_state is 'idle' or 'aftermath'
    if (playState == 'idle' || playState == 'aftermath') {
      return SizedBox.shrink();
    }

    // Retrieve `headAnims` from `plugin_anims`
    final List<String>? headAnims = context.select<AppStateProvider, List<String>?>(
          (appStateProvider) {
        final pluginState = appStateProvider.getPluginState<Map<String, dynamic>>(pluginStateKey) ?? {};
        return List<String>.from(pluginState['plugin_anims']?['head_anims'] ?? []);
      },
    );

    final String? celebImgUrl = context.select<AppStateProvider, String?>(
          (appStateProvider) {
        final pluginState = appStateProvider.getPluginState<Map<String, dynamic>>(pluginStateKey) ?? {};
        return pluginState['celeb_img_url'] as String?;
      },
    );

    final bool isImageAvailable = celebImgUrl != null && celebImgUrl.isNotEmpty;
    final screenWidth = MediaQuery.of(context).size.width;
    final imageSize = screenWidth * 0.2;

    Widget animatedChild = Container(
      width: imageSize,
      height: imageSize,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(celebImgUrl ?? ''),
          fit: BoxFit.cover,
        ),
      ),
    );

    // Apply animations based on contents of `headAnims`
    if (headAnims != null) {
      if (headAnims.contains('bounce')) {
        animatedChild = animationHelper.bounce(
          animatedChild,
          controller: bounceController,
          duration: Duration(seconds: 2),
          begin: Offset(0.0, -0.1),
          end: Offset(0.0, 0.1),
          curve: Curves.easeInOut,
          infinite: true,
        );
      }
      if (headAnims.contains('sideToSide')) {
        animatedChild = animationHelper.sideToSide(
          animatedChild,
          controller: sideToSideController,
          duration: Duration(seconds: 3),
          begin: Offset(-0.05, 0.0),
          end: Offset(0.05, 0.0),
          curve: Curves.easeInOut,
          infinite: true,
        );
      }
      if (headAnims.contains('pulse')) {
        animatedChild = animationHelper.pulse(
          animatedChild,
          controller: pulseController,
          duration: Duration(seconds: 1),
          begin: 0.9,
          end: 1.0,
          curve: Curves.easeInOut,
          infinite: true,
        );
      }
      if (headAnims.contains('shakeAndDrop')) {
        animatedChild = animationHelper.shakeAndDrop(
          animatedChild,
          shakeController: shakeController,
          dropController: dropController,
          shakeDuration: Duration(milliseconds: 100),
          shakeTotalDuration: Duration(seconds: 4),
          dropDuration: Duration(seconds: 2),
          dropStartDelay: Duration(seconds: 2),
          shakeBegin: Offset(-10.0, 0.0),
          shakeEnd: Offset(10.0, 0.0),
          dropBegin: Offset(0.0, 0.0),
          dropEnd: Offset(0.0, 100.0),
          shakeCurve: Curves.easeInOut,
          dropCurve: Curves.easeIn,
          infinite: false,
          onComplete: () {
            PlayFunctions.activateAftermath(appStateProvider, pluginStateKey);
          },
        );
      }
      if (headAnims.contains('slideUp')) {
        animatedChild = animationHelper.slideUp(
          animatedChild,
          controller: slideUpController,
          duration: Duration(seconds: 1),
          begin: Offset(0.0, 1.0),
          end: Offset(0.0, 0.0),
          infinite: false,
          onComplete: () {
            print("Slide up animation completed");
          },
        );
      }
    }

    // Center the widget without initial offset
    return Center(
      child: animatedChild,
    );
  }


}

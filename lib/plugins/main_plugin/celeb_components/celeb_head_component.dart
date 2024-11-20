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
  late final AnimationController slideUpController;
  late final AnimationController flyAwayController;
  late final AnimationController flashController; // Controller for flashing text

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
    slideUpController = AnimationController(vsync: this);
    flyAwayController = AnimationController(vsync: this);
    flashController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    )..repeat(reverse: true); // Repeating for flashing effect
  }

  @override
  void dispose() {
    bounceController.dispose();
    sideToSideController.dispose();
    pulseController.dispose();
    shakeController.dispose();
    dropController.dispose();
    slideUpController.dispose();
    flyAwayController.dispose();
    flashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appStateProvider = Provider.of<AppStateProvider>(context, listen: false);
    final pluginStateKey = "${MainPlugin().runtimeType}State";
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Check the play state and determine visibility
    final String? playState = context.select<AppStateProvider, String?>(
          (appStateProvider) {
        final pluginState = appStateProvider.getPluginState<Map<String, dynamic>>(pluginStateKey) ?? {};
        return pluginState['play_state'] as String?;
      },
    );

    // Determine when to show the "Incorrect!!" text and celeb image
    final bool showText = playState == 'revealed_incorrect' ||
        playState == 'aftermath_incorrect' ||
        playState == 'revealed_correct' ||
        playState == 'aftermath_correct';
    final bool showCelebImage = playState != 'idle' && playState != 'aftermath_correct';

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

    final screenWidth = MediaQuery.of(context).size.width;
    final imageSize = screenWidth * 0.2;

    // Celeb image container with loading indicator and error handling
    Widget animatedChild = celebImgUrl != null && celebImgUrl.isNotEmpty
        ? FutureBuilder(
      future: precacheImage(NetworkImage(celebImgUrl), context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Container(
            width: imageSize,
            height: imageSize,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(celebImgUrl),
                fit: BoxFit.cover,
              ),
            ),
          );
        } else {
          return SizedBox(
            width: imageSize,
            height: imageSize,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    )
        : Container(
      width: imageSize,
      height: imageSize,
      color: Colors.grey, // Placeholder color or local asset for missing image
      child: Icon(Icons.error, color: Colors.red),
    );

    // Apply animations based on contents of `headAnims`
    if (showCelebImage && headAnims != null) {
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
          dropDuration: Duration(milliseconds: 1800),
          dropStartDelay: Duration(milliseconds: 1000),
          shakeBegin: Offset(-3.0, 0.0),
          shakeEnd: Offset(3.0, 0.0),
          dropBegin: Offset(0.0, 0.0),
          dropEnd: Offset(0.0, 150.0),
          shakeCurve: CustomShakeCurve(
            accelerationFactor: 1.0, // Adjust the acceleration
            decelerationFactor: 0.2, // Adjust the deceleration
          ),
          dropCurve: Curves.easeIn,
          infinite: false,
          onComplete: () {
            PlayFunctions.activateAftermath(appStateProvider, pluginStateKey, context);
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
          onComplete: () {},
        );
      }
      if (headAnims.contains('flyAway')) {
        animatedChild = animationHelper.flyAway(
          animatedChild,
          controller: flyAwayController,
          slideUpDuration: Duration(seconds: 2),
          pauseDuration: Duration(seconds: 2),
          flyAwayDuration: Duration(milliseconds: 1500),
          begin: Offset(0.0, 0.0),
          middle: Offset(0.0, 0.0),
          end: Offset(0.0, -6.0),
          initialSlideCurve: Curves.easeOutCubic,
          flyAwayCurve: Curves.easeInCubic,
          infinite: false,
          onComplete: () {},
        );
      }
    }

    // Add the flashing "Incorrect!!" text positioned 1/3 from the top of the screen
    return Stack(
      children: [
        if (showText)
          Positioned(
            top: MediaQuery.of(context).size.height * 0.11,
            left: MediaQuery.of(context).size.width * 0.125,
            right: MediaQuery.of(context).size.width * 0.125,
            child: FadeTransition(
              opacity: flashController.drive(
                Tween(begin: 0.3, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)),
              ),
              child: Text(
                playState == 'revealed_correct' || playState == 'aftermath_correct'
                    ? "Correct!!"
                    : "Incorrect!!",
                textAlign: TextAlign.center,
                style: textTheme.headlineMedium?.copyWith(
                  fontSize: screenWidth * 0.1,
                  fontWeight: FontWeight.bold,
                  color: playState == 'revealed_correct' || playState == 'aftermath_correct'
                      ? colorScheme.primary
                      : colorScheme.error,
                  shadows: [
                    Shadow(
                      blurRadius: 20.0,
                      color: colorScheme.background,
                      offset: Offset(0, 0),
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (showCelebImage)
          Center(child: animatedChild),
      ],
    );
  }
}

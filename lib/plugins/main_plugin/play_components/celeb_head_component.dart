import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../services/providers/app_state_provider.dart';
import '../functions/animation_helper.dart';
import '../functions/play_functions.dart';
import '../main_plugin_main.dart';

class CelebHeadComponent extends StatefulWidget {
  const CelebHeadComponent({Key? key}) : super(key: key);

  @override
  CelebHeadComponentState createState() => CelebHeadComponentState();
}

class CelebHeadComponentState extends State<CelebHeadComponent> with TickerProviderStateMixin {
  late final AnimationController bounceController;
  late final AnimationController sideToSideController;
  late final AnimationController pulseController;
  late final AnimationController shakeController;
  late final AnimationController dropController;
  late final AnimationController slideUpController;
  late final AnimationController flyAwayController;
  late final AnimationController flashController;

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
      duration: const Duration(seconds: 1),
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
    final pluginStateKey = "${MainPlugin().runtimeType}State";
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Retrieve the play state from the app state provider
    final String? playState = context.select<AppStateProvider, String?>(
          (appStateProvider) {
        final pluginState = appStateProvider.getPluginState<Map<String, dynamic>>(pluginStateKey) ?? {};
        return pluginState['play_state'] as String?;
      },
    );

    // Determine visibility of text and image
    final bool showText = playState == 'revealed_incorrect' ||
        playState == 'aftermath_incorrect' ||
        playState == 'revealed_correct' ||
        playState == 'aftermath_correct';
    final bool showCelebImage = playState != 'idle' && playState != 'aftermath_correct';

    // Retrieve animation list and image URL
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

    // Create an animated child for the celeb image
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
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    )
        : Container(
      width: imageSize,
      height: imageSize,
      color: Colors.grey,
      child: const Icon(Icons.error, color: Colors.red),
    );

    // Apply animations based on contents of `headAnims`
    if (showCelebImage && headAnims != null) {
      if (headAnims.contains('bounce')) {
        animatedChild = animationHelper.bounce(
          animatedChild,
          controller: bounceController,
          duration: const Duration(seconds: 2),
          begin: const Offset(0.0, -0.1),
          end: const Offset(0.0, 0.1),
          curve: Curves.easeInOut,
          infinite: true,
        );
      }
      if (headAnims.contains('sideToSide')) {
        animatedChild = animationHelper.sideToSide(
          animatedChild,
          controller: sideToSideController,
          duration: const Duration(seconds: 3),
          begin: const Offset(-0.05, 0.0),
          end: const Offset(0.05, 0.0),
          curve: Curves.easeInOut,
          infinite: true,
        );
      }
      if (headAnims.contains('pulse')) {
        animatedChild = animationHelper.pulse(
          animatedChild,
          controller: pulseController,
          duration: const Duration(seconds: 1),
          begin: 0.9,
          end: 1.0,
          curve: Curves.easeInOut,
          infinite: true,
        );
      }
      if (headAnims.contains('shakeAndDrop')) {
        final appStateProvider = Provider.of<AppStateProvider>(context, listen: false); // Access AppStateProvider

        animatedChild = animationHelper.shakeAndDrop(
          animatedChild,
          shakeController: shakeController,
          dropController: dropController,
          shakeDuration: const Duration(milliseconds: 100),
          shakeTotalDuration: const Duration(seconds: 4),
          dropDuration: const Duration(milliseconds: 1800),
          dropStartDelay: const Duration(milliseconds: 1000),
          shakeBegin: const Offset(-3.0, 0.0),
          shakeEnd: const Offset(3.0, 0.0),
          dropBegin: const Offset(0.0, 0.0),
          dropEnd: const Offset(0.0, 150.0),
          shakeCurve: const CustomShakeCurve(
            accelerationFactor: 1.0, // Adjust the acceleration
            decelerationFactor: 0.2, // Adjust the deceleration
          ),
          dropCurve: Curves.easeIn,
          infinite: false,
          onComplete: () {
            // Call activateAftermath when animation completes
            PlayFunctions.activateAftermath(
              appStateProvider,
              pluginStateKey,
              context,
            );
          },
        );
      }

      if (headAnims.contains('slideUp')) {
        animatedChild = animationHelper.slideUp(
          animatedChild,
          controller: slideUpController,
          duration: const Duration(seconds: 1),
          begin: const Offset(0.0, 1.0),
          end: const Offset(0.0, 0.0),
          infinite: false,
          onComplete: () {},
        );
      }
      if (headAnims.contains('flyAway')) {
        animatedChild = animationHelper.flyAway(
          animatedChild,
          controller: flyAwayController,
          slideUpDuration: const Duration(seconds: 2),
          pauseDuration: const Duration(seconds: 2),
          flyAwayDuration: const Duration(milliseconds: 1500),
          begin: const Offset(0.0, 0.0),
          middle: const Offset(0.0, 0.0),
          end: const Offset(0.0, -6.0),
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
                Tween(begin: 0.3, end: 1.0)
                    .chain(CurveTween(curve: Curves.easeInOut)),
              ),
              child: Text(
                playState == 'revealed_correct' ||
                    playState == 'aftermath_correct'
                    ? "Correct!!"
                    : "Incorrect!!",
                textAlign: TextAlign.center,
                style: textTheme.headlineMedium?.copyWith(
                  fontSize: screenWidth * 0.1,
                  fontWeight: FontWeight.bold,
                  color: playState == 'revealed_correct' ||
                      playState == 'aftermath_correct'
                      ? colorScheme.primary
                      : colorScheme.error,
                  shadows: [
                    Shadow(
                      blurRadius: 20.0,
                      color: colorScheme.surface,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (showCelebImage) Center(child: animatedChild),
      ],
    );
  }
}
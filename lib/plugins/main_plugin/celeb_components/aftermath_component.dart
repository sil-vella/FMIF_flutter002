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
  String? animationImageUrl;

  @override
  void initState() {
    super.initState();
    animationHelper = AnimationHelper();
    slideUpAndDownController = AnimationController(vsync: this);
    flyAwayController = AnimationController(vsync: this);
    loadAnimationImage();
  }

  @override
  void dispose() {
    slideUpAndDownController.dispose();
    flyAwayController.dispose();
    super.dispose();
  }

  void loadAnimationImage() {
    // Determine which URL to use based on play_state
    final appStateProvider = Provider.of<AppStateProvider>(context, listen: false);
    final pluginStateKey = "${MainPlugin().runtimeType}State";
    final playState = appStateProvider.getPluginState<Map<String, dynamic>>(pluginStateKey)?['play_state'];

    // Fetch correct or incorrect animation URL from pluginState
    final pluginState = appStateProvider.getPluginState<Map<String, dynamic>>(pluginStateKey) ?? {};
    animationImageUrl = (playState == 'aftermath_correct')
        ? pluginState['correct_anim']
        : pluginState['incorrect_anim'];

    setState(() {}); // Trigger rebuild with updated URL
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

    // Display a network image from the retrieved URL or fallback to a default image with loading and error handling
    Widget animatedChild = animationImageUrl != null && animationImageUrl!.isNotEmpty
        ? FutureBuilder(
      future: precacheImage(NetworkImage(animationImageUrl!), context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Container(
            width: imageSize,
            height: imageSize,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(animationImageUrl!),
                fit: BoxFit.cover,
              ),
            ),
          );
        } else {
          return SizedBox(
            width: imageSize,
            height: imageSize,
            child: Center(child: CircularProgressIndicator()),
          );
        }
      },
    )
        : Container(
      width: imageSize,
      height: imageSize,
      color: Colors.grey,
      child: Icon(Icons.error, color: Colors.red),
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

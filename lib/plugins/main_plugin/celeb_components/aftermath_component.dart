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
  late final AnimationHelper animationHelper;
  String? randomImagePath;

  @override
  void initState() {
    super.initState();
    animationHelper = AnimationHelper();
    slideUpAndDownController = AnimationController(vsync: this, duration: Duration(seconds: 4));
    loadRandomImage();
  }

  @override
  void dispose() {
    slideUpAndDownController.dispose();
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
    final appStateProvider = Provider.of<AppStateProvider>(context, listen: false);
    final pluginStateKey = "${MainPlugin().runtimeType}State";

    // Listen for animation settings from `plugin_anims`
    final List<String>? aftermathAnims = context.select<AppStateProvider, List<String>?>(
          (appStateProvider) {
        final pluginState = appStateProvider.getPluginState<Map<String, dynamic>>(pluginStateKey) ?? {};
        final animations = List<String>.from(pluginState['plugin_anims']?['aftermath_anims'] ?? []);
        return animations;
      },
    );

    final isAftermathState = context.select<AppStateProvider, bool>((appStateProvider) {
      final pluginState = appStateProvider.getPluginState<Map<String, dynamic>>(pluginStateKey) ?? {};
      return pluginState['play_state'] == 'aftermath';
    });

    if (!isAftermathState) {
      return SizedBox.shrink();
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final imageSize = screenWidth * 0.2;

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

    // Apply `slideUpAndDown` animation if it's specified in the state
    if (aftermathAnims != null && aftermathAnims.contains('slideUpAndDown')) {
      animatedChild = animationHelper.slideUpAndDown(
        animatedChild,
        controller: slideUpAndDownController,
        duration: Duration(seconds: 4),
        begin: Offset(0.0, 0.0),          // Start at -100% offset
        middle: Offset(0.0, -1.0),          // Pause at original position
        end: Offset(0.0, 0.0),            // End at -100% offset
        infinite: false,
        onComplete: () {
          PlayFunctions.resetPluginPlayState(appStateProvider, pluginStateKey);
        },
      );
    }

    // Center the widget with initial offset
    return Center(
      child: Transform.translate(
        offset: Offset(0, imageSize),
        child: animatedChild,
      ),
    );
  }
}

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

  @override
  Widget build(BuildContext context) {
    final appStateProvider = Provider.of<AppStateProvider>(context, listen: false);
    final pluginStateKey = "${MainPlugin().runtimeType}State";

    // Retrieve `headAnims` from `plugin_anims` and check its contents
    final List<String>? headAnims = context.select<AppStateProvider, List<String>?>(
          (appStateProvider) {
        final pluginState = appStateProvider.getPluginState<Map<String, dynamic>>(pluginStateKey) ?? {};
        final headAnims = List<String>.from(pluginState['plugin_anims']?['head_anims'] ?? []);
        print("Current headAnims: $headAnims"); // Debug output for headAnims list
        return headAnims;
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
        print('Applying bounce animation');
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
        print('Applying sideToSide animation');
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
        print('Applying pulse animation');
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
        print('Applying shakeAndDrop animation');
        animatedChild = animationHelper.shakeAndDrop(
          animatedChild,
          shakeController: shakeController,
          dropController: dropController,
          shakeDuration: Duration(milliseconds: 100),  // Fast shake cycles
          shakeTotalDuration: Duration(seconds: 4),    // Total shake time
          dropDuration: Duration(seconds: 2),          // Drop for 2 seconds
          dropStartDelay: Duration(seconds: 2),        // Drop starts after 2 seconds
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


    }

    return Center(
      child: SizedBox(
        width: imageSize,
        height: imageSize,
        child: isImageAvailable ? animatedChild : CircularProgressIndicator(),
      ),
    );
  }
}

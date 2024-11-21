import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../providers/app_state_provider.dart';
import '../functions/animation_helper.dart';
import '../main_plugin_main.dart';

class RibbonComponent extends StatefulWidget {
  const RibbonComponent({Key? key}) : super(key: key);

  @override
  _RibbonComponentState createState() => _RibbonComponentState();
}

class _RibbonComponentState extends State<RibbonComponent>
    with TickerProviderStateMixin {
  late final AnimationController leftTapeController;
  late final AnimationController rightTapeController;
  late final AnimationController centerTapeController;
  late final AnimationHelper animationHelper;

  @override
  void initState() {
    super.initState();
    animationHelper = AnimationHelper();
    leftTapeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    rightTapeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    centerTapeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
  }

  @override
  void dispose() {
    leftTapeController.dispose();
    rightTapeController.dispose();
    centerTapeController.dispose();
    super.dispose();
  }

  Future<String> _loadCategory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('celeb_category') ?? 'default';
  }

  Future<String> _getBackgroundImagePath(String category) async {
    final backgroundImagePath = 'assets/images/tape_$category.png';

    try {
      await rootBundle.load(backgroundImagePath);
      return backgroundImagePath;
    } catch (e) {
      return 'assets/images/tape001.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final pluginStateKey = "${MainPlugin().runtimeType}State";

    final String? playState = context.select<AppStateProvider, String?>((appStateProvider) {
      final pluginState = appStateProvider.getPluginState<Map<String, dynamic>>(pluginStateKey) ?? {};
      return pluginState['play_state'] as String?;
    });

    final bool flushing = context.select<AppStateProvider, bool>((appStateProvider) {
      final pluginState = appStateProvider.getPluginState<Map<String, dynamic>>(pluginStateKey) ?? {};
      return pluginState['flushing'] as bool? ?? false;
    });

    if (flushing || (playState != 'in_play' && playState != 'revealed_correct' && playState != 'revealed_incorrect')) {
      return const SizedBox.shrink();
    }

    final List<String> ribbonAnims = List<String>.from(
      context.select<AppStateProvider, List<dynamic>?>((appStateProvider) {
        final pluginState = appStateProvider.getPluginState<Map<String, dynamic>>(pluginStateKey) ?? {};
        return pluginState['plugin_anims']?['ribbon_anims'] ?? [];
      }) ?? [],
    );

    return FutureBuilder<String>(
      future: _loadCategory(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final category = snapshot.data!;
        return FutureBuilder<String>(
          future: _getBackgroundImagePath(category),
          builder: (context, imageSnapshot) {
            if (imageSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final imagePath = imageSnapshot.data!;

            Widget leftTape = Transform.translate(
              offset: const Offset(0, -20),
              child: Transform.rotate(
                angle: -5 * (pi / 180),
                child: Transform.scale(
                  scale: 1.4,
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            );

            Widget rightTape = Transform.translate(
              offset: const Offset(0, -5),
              child: Transform.rotate(
                angle: 5 * (pi / 180),
                child: Transform.scale(
                  scale: 1.2,
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            );

            Widget centerTape = Transform.translate(
              offset: const Offset(0, 5),
              child: Transform.scale(
                scale: 1.5,
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            );

            // Apply individual animations with Y-axis translation and respective pivots
            if (playState == 'revealed_correct' || playState == 'revealed_incorrect') {
              if (ribbonAnims.contains('cut_tape')) {
                leftTape = animationHelper.cutTape(
                  leftTape,
                  controller: leftTapeController,
                  duration: const Duration(seconds: 1),
                  pivot: Alignment.centerLeft,
                  rotationEnd: 90 * (pi / 180),
                  translateY: 600.0, // Move to the bottom of the screen
                  onComplete: () {
                    print("Left tape animation completed");
                  },
                );

                rightTape = animationHelper.cutTape(
                  rightTape,
                  controller: rightTapeController,
                  duration: const Duration(seconds: 1),
                  pivot: Alignment.centerRight,
                  rotationEnd: -90 * (pi / 180),
                  translateY: 600.0, // Move to the bottom of the screen
                  onComplete: () {
                    print("Right tape animation completed");
                  },
                );

                centerTape = animationHelper.cutTape(
                  centerTape,
                  controller: centerTapeController,
                  duration: const Duration(seconds: 1),
                  pivot: Alignment.centerLeft,
                  rotationEnd: 90 * (pi / 180),
                  translateY: 600.0, // Move to the bottom of the screen
                  onComplete: () {
                    print("Center tape animation completed");
                  },
                );
              }
            }

            return Stack(
              alignment: Alignment.center,
              children: [leftTape, rightTape, centerTape],
            );
          },
        );
      },
    );
  }
}

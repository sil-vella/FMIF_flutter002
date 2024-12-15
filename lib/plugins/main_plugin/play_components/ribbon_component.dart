import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../services/providers/app_state_provider.dart';
import '../functions/animation_helper.dart';
import '../main_plugin_main.dart';

class RibbonComponent extends StatefulWidget {
  const RibbonComponent({Key? key}) : super(key: key);

  @override
  RibbonComponentState createState() => RibbonComponentState();
}

class RibbonComponentState extends State<RibbonComponent>
    with TickerProviderStateMixin {
  late final AnimationController leftTapeController;
  late final AnimationController rightTapeController;
  late final AnimationController centerTapeController;
  late final AnimationHelper animationHelper;

  bool hasCutTapeAnimationPlayed = false; // Track if animation has already played

  @override
  void initState() {
    super.initState();
    animationHelper = AnimationHelper();

    // Initialize animation controllers
    leftTapeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..value = 1.0; // Start at the end position

    rightTapeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..value = 1.0; // Start at the end position

    centerTapeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..value = 1.0; // Start at the end position
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
    final pluginStateKey = "MainPluginState";

    final String? playState = context.select<AppStateProvider, String?>((appStateProvider) {
      final pluginState = appStateProvider.getPluginState<Map<String, dynamic>>(pluginStateKey) ?? {};
      return pluginState['play_state'] as String?;
    });

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

            // Create initial tape widgets
            Widget leftTape = _buildTape(imagePath, offset: const Offset(0, -20), angle: -5, scale: 1.4);
            Widget rightTape = _buildTape(imagePath, offset: const Offset(0, -5), angle: 5, scale: 1.2);
            Widget centerTape = _buildTape(imagePath, offset: const Offset(0, 5), angle: 0, scale: 1.5);

            if (ribbonAnims.contains('cut_tape') && !hasCutTapeAnimationPlayed) {
              hasCutTapeAnimationPlayed = true; // Mark animation as played

              // Apply cut tape animations
              leftTape = animationHelper.cutTape(
                leftTape,
                controller: leftTapeController,
                duration: const Duration(seconds: 1),
                pivot: Alignment.centerLeft,
                rotationEnd: 90 * (pi / 180),
                translateY: 600.0,
                onComplete: () {
                  leftTapeController.value = 1.0; // Ensure it stays at the end position
                },
              );

              rightTape = animationHelper.cutTape(
                rightTape,
                controller: rightTapeController,
                duration: const Duration(seconds: 1),
                pivot: Alignment.centerRight,
                rotationEnd: -90 * (pi / 180),
                translateY: 600.0,
                onComplete: () {
                  rightTapeController.value = 1.0; // Ensure it stays at the end position
                },
              );

              centerTape = animationHelper.cutTape(
                centerTape,
                controller: centerTapeController,
                duration: const Duration(seconds: 1),
                pivot: Alignment.centerLeft,
                rotationEnd: 90 * (pi / 180),
                translateY: 600.0,
                onComplete: () {
                  centerTapeController.value = 1.0; // Ensure it stays at the end position
                },
              );
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

  Widget _buildTape(String imagePath,
      {required Offset offset, required double angle, required double scale}) {
    return Transform.translate(
      offset: offset,
      child: Transform.rotate(
        angle: angle * (pi / 180),
        child: Transform.scale(
          scale: scale,
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
  }
}

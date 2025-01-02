import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/providers/app_state_provider.dart';
import '../../../screens/base_screen.dart';
import '../../../utils/consts/theme_consts.dart';
import '../../00_base/module_manager.dart';
import '../play_components/timer_clock_component.dart';
import '../play_components/ribbon_component.dart';
import '../play_components/celeb_facts_component.dart';
import '../play_components/celeb_head_component.dart';
import '../play_components/main_background_component.dart';
import '../play_components/aftermath_component.dart';
import '../play_components/aftermath_anim_component.dart';
import '../play_components/name_buttons_component.dart';
import '../play_components/main_background_overlay_component.dart';
import '../functions/play_functions.dart';

class GameScreen extends BaseScreen {
  const GameScreen({Key? key}) : super(key: key);

  @override
  String computeTitle(BuildContext context) {
    return "Flush Me I'm Famous";
  }

  @override
  GameScreenState createState() => GameScreenState();
}

class GameScreenState extends BaseScreenState<GameScreen> with SingleTickerProviderStateMixin {
  late AppStateProvider _appStateProvider;
  String category = "Unknown";
  String level = "N/A";
  String points = "-";

  @override
  void initState() {
    super.initState();
    _appStateProvider = Provider.of<AppStateProvider>(context, listen: false);

    if (_appStateProvider.getMainAppState('main_state') != 'in_play') {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await PlayFunctions.handlePlayButton(_appStateProvider, context);
      });
    }

    _loadSharedPreferences();
  }

  Future<void> _loadSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      category = prefs.getString('celeb_category') ?? "Unknown";

      final categoryLevels = prefs.getString('category_levels') ?? "{}";
      final categoryLevelsMap = Map<String, dynamic>.from(
        jsonDecode(categoryLevels),
      );

      final currentLevelKey = 'level_${category.replaceAll(" ", "_").toLowerCase()}';
      level = categoryLevelsMap[currentLevelKey]?.toString() ?? "N/A";

      points = prefs.getInt('points')?.toString() ?? "-";
    });
  }

  @override
  Widget buildContent(BuildContext context) {
    debugPrint("GameScreenState - buildContent called");

    // Listen for `play_state` changes
    final playState = context.select<AppStateProvider, String?>((appStateProvider) {
      final mainPluginState = appStateProvider.getPluginState<Map<String, dynamic>>("MainPluginState") ?? {};
      return mainPluginState['play_state'] as String?;
    });

    final flushing = context.select<AppStateProvider, bool>((appStateProvider) {
      final mainPluginState = appStateProvider.getPluginState<Map<String, dynamic>>("MainPluginState") ?? {};
      return mainPluginState['flushing'] as bool? ?? false;
    });

    return Column(
      children: [
        // Displaying Category, Level, and Points
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          color: AppColors.accentColor2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "$category (Level: $level)",
                style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              Text(
                "Points: $points",
                style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ],
          ),
        ),

        // Stack for the game content
        Expanded(
          child: Stack(
            children: [
              Positioned.fill(child: const MainBackgroundComponent()),

              if (playState == 'aftermath_correct' || playState == 'aftermath_incorrect')
                Positioned.fill(child: const AfterMathComponent()),

              Positioned.fill(child: const CelebHeadComponent()),

              Positioned.fill(child: const MainBackgroundOverlayComponent()),

              if (!flushing && (playState == 'in_play' || playState == 'revealed_correct' || playState == 'revealed_incorrect'))
                Positioned.fill(child: const RibbonComponent()),

              if (playState == 'aftermath_correct')
                Positioned.fill(child: const AfterMathAnimComponent()),

              if (playState == 'in_play' || playState == 'revealed_correct')
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: NameButtonsComponent(),
                ),

              if (playState == 'in_play')
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TimerClockComponent(),
                      const SingleChildScrollView(
                        child: CelebFactsComponent(),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

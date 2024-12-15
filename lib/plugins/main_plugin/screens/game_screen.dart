import 'package:flush_me_im_famous/plugins/main_plugin/play_components/timer_clock_component.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/providers/app_state_provider.dart';
import '../../../screens/base_screen.dart';
import '../../../utils/consts/theme_consts.dart';
import '../play_components/ribbon_component.dart';
import '../play_components/celeb_facts_component.dart';
import '../play_components/celeb_head_component.dart';
import '../play_components/main_background_component.dart';
import '../play_components/aftermath_component.dart';
import '../play_components/aftermath_anim_component.dart';
import '../play_components/name_buttons_component.dart';
import '../play_components/main_background_overlay_component.dart';
import '../functions/play_functions.dart';
import '../functions/audio_helper.dart';

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

  @override
  void initState() {
    super.initState();
    _appStateProvider = Provider.of<AppStateProvider>(context, listen: false);

    // Auto-play background music playlist
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await AudioHelper().playBackgroundPlaylist(
        audioPaths: [
          'audio/background_pt_1_002.mp3',
          'audio/background_pt2_003.mp3',
        ],
        context: context,
      );
    });

    if (_appStateProvider.getMainAppState('main_state') != 'in_play') {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await PlayFunctions.handlePlayButton(_appStateProvider, context);
      });
    }
  }

  @override
  void dispose() {
    AudioHelper().stopBackgroundSound();
    super.dispose();
  }

  @override
  Widget buildContent(BuildContext context) {
    final appStateProvider = Provider.of<AppStateProvider>(context, listen: false);
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
        Selector<AppStateProvider, Map<String, dynamic>>(
          selector: (context, provider) {
            final mainPluginState = provider.getPluginState<Map<String, dynamic>>("MainPluginState") ?? {};
            final loginPluginState = provider.getPluginState<Map<String, dynamic>>("LoginPluginState") ?? {};
            return {
              "celeb_category": mainPluginState['celeb_category'] ?? "Unknown",
              "category_levels": loginPluginState['category_levels'] ?? {},
              "points": loginPluginState['points'] ?? "-"
            };
          },
          builder: (context, pluginState, child) {
            final category = pluginState['celeb_category'] ?? "Unknown";
            final categoryLevels = pluginState['category_levels'] ?? {};
            final currentLevelKey = 'level_${category.replaceAll(" ", "_").toLowerCase()}';
            final level = categoryLevels[currentLevelKey] ?? "N/A";
            final points = pluginState['points'] ?? "-";

            return Container(
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
            );
          },
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

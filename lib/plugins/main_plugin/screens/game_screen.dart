import 'package:flush_me_im_famous/plugins/main_plugin/celeb_components/ribbon_component.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flush_me_im_famous/plugins/main_plugin/celeb_components/celeb_facts_component.dart';
import 'package:flush_me_im_famous/plugins/main_plugin/celeb_components/celeb_head_component.dart';
import 'package:flush_me_im_famous/plugins/main_plugin/celeb_components/main_background_component.dart';
import 'package:flush_me_im_famous/plugins/main_plugin/celeb_components/aftermath_component.dart';
import '../../../providers/app_state_provider.dart';
import '../../../screens/base_screen.dart';
import '../../../utils/consts/theme_consts.dart';
import '../celeb_components/aftermath_anim_component.dart';
import '../celeb_components/name_buttons_component.dart';
import '../celeb_components/main_background_overlay_component.dart';
import '../functions/play_functions.dart';
import '../functions/audio_helper.dart';

class GameScreen extends BaseScreen {
  const GameScreen({Key? key}) : super(key: key);

  @override
  String computeTitle(BuildContext context) {
    // Return a fixed title for the screen
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
    debugPrint("GameScreenState - buildContent called"); // Debug rebuilds
    return Column(
      children: [
        // Use Selector to display Level and Points
        Selector<AppStateProvider, Map<String, dynamic>>(
          selector: (context, provider) =>
          provider.getPluginState<Map<String, dynamic>>("LoginPluginState") ?? {},
          builder: (context, loginState, child) {
            debugPrint("Selector - LoginPluginState build called"); // Debug rebuilds
            final level = loginState['level'] ?? "Not signed in.";
            final points = loginState['points'] ?? "-";
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              color: AppColors.accentColor2, // Background color
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Level: $level",
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    "Points: $points",
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
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
              // Background and game components
              Positioned.fill(child: const MainBackgroundComponent()),
              Positioned.fill(child: const AfterMathComponent()),
              Positioned.fill(child: const CelebHeadComponent()),
              Positioned.fill(child: const MainBackgroundOverlayComponent()),
              Positioned.fill(child: const RibbonComponent()),
              Positioned.fill(child: const AfterMathAnimComponent()),

              // Name buttons component at the top
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: NameButtonsComponent(),
              ),

              // Celeb facts component at the bottom with a scrollable container
              const Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SingleChildScrollView(
                  child: CelebFactsComponent(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

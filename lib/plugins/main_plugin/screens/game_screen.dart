import 'package:flush_me_im_famous/plugins/main_plugin/celeb_components/ribbon_component.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flush_me_im_famous/plugins/main_plugin/celeb_components/celeb_facts_component.dart';
import 'package:flush_me_im_famous/plugins/main_plugin/celeb_components/celeb_head_component.dart';
import 'package:flush_me_im_famous/plugins/main_plugin/celeb_components/main_background_component.dart';
import 'package:flush_me_im_famous/plugins/main_plugin/celeb_components/aftermath_component.dart';
import '../../../providers/app_state_provider.dart';
import '../../../screens/base_screen.dart';
import '../celeb_components/aftermath_anim_component.dart';
import '../celeb_components/name_buttons_component.dart';
import '../celeb_components/main_background_overlay_component.dart';
import '../functions/play_functions.dart';
import '../functions/audio_helper.dart';

class GameScreen extends BaseScreen {
  const GameScreen({Key? key}) : super(key: key);

  @override
  String get title => "Play";

  @override
  GameScreenState createState() => GameScreenState(); // Updated class name to public
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
    return Consumer<AppStateProvider>(
      builder: (context, appStateProvider, child) {
        // Adjust volume dynamically based on mute state
        AudioHelper().updateVolumeBasedOnState(context);

        return const Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(child: MainBackgroundComponent()),
                  Positioned.fill(child: AfterMathComponent()),
                  Positioned.fill(child: CelebHeadComponent()),
                  Positioned.fill(child: MainBackgroundOverlayComponent()),
                  Positioned.fill(child: RibbonComponent()),
                  Positioned.fill(child: AfterMathAnimComponent()),

                  // Name buttons component at the top
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: NameButtonsComponent(),
                  ),

                  // Celeb facts component at the bottom with a scrollable container
                  Positioned(
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
      },
    );
  }
}

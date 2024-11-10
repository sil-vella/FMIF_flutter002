import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:FMIF/plugins/main_plugin/celeb_components/celeb_facts_component.dart';
import 'package:FMIF/plugins/main_plugin/celeb_components/celeb_head_component.dart';
import 'package:FMIF/plugins/main_plugin/celeb_components/main_background_component.dart';
import 'package:FMIF/plugins/main_plugin/celeb_components/aftermath_component.dart';
import '../../../providers/app_state_provider.dart';
import '../../../screens/base_screen.dart';
import '../celeb_components/name_buttons_component.dart';
import '../celeb_components/main_background_overlay_component.dart';

class GameScreen extends BaseScreen {
  const GameScreen({Key? key}) : super(key: key);

  @override
  String get title => "Play";

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends BaseScreenState<GameScreen> with SingleTickerProviderStateMixin {
  bool shouldRebuild = false;

  @override
  Widget buildContent(BuildContext context) {
    final pluginStateKey = "MainPluginState";

    // Track when play_state changes to 'in_play'
    context.select<AppStateProvider, String?>((appStateProvider) {
      final pluginState = appStateProvider.getPluginState<Map<String, dynamic>>(pluginStateKey) ?? {};
      final playState = pluginState['play_state'] as String?;

      // Trigger rebuild if state changes to 'in_play'
      if (playState == 'in_play' && !shouldRebuild) {
        setState(() {
          shouldRebuild = true;
        });
      } else if (playState != 'in_play' && shouldRebuild) {
        shouldRebuild = false;  // Reset flag when not in 'in_play' to allow future rebuilds
      }

      return playState;
    });

    return Expanded(
      child: Stack(
        children: [
          const Positioned.fill(child: MainBackgroundComponent()),
          Positioned.fill(child: AfterMathComponent()),
          Positioned.fill(child: CelebHeadComponent()),

          const Positioned.fill(child: MainBackgroundOverlayComponent()),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: const NameButtonsComponent(),
          ),
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
    );
  }
}

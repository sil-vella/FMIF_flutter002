import 'package:FMIF/plugins/main_plugin/celeb_components/main_background_ribbon_component.dart';
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
  @override
  Widget buildContent(BuildContext context) {
    final pluginStateKey = "MainPluginState";

    // Monitor play_state changes to trigger specific actions or animations if needed
    context.select<AppStateProvider, String?>((appStateProvider) {
      final pluginState = appStateProvider.getPluginState<Map<String, dynamic>>(pluginStateKey) ?? {};
      return pluginState['play_state'] as String?;
    });

    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              const Positioned.fill(child: MainBackgroundComponent()),
              const Positioned.fill(child: AfterMathComponent()),
              const Positioned.fill(child: CelebHeadComponent()),
              const Positioned.fill(child: MainBackgroundOverlayComponent()),
              const Positioned.fill(child: RibbonComponent()),

              // Name buttons component at the top
              const Positioned(
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
  }
}

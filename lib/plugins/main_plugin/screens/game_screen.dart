import 'package:flutter/material.dart';
import 'package:FMIF/plugins/main_plugin/celeb_components/celeb_facts_component.dart';
import 'package:FMIF/plugins/main_plugin/celeb_components/celeb_head_component.dart';
import 'package:FMIF/plugins/main_plugin/celeb_components/main_background_component.dart';
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

class _GameScreenState extends BaseScreenState<GameScreen> {
  @override
  Widget buildContent(BuildContext context) {
    return Column(
      children: [
        const NameButtonsComponent(),
        Expanded(
          child: Stack(
            children: [
              const Positioned.fill(child: MainBackgroundComponent()),
              const Positioned.fill(child: CelebHeadComponent(id: 'celebHead01',)),
              const Positioned.fill(child: MainBackgroundOverlayComponent()),
              const Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: CelebFactsComponent(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:FMIF/plugins/main_plugin/celeb_components/celeb_facts_component.dart';
import 'package:FMIF/plugins/main_plugin/celeb_components/celeb_head_component.dart';
import 'package:FMIF/plugins/main_plugin/celeb_components/main_background_component.dart';
import 'package:FMIF/plugins/main_plugin/celeb_components/aftermath_component.dart';
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
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget buildContent(BuildContext context) {
    return Column(
      children: [
        const NameButtonsComponent(),
        Expanded(
          child: Stack(
            children: [
              const Positioned.fill(child: MainBackgroundComponent()),
              Positioned.fill(child: CelebHeadComponent()),
              Positioned.fill(child: AfterMathComponent()), // Added AfterMathComponent here
              const Positioned.fill(child: MainBackgroundOverlayComponent()),
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

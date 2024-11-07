import 'package:flutter/material.dart';
import 'package:FMIF/plugins/main_plugin/celeb_components/celeb_facts_component.dart';
import 'package:FMIF/plugins/main_plugin/celeb_components/celeb_head_component.dart';
import 'package:FMIF/plugins/main_plugin/celeb_components/main_background_component.dart';
import '../../../screens/base_screen.dart';
import '../celeb_components/name_buttons_component.dart';
import '../functions/animation_helper.dart';
import '../celeb_components/main_background_overlay_component.dart';

class GameScreen extends BaseScreen {
  const GameScreen({Key? key}) : super(key: key);

  @override
  String get title => "Play";

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends BaseScreenState<GameScreen> with TickerProviderStateMixin {
  late AnimationController mainController;

  @override
  void initState() {
    super.initState();
    mainController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    mainController.dispose();
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
              Positioned.fill(
                child: AnimationHelper.bounce(
                  AnimationHelper.sideToSide(
                    AnimationHelper.pulse(
                      const CelebHeadComponent(),
                      controller: mainController,
                    ),
                    controller: mainController,
                  ),
                  controller: mainController,
                ),
              ),
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

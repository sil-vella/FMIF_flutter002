// game_screen.dart
import 'package:flutter/material.dart';
import 'package:FMIF/plugins/main_plugin/celeb_components/main_background_component.dart';
import 'package:FMIF/plugins/main_plugin/celeb_components/main_celeb_component.dart';
import '../../../screens/base_screen.dart';

class GameScreen extends BaseScreen {
  const GameScreen({Key? key}) : super(key: key);

  @override
  String get title => "FMIF";

  @override
  Widget buildContent(BuildContext context) {
    return Stack(
      children: const [
        // Use Positioned.fill to make the background fill the Stack
        Positioned.fill(
          child: MainBackgroundComponent(),
        ),
        // Position MainCelebComponent appropriately
        MainCelebComponent(),
      ],
    );
  }
}

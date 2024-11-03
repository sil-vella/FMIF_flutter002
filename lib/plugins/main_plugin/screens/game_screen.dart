// pref_screen.dart
import '../celeb_components/main_celeb_component.dart';
import 'package:flutter/material.dart';
import '../../../screens/base_screen.dart';

class GameScreen extends BaseScreen {
  const GameScreen({Key? key}) : super(key: key);

  @override
  String get title => "FMIF";

  Widget buildContent(BuildContext context) {
    return const Center(
      child: MainCelebComponent(),
    );
  }
}
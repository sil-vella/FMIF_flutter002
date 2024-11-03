// screen_one.dart
import 'package:flutter/material.dart';
import '../../../screens/base_screen.dart';

class ScreenOne extends BaseScreen {
  const ScreenOne({Key? key}) : super(key: key);

  @override
  String get title => "Screen One";

  @override
  Widget buildContent(BuildContext context) {
    return const Center(
      child: Text("Welcome to Screen One!"),
    );
  }
}

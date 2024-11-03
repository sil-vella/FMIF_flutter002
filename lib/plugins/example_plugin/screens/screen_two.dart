// screen_two.dart
import 'package:flutter/material.dart';
import '../../../screens/base_screen.dart';

class ScreenTwo extends BaseScreen {
  const ScreenTwo({Key? key}) : super(key: key);

  @override
  String get title => "Screen Two";

  @override
  Widget buildContent(BuildContext context) {
    return const Center(
      child: Text("Welcome to Screen Two!"),
    );
  }
}

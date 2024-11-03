// home_screen.dart
import 'package:flutter/material.dart';
import 'base_screen.dart';

class HomeScreen extends BaseScreen {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  String get title => 'Home';

  @override
  Widget buildContent(BuildContext context) {
    return const Center(
      child: Text('Welcome to the Home Screen!'),
    );
  }
}

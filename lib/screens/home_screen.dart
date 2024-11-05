// home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../plugins/main_plugin/functions/play_functions.dart';
import '../providers/app_state_provider.dart';
import 'base_screen.dart';

class HomeScreen extends BaseScreen {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  String get title => 'Home';

  @override
  Widget buildContent(BuildContext context) {
    // Access AppStateProvider to pass into PlayFunctions
    final appStateProvider = Provider.of<AppStateProvider>(context, listen: false);

    return Center(
      child: ElevatedButton(
        onPressed: () {
          // Call handlePlayButton with AppStateProvider
          PlayFunctions.handlePlayButton(appStateProvider, context);
        },
        child: const Text('Play'),
      ),
    );
  }
}

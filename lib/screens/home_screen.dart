import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../plugins/main_plugin/functions/play_functions.dart';
import '../services/providers/app_state_provider.dart';
import 'base_screen.dart';

class HomeScreen extends BaseScreen {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  String computeTitle(BuildContext context) {
    // Return a fixed title for the screen
    return "Home";
  }

  @override
  HomeScreenState createState() => HomeScreenState();
}

// Rename _HomeScreenState to HomeScreenState
class HomeScreenState extends BaseScreenState<HomeScreen> {
  @override
  Widget buildContent(BuildContext context) {
    return Stack(
      children: [
        // Background image
        Positioned.fill(
          child: Image.asset(
            'assets/images/backgrounds/pre_game_main_background.jpg', // Replace with your background image path
            fit: BoxFit.cover, // Ensures the image covers the entire screen
          ),
        ),
        // Foreground content
        Center(
          child: ElevatedButton(
            onPressed: () {
              final appStateProvider = Provider.of<AppStateProvider>(context, listen: false);
              PlayFunctions.handlePlayButton(appStateProvider, context);
            },
            child: const Text('Play'),
          ),
        ),
      ],
    );
  }
}

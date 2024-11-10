import 'package:flutter/material.dart';
import '../../../providers/app_state_provider.dart';
import '../main_plugin_main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_plugin_helper.dart';

class PlayFunctions extends PluginHelper {
  static Future<void> handlePlayButton(AppStateProvider appStateProvider, BuildContext context) async {
    // Retrieve the celeb_category from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final celebCategory = prefs.getString('celeb_category');

    // Check if the celeb_category has a value
    if (celebCategory == null || celebCategory.isEmpty) {
      // If not, show a popup alert and link to the /pref screen
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Category Required"),
            content: Text("Please choose a category to continue."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the alert dialog
                  Navigator.of(context).pushNamed('/prefs'); // Navigate to the /pref screen
                },
                child: Text("Choose Category"),
              ),
            ],
          );
        },
      );
      return; // Stop the function if no category is selected
    }

    // Update the main app state to indicate that play has started
    appStateProvider.updateMainAppState('main_state', 'in_play');

    // Use MainPlugin's runtimeType for the dynamic key
    final pluginStateKey = "${MainPlugin().runtimeType}State";

    // Fetch and set celebrity details, awaiting its completion
    await fetchAndSetCelebDetails(appStateProvider, pluginStateKey);

    // Update the play state in the plugin state
    appStateProvider.updatePluginState(pluginStateKey, {
      'play_state': "in_play",
      'plugin_anims': {'head_anims': ['bounce', 'pulse', 'sideToSide']},
    });

    // Navigate to the /play screen once details are fetched
    Navigator.of(context).pushNamed('/play');
  }

  static Future<void> fetchAndSetCelebDetails(
      AppStateProvider appStateProvider,
      String pluginStateKey,
      ) async {
    // Retrieve the current category from the plugin state
    final pluginState = appStateProvider.getPluginState<Map<String, dynamic>>(pluginStateKey) ?? {};
    final celebCategory = pluginState['celeb_category'];

    print("getting from category $celebCategory");

    try {
      // Fetch the celeb details from the API
      final celebDetails = await PluginHelper.getCelebDetails(celebCategory);

      // Update specific fields in the plugin state
      appStateProvider.updatePluginState(pluginStateKey, {
        'celeb_name': celebDetails['name'],
        'celeb_facts': celebDetails['facts'],
        'celeb_img_url': celebDetails['image'],
        'other_celebs': celebDetails['other_celebs'],
      });

      print("Celebrity details updated in the state: ${appStateProvider.getPluginState(pluginStateKey)}");

    } catch (error) {
      print("Error fetching or updating celebrity details: $error");
    }
  }

  static Future<void> selectedCeleb(AppStateProvider appStateProvider, String pluginStateKey, String selectedName) async {
    final pluginState = appStateProvider.getPluginState<Map<String, dynamic>>(pluginStateKey) ?? {};

    if (selectedName == pluginState['celeb_name']) {
      appStateProvider.updatePluginState(pluginStateKey, {
        'play_state': 'revealed_correct',
      });

    } else {
      print("Incorrect selection.");
    }
  }

  // Now static: Function triggered when the correct name is selected
  static Future<void> flushAction(AppStateProvider appStateProvider, String pluginStateKey) async {
    // Define logic for correct selection here, such as updating a score or showing feedback
    appStateProvider.updatePluginState(pluginStateKey, {
      'plugin_anims': {'head_anims': ['shakeAndDrop', 'pulse', 'sideToSide', 'bounce']},
    });
    // Force rebuild or small delay if needed to apply the animation
    await Future.delayed(Duration(milliseconds: 100));
  }

  // Now static: Function triggered when the correct name is selected
  static Future<void> activateAftermath(AppStateProvider appStateProvider, String pluginStateKey) async {
    print("aftermath functiuon reached");
    // Define logic for correct selection here, such as updating a score or showing feedback
    appStateProvider.updatePluginState(pluginStateKey, {
      'play_state': 'aftermath',
      'plugin_anims': {'aftermath_anims': ['slideUpAndDown']},
    });
    // Force rebuild or small delay if needed to apply the animation
    await Future.delayed(Duration(milliseconds: 100));
  }

  static Future<void> resetPluginPlayState(AppStateProvider appStateProvider, String pluginStateKey) async {
    appStateProvider.updatePluginState(pluginStateKey, {
      'plugin_anims': {},
    });
    // Force rebuild or small delay if needed to apply the animation
    await Future.delayed(Duration(milliseconds: 100));
    // Fetch the default state from MainPlugin
    final defaultState = MainPlugin().reset();

    // Update the plugin state with the default values
    appStateProvider.updatePluginState(pluginStateKey, defaultState);

    // Retrieve any saved category from SharedPreferences (if required)
    final savedCategory = await SharedPreferences.getInstance().then((prefs) => prefs.getString("celeb_category") ?? "");
    // Fetch and set celebrity details, awaiting its completion
    await fetchAndSetCelebDetails(appStateProvider, pluginStateKey);
    defaultState["celeb_category"] = savedCategory;

    appStateProvider.updatePluginState(pluginStateKey, {
      'play_state': 'in_play',
      'plugin_anims': {'head_anims': ['pulse', 'sideToSide', 'bounce']},
    });
  }

  // Now static: Function triggered when an incorrect name is selected
  static void onIncorrectSelection(AppStateProvider appStateProvider, String pluginStateKey) {
    // Define logic for incorrect selection here, such as showing feedback or updating attempts
  }
}


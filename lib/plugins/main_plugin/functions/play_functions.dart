// plugins/shared_plugin/functions/play_functions.dart
import 'package:flutter/material.dart';
import '../../../providers/app_state_provider.dart';
import '../main_plugin_main.dart'; // Import MainPlugin to access runtimeType
import 'main_plugin_helper.dart'; // Import PluginHelper to access getCelebDetails
import 'package:shared_preferences/shared_preferences.dart';

class PlayFunctions {
  static Future<void> handlePlayButton(AppStateProvider appStateProvider,
      BuildContext context) async {
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
                  Navigator.of(context).pushNamed(
                      '/prefs'); // Navigate to the /pref screen
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
    // Retrieve the current plugin state
    final pluginState = appStateProvider.getPluginState<Map<String, dynamic>>(
        pluginStateKey) ?? {};

    // Set the play state to indicate that the play has started
    pluginState['play_state'] = "in_play";
    // Save the updated play state
    appStateProvider.updatePluginState(pluginStateKey, pluginState);

    // Fetch and set celebrity details, awaiting its completion
    await fetchAndSetCelebDetails(
        appStateProvider, pluginState, pluginStateKey);

    // Navigate to the /play screen once details are fetched
    Navigator.of(context).pushNamed('/play');
  }

  static Future<void> fetchAndSetCelebDetails(AppStateProvider appStateProvider,
      Map<String, dynamic> pluginState, String pluginStateKey) async {
    // Retrieve the current category from the plugin state
    final celebCategory = pluginState['celeb_category'];

    try {
      // Fetch the celeb details from the API
      final celebDetails = await PluginHelper.getCelebDetails(celebCategory);

      // Update pluginState with fetched celeb details if successful
      pluginState['celeb_name'] = celebDetails['name'];
      pluginState['celeb_facts'] = celebDetails['facts'];
      pluginState['celeb_img_url'] = celebDetails['image'];
      pluginState['other_celebs'] = celebDetails['other_celebs'];

      // Save the updated state back into AppStateProvider
      appStateProvider.updatePluginState(pluginStateKey, pluginState);

      print("Celebrity details updated in the state: $pluginState");
    } catch (error) {
      print("Error fetching or updating celebrity details: $error");
    }
  }

  void selectedCeleb(AppStateProvider appStateProvider,
      Map<String, dynamic> pluginState, String pluginStateKey, String selectedName) async {

    // Compare selected name to the correct celebrity name
    if (selectedName == pluginState['celeb_name']) {
      onCorrectSelection(appStateProvider, pluginState, pluginStateKey);
    } else {
      onIncorrectSelection(appStateProvider, pluginState, pluginStateKey);
    }
  }

  // Function triggered when the correct name is selected
  void onCorrectSelection(AppStateProvider appStateProvider,
      Map<String, dynamic> pluginState, String pluginStateKey) {

  }

  // Function triggered when an incorrect name is selected
  void onIncorrectSelection(AppStateProvider appStateProvider,
      Map<String, dynamic> pluginState, String pluginStateKey) {

  }
}

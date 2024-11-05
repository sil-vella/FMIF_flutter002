// plugins/shared_plugin/functions/play_functions.dart
import 'package:flutter/material.dart';
import '../../../providers/app_state_provider.dart';
import '../main_plugin_main.dart'; // Import MainPlugin to access runtimeType
import 'main_plugin_helper.dart'; // Import PluginHelper to access getCelebDetails

class PlayFunctions {
  static Future<void> handlePlayButton(AppStateProvider appStateProvider, BuildContext context) async {
    // Use MainPlugin's runtimeType for the dynamic key
    final pluginStateKey = "${MainPlugin().runtimeType}State";
    // Retrieve the current plugin state
    final pluginState = appStateProvider.getPluginState<Map<String, dynamic>>(pluginStateKey) ?? {};

    // Set the play state to indicate that the play has started
    pluginState['play_state'] = "in_play";
    // Save the updated play state
    appStateProvider.updatePluginState(pluginStateKey, pluginState);

    // Fetch and set celebrity details, awaiting its completion
    await fetchAndSetCelebDetails(appStateProvider, pluginState, pluginStateKey);

    // Navigate to the /play screen once details are fetched
    Navigator.of(context).pushNamed('/play');
  }

  static Future<void> fetchAndSetCelebDetails(
      AppStateProvider appStateProvider, Map<String, dynamic> pluginState, String pluginStateKey) async {
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
}

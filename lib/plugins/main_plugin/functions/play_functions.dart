import 'package:flutter/material.dart';
import '../../../providers/app_state_provider.dart';
import '../../00_base/module_manager.dart';
import '../../admobs/admobs_main.dart';
import '../main_plugin_main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'audio_helper.dart';
import 'main_plugin_helper.dart';


class PlayFunctions extends PluginHelper {
  static Future<void> handlePlayButton(AppStateProvider appStateProvider, BuildContext context) async {
    print('Starting handlePlayButton');
    try {
      // Retrieve the celeb_category from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final celebCategory = prefs.getString('celeb_category');
      print('Retrieved celeb_category: $celebCategory');

      if (celebCategory == null || celebCategory.isEmpty) {
        print('celeb_category is null or empty');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Category Required"),
              content: Text("Please choose a category to continue."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushNamed('/prefs');
                  },
                  child: Text("Choose Category"),
                ),
              ],
            );
          },
        );
        return;
      }

      // Use MainPlugin's runtimeType for the dynamic key
      final pluginStateKey = "${MainPlugin().runtimeType}State";
      print('Using pluginStateKey: $pluginStateKey');

      // Fetch and set celebrity details since a category is set
      print('Fetching details since celeb_category is set');
      await fetchAndSetCelebDetails(appStateProvider, pluginStateKey);

      // Retrieve updated pluginState to reflect fetched details
      var pluginState = appStateProvider.getPluginState<Map<String, dynamic>>(pluginStateKey) ?? {};
      print('pluginState after fetching: $pluginState');

      // Update the main app state to indicate that play has started
      appStateProvider.updateMainAppState('main_state', 'in_play');
      print('Updated main app state to in_play');

      // Update the play state in the plugin state
      appStateProvider.updatePluginState(pluginStateKey, {
        'play_state': "in_play",
        'plugin_anims': {
          'head_anims': ['slideUp', 'bounce', 'pulse', 'sideToSide'],
          'ribbon_anims': [],
        },
      });
      print('Updated plugin state to in_play');

      // Navigate to the /play screen once details are verified and fetched
      print('Navigating to /play');
      Navigator.of(context).pushNamed('/play');
    } catch (error) {
      print('Error in handlePlayButton: $error');
    }
  }

  static Future<void> fetchAndSetCelebDetails(AppStateProvider appStateProvider, String pluginStateKey) async {
    print('fetching');
    try {
      final pluginState = appStateProvider.getPluginState<Map<String, dynamic>>(pluginStateKey) ?? {};
      final celebCategory = pluginState['celeb_category'];

      final celebDetails = await PluginHelper.getCelebDetails(celebCategory);
      appStateProvider.updatePluginState(pluginStateKey, {
        'celeb_name': celebDetails['name'],
        'celeb_facts': celebDetails['facts'],
        'celeb_img_url': celebDetails['image'],
        'other_celebs': celebDetails['other_celebs'],
        'correct_anim': celebDetails['correct_animation'],
        'incorrect_anim': celebDetails['incorrect_animation']
      });

    } catch (error) {
    }
  }

  static Future<void> selectedCeleb(AppStateProvider appStateProvider, String pluginStateKey, String selectedName) async {
    try {
      final pluginState = appStateProvider.getPluginState<Map<String, dynamic>>(pluginStateKey) ?? {};

      if (selectedName == pluginState['celeb_name']) {
        appStateProvider.updatePluginState(pluginStateKey, {
          'play_state': 'revealed_correct',
          'plugin_anims': {
            'head_anims': ['pulse', 'sideToSide', 'bounce'],
            'ribbon_anims': ['shrinkAndSlideDown'],
          }
        });
      } else {
        appStateProvider.updatePluginState(pluginStateKey, {
          'play_state': 'revealed_incorrect',
          'flushing': 'true',
          'plugin_anims': {
            'head_anims': ['pulse', 'sideToSide', 'bounce'],
            'ribbon_anims': ['shrinkAndSlideDown'],
          }
        });
        await activateAftermath(appStateProvider, pluginStateKey);
      }
    } catch (error) {
      print("Error in selectedCeleb: $error");
    }
  }

  static void flushAction(AppStateProvider appStateProvider, String pluginStateKey, context) {
    // Create an instance of AudioHelper
    // Access the singleton instance
    AudioHelper().playEffectSound('app_audio/flush006.mp3', context);


    // Update plugin state
    appStateProvider.updatePluginState(pluginStateKey, {
      'flushing': true,
      'plugin_anims': {
        'head_anims': ['shakeAndDrop', 'pulse', 'sideToSide', 'bounce'],
        'ribbon_anims': [],
      },
    });
  }

  static Future<void> activateAftermath(AppStateProvider appStateProvider, String pluginStateKey) async {
    try {
      final currentPlayState = appStateProvider.getPluginState<Map<String, dynamic>>(pluginStateKey)?['play_state'];

      if (currentPlayState == 'revealed_correct') {
        appStateProvider.updatePluginState(pluginStateKey, {
          'play_state': 'aftermath_correct',
          'plugin_anims': {'aftermath_anims': ['slideUpAndDown']},
        });
      } else if (currentPlayState == 'revealed_incorrect') {
        appStateProvider.updatePluginState(pluginStateKey, {
          'flushing': false,
          'play_state': 'aftermath_incorrect',
          'plugin_anims': {
            'aftermath_anims': ['flyAway'],
            'head_anims': ['flyAway']
          },
        });
      }

      await Future.delayed(Duration(milliseconds: 100));
    } catch (error) {
      print("Error in activateAftermath: $error");
    }
  }
  static bool _isResetting = false; // Flag to prevent reentrant calls

  static Future<void> resetPluginPlayState(AppStateProvider appStateProvider, String pluginStateKey) async {
    if (_isResetting) {
      print("resetPluginPlayState is already in progress. Skipping duplicate call.");
      return;
    }

    _isResetting = true; // Set the flag to true at the start of the method
    try {
      // Retrieve InterstitialAdWidget if it has been registered by AdmobsPlugin
      final interstitialModuleFactory = ModuleManager().getModule<Function>("InterstitialModule");
      final interstitialWidget = interstitialModuleFactory != null ? interstitialModuleFactory() as Widget : null;

      // Check and update the ad_counter
      final pluginState = appStateProvider.getPluginState<Map<String, dynamic>>(pluginStateKey) ?? {};
      int adCounter = pluginState['ad_counter'] ?? 0;

      print("Current ad_counter: $adCounter"); // Debug: Log current ad_counter

      if (adCounter >= 3) {
        print("ad_counter >= 3, attempting to play interstitial ad."); // Debug: Ad logic triggered

        // Show the interstitial ad
        try {
          AdmobsPlugin().showInterstitialAd();
          print("Interstitial ad displayed.");
        } catch (e) {
          print("Error showing interstitial ad: $e");
        }

        // Reset the ad_counter to 0
        appStateProvider.updatePluginState(pluginStateKey, {'ad_counter': 0});
        print("ad_counter reset to 0 after showing ad."); // Debug: Counter reset
      } else {
        print("ad_counter < 4, incrementing ad_counter."); // Debug: Increment logic

        // Increment the ad_counter
        appStateProvider.updatePluginState(pluginStateKey, {'ad_counter': adCounter + 1});
        print("ad_counter incremented to ${adCounter + 1}."); // Debug: Log incremented value
      }

      await Future.delayed(Duration(milliseconds: 100));

      // Reset the plugin state
      final defaultState = MainPlugin().reset();
      appStateProvider.updatePluginState(pluginStateKey, defaultState);

      print("Plugin state reset to default."); // Debug: State reset

      // Retrieve and set the saved category
      final savedCategory = await SharedPreferences.getInstance().then((prefs) => prefs.getString("celeb_category") ?? "");
      await fetchAndSetCelebDetails(appStateProvider, pluginStateKey);
      defaultState["celeb_category"] = savedCategory;

      print("Saved category retrieved and set: $savedCategory"); // Debug: Category

      appStateProvider.updatePluginState(pluginStateKey, {
        'plugin_anims': {},
      });

      appStateProvider.updatePluginState(pluginStateKey, {
        'play_state': 'in_play',
        'plugin_anims': {'head_anims': ['slideUp', 'pulse', 'sideToSide', 'bounce']},
      });

      print("Plugin state updated with play_state and animations."); // Debug: State updated
    } catch (error) {
      print("Error in resetPluginPlayState: $error"); // Debug: Error handling
    } finally {
      _isResetting = false; // Ensure the flag is reset even if an error occurs
    }
  }

}





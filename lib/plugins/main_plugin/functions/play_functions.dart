import 'dart:developer' as dev;
import 'dart:math';

import 'package:flutter/material.dart';
import '../../../services/providers/app_state_provider.dart';
import '../../00_base/module_manager.dart';
import '../main_plugin_main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'audio_helper.dart';
import 'main_plugin_helper.dart';


class PlayFunctions extends PluginHelper {
  static Future<void> handlePlayButton(AppStateProvider appStateProvider, BuildContext context) async {
    dev.log('Starting handlePlayButton');
    try {
      final prefs = await SharedPreferences.getInstance();
      final celebCategory = prefs.getString('celeb_category');
      dev.log('Retrieved celeb_category: $celebCategory');

      if (celebCategory == null || celebCategory.isEmpty) {
        // **FIX: Check context.mounted before using context**
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (BuildContext dialogContext) {
              return AlertDialog(
                title: const Text("Category Required"),
                content: const Text("Please choose a category to continue."),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      Navigator.of(context).pushNamed('/prefs');
                    },
                    child: const Text("Choose Category"),
                  ),
                ],
              );
            },
          );
        }
        return;
      }

      final pluginStateKey = "MainPluginState";
      dev.log('Using pluginStateKey: $pluginStateKey');

      await fetchAndSetCelebDetails(appStateProvider, context);

      appStateProvider.updateMainAppState('main_state', 'in_play');
      appStateProvider.updatePluginState(pluginStateKey, {
        'play_state': "in_play",
        'plugin_anims': {
          'head_anims': ['slideUp', 'bounce', 'pulse', 'sideToSide'],
          'ribbon_anims': [],
        },
      });

      // **FIX: Check context.mounted before navigating**
      if (context.mounted) {
        Navigator.of(context).pushNamed('/play');
      }
    } catch (error) {
      dev.log('Error in handlePlayButton: $error');
    }
  }

  static Future<void> fetchAndSetCelebDetails(AppStateProvider appStateProvider, BuildContext context) async {
    dev.log('Fetching celebrity details...');

    // Guard against using context after async gaps
    if (!context.mounted) return;

    try {
      // Fetch the plugin state for the given key
      final pluginState = appStateProvider.getPluginState<Map<String, dynamic>>("MainPluginState") ?? {};

      final celebCategory = pluginState['celeb_category'];
      dev.log('ze cate $celebCategory');

      // Check if the category is available
      if (celebCategory == null || celebCategory.isEmpty) {
        dev.log('No celebrity category found in plugin state.');
        return;
      }

      // Check if the user is logged in
      final loginState = appStateProvider.getPluginState<Map<String, dynamic>>("LoginPluginState") ?? {};
      final bool isLoggedIn = loginState['logged'] ?? false;
      String? username;

      // Get the username if logged in
      if (isLoggedIn) {
        username = loginState['username'];
        dev.log('User is logged in. Username: $username');

      } else {
        dev.log('User is not logged in.');
      }

      final celebDetails = await PluginHelper.getCelebDetails(celebCategory, username);
      dev.log('after getceleb before !context');

      dev.log('after !context ');
      dev.log('User is not logged in.');
      // Use containsKey to check if the key exists in the Map
      if (celebDetails.containsKey('level_up')) {
        // Fetch the `getUserDetails` function dynamically from the ModuleManager
        final userDetailsFunction = ModuleManager().getFunction<Future<Map<String, dynamic>> Function({required String username})>("LoginModule.getUserDetails");

        if (userDetailsFunction != null && username != null) {
          // Await the result of fetching user details
          final userDetails = await userDetailsFunction(username: username);

          // Check if the user details were successfully fetched
          if (userDetails['success'] == true) {
            // Update the LoginPluginState with the fetched user details
            appStateProvider.updatePluginState('LoginPluginState', {
              ...loginState, // Keep other existing state
              'points': userDetails['points'], // Update points
              'category_levels': userDetails['category_levels'], // Update category levels
            });

          } else {
            dev.log('Failed to fetch user details: ${userDetails['message']}');
          }
        } else {
          dev.log('Error: UserDetails function is unavailable or username is null.');
        }

        // Update the plugin state with the new play_state
        appStateProvider.updatePluginState("MainPluginState", {
          ...pluginState, // Keep other existing state
          'play_state': 'level_up', // Update play_state with the new play_state
        });

        // Navigate to the Level Up route
        Navigator.of(context).pushNamed('/levelup');
      } else {
        dev.log('Fetched celebrity details: $celebDetails');

        // Update plugin state with fetched details
        appStateProvider.updatePluginState("MainPluginState", {
          'celeb_name': celebDetails['name'],
          'celeb_facts': celebDetails['facts'],
          'celeb_img_url': celebDetails['image'],
          'other_celebs': celebDetails['other_celebs'],
          'correct_anim': celebDetails['correct_animation'],
          'incorrect_anim': celebDetails['incorrect_animation']
        });

        final updatedPluginState = appStateProvider.getPluginState<Map<String, dynamic>>("MainPluginState") ?? {};
        dev.log('Updated plugin state after fetching: $updatedPluginState');
      }
    } catch (error) {
      dev.log('Error fetching and setting celebrity details: $error');
    }
  }

  static Future<void> selectedCeleb(
      AppStateProvider appStateProvider, String pluginStateKey, String selectedName, BuildContext context) async {
    try {
      final pluginState = appStateProvider.getPluginState<Map<String, dynamic>>(pluginStateKey) ?? {};

      if (selectedName == pluginState['celeb_name']) {
        dev.log("Selected name matches celeb_name. Updating to revealed_correct.");
        appStateProvider.updatePluginState("MainPluginState", {
          'play_state': 'revealed_correct',
          'plugin_anims': {
            'head_anims': ['pulse', 'sideToSide', 'bounce'],
            'ribbon_anims': ['cut_tape'],
          }
        });

        // Check if user is logged in and add points
        final loginState = appStateProvider.getPluginState<Map<String, dynamic>>("LoginPluginState") ?? {};
        if (loginState['logged'] == true) {
          final username = loginState['username'];
          final currentPoints = loginState['points'] ?? 0;

          // Check the hint state and calculate points to add
          final hintState = pluginState['hint'] ?? false;
          final pointsToAdd = hintState == true ? 3 : 5;

          // Update the points
          final updatedPoints = currentPoints + pointsToAdd;

          // Update local state
          appStateProvider.updatePluginState("LoginPluginState", {
            ...loginState,
            'points': updatedPoints,
          });
          dev.log("User is logged in. Added $pointsToAdd points. Total points: $updatedPoints");

          // Dynamically call updatePoints from UserUpdateModule
          final updatePointsFunction = ModuleManager()
              .getFunction<Future<Map<String, dynamic>> Function({required String username, required int points, required BuildContext context})>(
              "UserUpdateModule.updatePoints");
          if (updatePointsFunction != null) {
            final response = await updatePointsFunction(
              username: username,
              points: updatedPoints,
              context: context,
            );

            if (response['success'] == true) {
              dev.log("Successfully updated points in the backend: ${response['updated_points']}");
            } else {
              dev.log("Failed to update points in the backend: ${response['message']}");
            }
          } else {
            dev.log("Error: updatePoints function not found in UserUpdateModule.");
          }
        }

        // Call updateGuessed to update guessed celebrity
        final guessedCategory = pluginState['celeb_category'];  // Assuming category is stored in pluginState
        if (guessedCategory != null) {
          final updateGuessedFunction = ModuleManager()
              .getFunction<Future<Map<String, dynamic>> Function({required String username, required String guessedName, required String guessedCategory, required BuildContext context})>(
              "UserUpdateModule.updateGuessed");

          if (updateGuessedFunction != null) {
            final response = await updateGuessedFunction(
              username: loginState['username'],
              guessedName: selectedName,
              guessedCategory: guessedCategory,
              context: context,
            );

            if (response['success'] == true) {
              dev.log("Successfully updated guessed celebrity: ${response['guessed_name']} in category: ${response['guessed_category']}");
            } else {
              dev.log("Failed to update guessed celebrity: ${response['message']}");
            }
          } else {
            dev.log("Error: updateGuessed function not found in UserUpdateModule.");
          }
        }

        // Play a random applause file
        final applauseKeys = AudioHelper().applauseFiles.keys.toList();
        final randomKey = applauseKeys[Random().nextInt(applauseKeys.length)];
        final applausePath = AudioHelper().applauseFiles[randomKey];

        if (applausePath != null) {
          AudioHelper().playEffectSound(applausePath, context);
        } else {
          dev.log("Error: No applause sound found for key '$randomKey'");
        }
      } else {
        dev.log("Selected name does not match celeb_name. Updating to revealed_incorrect.");
        appStateProvider.updatePluginState("MainPluginState", {
          'play_state': 'revealed_incorrect',
          'flushing': 'true',
          'plugin_anims': {
            'head_anims': ['pulse', 'sideToSide', 'bounce'],
            'ribbon_anims': ['cut_tape'],
          }
        });
        dev.log("Calling activateAftermath for revealed_incorrect.");
        await activateAftermath(appStateProvider, pluginStateKey, context);
      }
    } catch (error) {
      dev.log("Error in selectedCeleb: $error");
    }
  }

  static void flushAction(AppStateProvider appStateProvider, String pluginStateKey, context) {
    // Create an instance of AudioHelper
    // Access the singleton instance
    AudioHelper().playEffectSound('audio/flush006.mp3', context);


    // Update plugin state
    appStateProvider.updatePluginState("MainPluginState", {
      'flushing': true,
      'plugin_anims': {
        'head_anims': ['shakeAndDrop', 'pulse', 'sideToSide', 'bounce'],
        'ribbon_anims': [],
      },
    });
  }

  static Future<void> activateAftermath(
      AppStateProvider appStateProvider,
      String pluginStateKey,
      BuildContext context,
      ) async {
    try {
      final pluginState = appStateProvider.getPluginState<Map<String, dynamic>>(pluginStateKey) ?? {};
      final currentPlayState = pluginState['play_state'];

      if (currentPlayState == 'revealed_correct') {
        dev.log("Play state is revealed_correct. Updating to aftermath_correct.");
        appStateProvider.updatePluginState("MainPluginState", {
          'play_state': 'aftermath_correct',
          'plugin_anims': {
            'aftermath_anims': ['slideUpAndDown'],
            'game_screen_anims': ['hue_and_bright']
          },
        });
        dev.log("Correct anim: ${pluginState['correct_anim']}");

      } else if (currentPlayState == 'revealed_incorrect') {
        dev.log("Play state is revealed_incorrect. Updating to aftermath_incorrect.");
        appStateProvider.updatePluginState("MainPluginState", {
          'flushing': false,
          'play_state': 'aftermath_incorrect',
          'plugin_anims': {
            'aftermath_anims': ['flyAway'],
            'head_anims': ['flyAway']
          },
        });
      }

      await Future.delayed(const Duration(milliseconds: 100));
    } catch (error) {
      dev.log("Error in activateAftermath: $error");
    }
  }


  static bool _isResetting = false; // Flag to prevent reentrant calls

  static Future<void> resetPluginPlayState(AppStateProvider appStateProvider, String pluginStateKey, BuildContext context) async {
    dev.log("staret of reset.");
    if (_isResetting) {
      dev.log("resetPluginPlayState is already in progress. Skipping duplicate call.");
      return;
    }

    _isResetting = true; // Set the flag to true at the start of the method
    try {
      // Check and update the ad_counter
      final pluginState = appStateProvider.getPluginState<Map<String, dynamic>>(pluginStateKey) ?? {};
      int adCounter = pluginState['ad_counter'] ?? 0;

      dev.log("Current ad_counter: $adCounter"); // Debug: Log current ad_counter

      if (adCounter >= 3) {
        dev.log("ad_counter >= 3, attempting to play interstitial ad."); // Debug: Ad logic triggered

        // Retrieve the InterstitialAdService dynamically from ModuleManager
        final interstitialAdService = ModuleManager().getInstance<dynamic>("InterstitialAdService");

        if (interstitialAdService != null) {
          try {
            // Use Function.apply to call the showAd method dynamically
            Function.apply(
              interstitialAdService.showAd,
              [],
            );
            dev.log("Interstitial ad displayed.");
          } catch (e) {
            dev.log("Error showing interstitial ad: $e");
          }
        } else {
          dev.log("InterstitialAdService instance not found in ModuleManager.");
        }

        // Reset the ad_counter to 0
        appStateProvider.updatePluginState("MainPluginState", {'ad_counter': 0});
        dev.log("ad_counter reset to 0 after showing ad.");
      } else {
        dev.log("ad_counter < 3, incrementing ad_counter."); // Debug: Increment logic

        // Increment the ad_counter
        appStateProvider.updatePluginState("MainPluginState", {'ad_counter': adCounter + 1});
        dev.log("ad_counter incremented to ${adCounter + 1}."); // Debug: Log incremented value
      }

      await Future.delayed(const Duration(milliseconds: 100));

      // Reset the plugin state
      final defaultState = MainPlugin().reset();
      appStateProvider.updatePluginState("MainPluginState", defaultState);

      dev.log("Plugin state reset to default."); // Debug: State reset

      // Retrieve and set the saved category
      final savedCategory = await SharedPreferences.getInstance().then((prefs) => prefs.getString("celeb_category") ?? "");
      dev.log("before fetchceleb");
      await fetchAndSetCelebDetails(appStateProvider, context);
      dev.log("after fetch. state: $pluginState");
      defaultState["celeb_category"] = savedCategory;

      dev.log("Saved category retrieved and set: $savedCategory"); // Debug: Category

      appStateProvider.updatePluginState("MainPluginState", {
        'plugin_anims': {},
      });
      dev.log("after fetch 2. state: $pluginState");

// Assuming `appStateProvider` has a method to get the current plugin state
      var currentState = appStateProvider.getPluginState(pluginStateKey);

      dev.log("after fetch 3. state: $pluginState and currentate $currentState");

// Check if the current play_state is not 'level_up'
      if (currentState['play_state'] != 'level_up') {
        appStateProvider.updatePluginState("MainPluginState", {
          'play_state': 'in_play',
          'plugin_anims': {
            'head_anims': ['slideUp', 'pulse', 'sideToSide', 'bounce'],
            'game_screen_anims': []
          },
        });
      }

      dev.log("Plugin state updated with play_state and animations."); // Debug: State updated
    } catch (error) {
      dev.log("Error in resetPluginPlayState: $error"); // Debug: Error handling
    } finally {
      _isResetting = false; // Ensure the flag is reset even if an error occurs
    }
  }

  static Future<void> onRewardEarned(AppStateProvider appStateProvider, BuildContext context) async {
    // Use MainPlugin's runtimeType for the dynamic key
    final pluginStateKey = "${MainPlugin().runtimeType}State";

    // Retrieve the current plugin state
    final pluginState = appStateProvider.getPluginState<Map<String, dynamic>>(pluginStateKey) ?? {};

    // Get the current 'other_celebs' list
    final List<String> otherCelebs = List<String>.from(pluginState['other_celebs'] ?? []);

    if (otherCelebs.length > 1) {
      // Randomly remove one of the two strings
      otherCelebs.removeAt(Random().nextInt(otherCelebs.length));
    }

    // Update the plugin state with the remaining list and set 'hint' to true
    appStateProvider.updatePluginState("MainPluginState", {
      ...pluginState,
      'other_celebs': otherCelebs, // Update the 'other_celebs' key with the new list
      'hint': true,               // Set 'hint' to true
    });

    dev.log("Updated other_celebs: $otherCelebs");
    dev.log("'hint' is now set to true.");
  }


}





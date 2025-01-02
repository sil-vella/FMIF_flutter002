import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:math';

import 'package:flutter/material.dart';
import '../../../services/providers/app_state_provider.dart';
import '../../../services/shared_preferences_service.dart';
import '../../00_base/module_manager.dart';
import '../main_plugin_main.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

      final audioHelper = ModuleManager().getInstance<dynamic>("AudioHelper");
      audioHelper?.loopSpecific(context, audioHelper.backgroundSounds, "backsound_1",);

      appStateProvider.updateMainAppState('main_state', 'in_play');
      final currentPluginState = appStateProvider.getPluginState<Map<String, dynamic>>(pluginStateKey) ?? {};
      appStateProvider.updatePluginState(pluginStateKey, {
        ...currentPluginState, // Preserve the current state
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

      // Check SharedPreferences for the category
      final celebCategory = SharedPreferencesService().getString('celeb_category');

      // Check if the category is available
      if (celebCategory == null || celebCategory.isEmpty) {
        return;
      }

      // Retrieve the guessed celebrities for the category
      final guessedMapString = SharedPreferencesService().getString('guessed_celebs_map');
      final Map<String, dynamic> guessedCelebsMap = guessedMapString != null
          ? Map<String, dynamic>.from(jsonDecode(guessedMapString))
          : {};
      final guessedList = List<String>.from(guessedCelebsMap[celebCategory] ?? []);

      // Retrieve the level from SharedPreferences
      final levelKey = 'level_${celebCategory.replaceAll(" ", "_").toLowerCase()}';
      final level = SharedPreferencesService().getInt(levelKey) ?? 1; // Default level to 1

      // Pass the guessed list and level to the backend along with the category as JSON
      final payload = {
        'category': celebCategory,
        'guessed_list': guessedList,
        'level': level
      };
      final celebDetails = await PluginHelper.getCelebDetails(payload);
      dev.log('after getceleb before !context');

      dev.log('after !context ');

      // Use containsKey to check if the key exists in the Map
      if (celebDetails.containsKey('level_up')) {
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
          ...pluginState, // Preserve the existing state
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
      final audioHelper = ModuleManager().getInstance<dynamic>("AudioHelper");

      if (selectedName == pluginState['celeb_name']) {
        audioHelper?.playSpecific(
          context,
          audioHelper.correctSounds,
          "correct_1",
        );
        audioHelper?.stopSound(audioHelper.timerSounds, "ticking");
        appStateProvider.updatePluginState("MainPluginState", {
          ...pluginState, // Preserve the existing state
          'play_state': 'revealed_correct',
          'plugin_anims': {
            'head_anims': ['pulse', 'sideToSide', 'bounce'],
            'ribbon_anims': ['cut_tape'],
          }
        });


        // Update points and guessed data in SharedPreferences
        final currentPoints = SharedPreferencesService().getInt('points') ?? 0;
        final category = pluginState['celeb_category'] ?? "Unknown";
        final levelKey = 'level_${category.replaceAll(" ", "_").toLowerCase()}';
        final level = SharedPreferencesService().getInt(levelKey) ?? 1; // Default to level 1

        // Check the hint state
        final hintState = pluginState['hint'] ?? false;

        // Base points for level 1
        final basePoints = hintState == true ? 3 : 6;

        // Calculate additional points based on level
        final extraPoints = (level - 1) * 2;
        final pointsToAdd = basePoints + extraPoints;

        // Save updated points
        final updatedPoints = currentPoints + pointsToAdd;
        await SharedPreferencesService().setInt('points', updatedPoints);

        // Save guessed celebrity for the specific category
        final guessedMap = SharedPreferencesService().getString('guessed_celebs_map');
        final Map<String, dynamic> guessedCelebsMap = guessedMap != null
            ? Map<String, dynamic>.from(jsonDecode(guessedMap))
            : {};

        // Update the guessed list for the specific category
        final guessedList = List<String>.from(guessedCelebsMap[category] ?? []);
        if (!guessedList.contains(selectedName)) {
          guessedList.add(selectedName);
          guessedCelebsMap[category] = guessedList;
          await SharedPreferencesService().setString('guessed_celebs_map', jsonEncode(guessedCelebsMap));
        }

        dev.log("Points updated to $updatedPoints. Guessed celebrities for $category: $guessedList.");
      } else {
        audioHelper?.playSpecific(
          context,
          audioHelper.incorrectSounds,
          "incorrect_1",
        );
        audioHelper?.stopSound(audioHelper.timerSounds, "ticking");
        appStateProvider.updatePluginState("MainPluginState", {
          ...pluginState, // Preserve the existing state
          'play_state': 'revealed_incorrect',
          'flushing': true,
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
    final audioHelper = ModuleManager().getInstance<dynamic>("AudioHelper");
    final pluginState = appStateProvider.getPluginState<Map<String, dynamic>>(pluginStateKey) ?? {};
    audioHelper?.playFromList(
      context,
      audioHelper.flushingFiles,
    );
    // Update plugin state
    appStateProvider.updatePluginState("MainPluginState", {
      ...pluginState, // Preserve the existing state
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
        appStateProvider.updatePluginState("MainPluginState", {
          ...pluginState, // Preserve the existing state
          'play_state': 'aftermath_correct',
          'plugin_anims': {
            'aftermath_anims': ['slideUpAndDown'],
            'game_screen_anims': ['hue_and_bright']
          },
        });
      } else if (currentPlayState == 'revealed_incorrect') {
        appStateProvider.updatePluginState("MainPluginState", {
          ...pluginState, // Preserve the existing state
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
            appStateProvider.updatePluginState("AdmobsPluginState", {
              "interstitial01": {"isShowing": true},
            });
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





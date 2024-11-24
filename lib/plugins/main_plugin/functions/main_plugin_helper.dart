// plugins/shared_plugin/plugin_helper.dart
import 'package:flush_me_im_famous/plugins/main_plugin/functions/play_functions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../navigation/navigation_container.dart';
import '../../../providers/app_state_provider.dart';
import '../../../utils/consts/config.dart';
import '../../00_base/module_manager.dart';
import '../main_plugin_main.dart';
import '../screens/pref_screen.dart';
import '../screens/game_screen.dart';
import 'audio_helper.dart';

class PluginHelper {
  /// Fetches categories from the API and returns the response data
  static Future<dynamic> getCategories(AppStateProvider appStateProvider) async {
    print("getCategories: Starting category retrieval process.");

    final createConnectionModule = ModuleManager().getModule<Function>("ConnectionModule");
    final String baseUrl = Config.apiUrl;
    print("getCategories: Base URL set to $baseUrl");

    if (createConnectionModule != null) {
      print("getCategories: Connection module found, creating connection with base URL.");
      final connectionModule = createConnectionModule(baseUrl);

      try {
        print("getCategories: Sending GET request to /get-categories");
        final response = await connectionModule.sendGetRequest("/get-categories");
        print("getCategories: Received response - $response");

        // Check if response is a list and return it directly
        if (response is List && response.isNotEmpty) {
          print("getCategories: Response is a non-empty list. Returning response.");
          return response;
        } else {
          print("getCategories: Response is not a list or is empty.");
        }
      } catch (error) {
        print("getCategories: Error occurred while fetching categories - $error");
        // Handle error if needed
      }
    } else {
      print("getCategories: Connection module is null.");
    }

    print("getCategories: Returning an empty list as fallback.");
    return []; // Return an empty list if categories cannot be fetched
  }


  /// Updates the selected category in both app state and SharedPreferences
  static Future<void> updateCategory(String category, AppStateProvider appStateProvider, BuildContext context) async {
    final pluginStateKey = "${MainPlugin().runtimeType}State";

    // Update the app state with the new category and clear previous data
    appStateProvider.updatePluginState(pluginStateKey, {
      "celeb_category": category,
      "celeb_name": "",
      "celeb_img_url": "",
      "celeb_facts": []
    });

    // Save the selected category in SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("celeb_category", category);

    // Call handlePlayButton with context to initialize the play session
    await PlayFunctions.handlePlayButton(appStateProvider, context);
  }

  /// Fetches celebrity details based on a category from the API and returns the response data
  static Future<dynamic> getCelebDetails(String category) async {
    final createConnectionModule = ModuleManager().getModule<Function>("ConnectionModule");
    final String baseUrl = Config.apiUrl;

    if (createConnectionModule != null) {
      final connectionModule = createConnectionModule(baseUrl);
      try {
        // Encode the category to handle spaces and special characters
        final encodedCategory = Uri.encodeComponent(category);
        final response = await connectionModule.sendGetRequest(
          "/get-celeb-details?category=$encodedCategory",
        );
        return response; // Return the celebrity details response data
      } catch (error) {
        return {"error": "Failed to fetch celebrity details"};
      }
    } else {
      return {"error": "ConnectionModule not available"};
    }
  }


  static void registerNavigation(BuildContext context) {
    final navigationContainer = Provider.of<NavigationContainer>(context, listen: false);
    navigationContainer.registerNavigationLinks(
      drawerLinks: [
        ListTile(
          leading: const Icon(Icons.play_arrow),
          title: const Text('Play'),
          onTap: () {
            NavigationContainer.navigateTo('/play');
          },
        ),
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('Preferences'),
          onTap: () {
            NavigationContainer.navigateTo('/prefs');
          },
        ),
      ],
      bottomNavLinks: [],
      routes: {
        '/prefs': (context) => const PrefScreen(),
        '/play': (context) => const GameScreen(),
      },
    );
  }

  static void registerAppbarItems(BuildContext context) {
    final appStateProvider = Provider.of<AppStateProvider>(context, listen: false);
    final navigationContainer = Provider.of<NavigationContainer>(context, listen: false);

    navigationContainer.registerAppBarItems([
      StatefulBuilder(
        builder: (context, setState) {
          final isMuted = appStateProvider.getPluginState("MainPluginState")?["sound_muted"] ?? false;
          return IconButton(
            icon: Icon(isMuted ? Icons.volume_off : Icons.volume_up),
            onPressed: () {
              // Toggle the mute state
              appStateProvider.updatePluginState("MainPluginState", {
                "sound_muted": !isMuted,
              });

              // Update the audio volume based on the mute state
              AudioHelper().updateVolumeBasedOnState(context);

              // Refresh the icon state
              setState(() {});
            },
          );
        },
      ),
    ]);
  }


}

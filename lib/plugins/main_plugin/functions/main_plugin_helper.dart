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

    final createConnectionModule = ModuleManager().getModule<Function>("ConnectionModule");
    const String baseUrl = Config.apiUrl;

    if (createConnectionModule != null) {
      final connectionModule = createConnectionModule(baseUrl);

      try {
        final response = await connectionModule.sendGetRequest("/get-categories");

        // Check if response is a list and return it directly
        if (response is List && response.isNotEmpty) {
          return response;
        } else {
        }
      } catch (error) {
        // Handle error if needed
      }
    } else {
    }

    return []; // Return an empty list if categories cannot be fetched
  }

  static Future<void> updateCategory(String category, AppStateProvider appStateProvider, BuildContext context) async {
    final pluginStateKey = "${MainPlugin().runtimeType}State";

    appStateProvider.updatePluginState(pluginStateKey, {
      "celeb_category": category,
      "celeb_name": "",
      "celeb_img_url": "",
      "celeb_facts": []
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("celeb_category", category);

    // **FIX: Use addPostFrameCallback for safe context-dependent operations**
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PlayFunctions.handlePlayButton(appStateProvider, context);
    });
  }

  /// Fetches celebrity details based on a category from the API and returns the response data
  static Future<dynamic> getCelebDetails(String category) async {
    final createConnectionModule = ModuleManager().getModule<Function>("ConnectionModule");
    const String baseUrl = Config.apiUrl;

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

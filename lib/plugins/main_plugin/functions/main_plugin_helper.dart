// plugins/shared_plugin/plugin_helper.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../navigation/navigation_container.dart';
import '../../../utils/consts/config.dart';
import '../../00_base/module_manager.dart';
import '../screens/pref_screen.dart';
import '../screens/game_screen.dart';

class PluginHelper {
  /// Fetches categories from the API and returns the response data
  static Future<dynamic> getCategories() async {
    final createConnectionModule = ModuleManager().getModule<Function>("ConnectionModule");
    final String baseUrl = Config.apiUrl;

    if (createConnectionModule != null) {
      final connectionModule = createConnectionModule(baseUrl);
      try {
        final response = await connectionModule.sendGetRequest("/get-categories");
        print("Response from ConnectionModule: $response");
        return response; // Return the response data
      } catch (error) {
        print("Error fetching categories: $error");
        return {"error": "Failed to fetch categories"};
      }
    } else {
      print("ConnectionModule is not available");
      return {"error": "ConnectionModule not available"};
    }
  }

  /// Fetches celebrity details based on a category from the API and returns the response data
  static Future<dynamic> getCelebDetails(String category) async {
    final createConnectionModule = ModuleManager().getModule<Function>("ConnectionModule");
    final String baseUrl = Config.apiUrl;

    if (createConnectionModule != null) {
      final connectionModule = createConnectionModule(baseUrl);
      try {
        final response = await connectionModule.sendGetRequest(
          "/get-celeb-details?category=$category",
        );
        print("Response from ConnectionModule: $response");
        return response; // Return the celebrity details response data
      } catch (error) {
        print("Error fetching celebrity details: $error");
        return {"error": "Failed to fetch celebrity details"};
      }
    } else {
      print("ConnectionModule is not available");
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
}

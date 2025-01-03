// plugins/shared_plugin/plugin_helper.dart
import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'package:flush_me_im_famous/plugins/main_plugin/functions/play_functions.dart';
import 'package:flush_me_im_famous/plugins/main_plugin/screens/leaderboard_screen.dart';
import 'package:flush_me_im_famous/plugins/main_plugin/screens/levelup_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../navigation/navigation_container.dart';
import '../../../services/providers/app_state_provider.dart';
import '../../../utils/consts/config.dart';
import '../../00_base/module_manager.dart';
import '../modules/audio_module/audio_module.dart';
import '../screens/pref_screen.dart';
import '../screens/game_screen.dart';

class PluginHelper {
  /// Fetches categories from the API and returns the response data

  static Future<dynamic> getCategories(AppStateProvider appStateProvider) async {
    final createConnectionModule = ModuleManager().getFunction<Function>("ConnectionModule");
    const String baseUrl = Config.apiUrl;

    if (createConnectionModule != null) {
      final connectionModule = createConnectionModule(baseUrl);

      try {
        final response = await connectionModule.sendGetRequest("/get-categories");

        // Check if response is a list and process it
        if (response is List && response.isNotEmpty) {
          // Fetch SharedPreferences instance
          final prefs = await SharedPreferences.getInstance();

          // Retrieve and parse existing category levels from SharedPreferences
          final categoryLevels = jsonDecode(prefs.getString('category_levels') ?? "{}") as Map<String, dynamic>;

          // Iterate through each category and ensure it has a level set in SharedPreferences
          for (final category in response) {
            final normalizedCategoryKey = 'level_${category.replaceAll(' ', '_').toLowerCase()}';
            if (!categoryLevels.containsKey(normalizedCategoryKey)) {
              categoryLevels[normalizedCategoryKey] = 1; // Set default level to 1
            }
          }

          // Save updated category levels back to SharedPreferences
          await prefs.setString('category_levels', jsonEncode(categoryLevels));

          return response;
        }
      } catch (error) {
        // Handle error if needed
        print("Error in getCategories: $error");
      }
    } else {
      print("ConnectionModule not available.");
    }

    return []; // Return an empty list if categories cannot be fetched
  }


  static Future<void> updateCategory(String category, AppStateProvider appStateProvider, BuildContext context) async {

    appStateProvider.updatePluginState("MainPluginState", {
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
  /// Fetches celebrity details based on a category (and optionally username) from the API and returns the response data
  static Future<dynamic> getCelebDetails(Map<String, dynamic> payload) async {
    dev.log('get celeb details reached');
    final createConnectionModule = ModuleManager().getFunction<Function>("ConnectionModule");
    const String baseUrl = Config.apiUrl;

    if (createConnectionModule != null) {
      final connectionModule = createConnectionModule(baseUrl);
      try {
        // Construct the endpoint with query parameters
        final category = Uri.encodeComponent(payload['category']);
        final guessedList = Uri.encodeComponent(jsonEncode(payload['guessed_list']));
        final level = payload['level'] ?? 1;
        final url = "/get-celeb-details?category=$category&guessed_list=$guessedList&level=$level";

        dev.log('before sending GET request to $url');

        // Send GET request
        final response = await connectionModule.sendGetRequest(url);
        dev.log('after sending GET with response $response');
        return response; // Return the celebrity details response data
      } catch (error) {
        dev.log("Error in getCelebDetails: $error");
        return {"error": "Failed to fetch celebrity details"};
      }
    } else {
      dev.log("ConnectionModule not available in getCelebDetails.");
      return {"error": "ConnectionModule not available"};
    }
  }

  static void registerNavigation(BuildContext context, {List<String> drawerRoutes = const []}) {
    final navigationContainer = Provider.of<NavigationContainer>(context, listen: false);

    // Define route configuration for title and icons
    final Map<String, Map<String, dynamic>> routeConfig = {
      '/play': {
        'icon': const Icon(Icons.play_arrow),
        'title': 'Play',
      },
      '/prefs': {
        'icon': const Icon(Icons.settings),
        'title': 'Preferences',
      },
      '/levelup': {
        'icon': const Icon(Icons.arrow_upward),
        'title': 'Level Up',
      },
      '/leaderboard': {
        'icon': const Icon(Icons.arrow_upward),
        'title': 'Leaderboard',
      },
    };

    // Generate ListTile widgets for the drawer based on the specified routes
    final drawerLinks = drawerRoutes
        .where((route) => routeConfig.containsKey(route)) // Ensure route exists in config
        .map((route) {
      final config = routeConfig[route]!;
      return ListTile(
        leading: config['icon'] as Icon,
        title: Text(config['title'] as String),
        onTap: () {
          NavigationContainer.navigateTo(route);
        },
      );
    }).toList();

    // Register all routes (routes are always registered, regardless of drawer inclusion)
    navigationContainer.registerNavigationLinks(
      pluginKey: 'MainPlugin',
      drawerLinks: drawerLinks,
      bottomNavLinks: [],
      routes: {
        '/prefs': (context) => const PrefScreen(),
        '/play': (context) => const GameScreen(),
        '/levelup': (context) => LevelUpScreen(), // Registered but not in drawer
        '/leaderboard': (context) => LeaderboardScreen(), // Registered but not in drawer
      },
    );
  }

  static void registerAppbarItems(BuildContext context) {
    final appStateProvider = Provider.of<AppStateProvider>(context, listen: false);
    final navigationContainer = Provider.of<NavigationContainer>(context, listen: false);

    navigationContainer.registerAppBarItems(
      'MainPlugin', // Plugin key
      [
        StatefulBuilder(
          builder: (context, setState) {
            final appStateProvider = Provider.of<AppStateProvider>(context, listen: false);

            // Retrieve the AudioHelper function and create a new instance
            final audioHelperFactory = ModuleManager().getFunction<Function>("AudioHelper");
            if (audioHelperFactory == null) {
              dev.log("Error: AudioHelper function is not registered.");
              return const SizedBox(); // Return an empty widget if the function is not registered
            }
            final audioHelper = audioHelperFactory.call() as AudioHelper;

            // Retrieve the current mute state
            bool isMuted = appStateProvider.getPluginState("MainPluginState")?["sound_muted"] ?? false;

            return IconButton(
              icon: Icon(isMuted ? Icons.volume_off : Icons.volume_up),
              onPressed: () async {
                // Immediately toggle the local state
                isMuted = !isMuted;

                // Update the AppStateProvider asynchronously
                await audioHelper.toggleMute(context, isMuted);

                // Refresh the icon immediately
                setState(() {});
              },
            );
          },
        ),
      ],
    );
  }


  static Future<dynamic> getLeaderboard(AppStateProvider appStateProvider) async {
    final createConnectionModule = ModuleManager().getFunction<Function>("ConnectionModule");
    const String baseUrl = Config.apiUrl;

    if (createConnectionModule != null) {
      final connectionModule = createConnectionModule(baseUrl);

      try {
        final response = await connectionModule.sendGetRequest("/get-leaderboard");

        // Check if response is a list and contains valid data
        if (response is List && response.isNotEmpty) {
          // Ensure each item in the list has required keys
          final validLeaderboard = response.every((entry) =>
          entry is Map &&
              entry.containsKey('username') &&
              entry.containsKey('points'));
          if (validLeaderboard) {
            return response;
          } else {
            dev.log("Invalid leaderboard data format received.");
            return {"error": "Invalid leaderboard data format"};
          }
        } else {
          dev.log("Empty or invalid leaderboard response.");
          return [];
        }
      } catch (error) {
        dev.log("Error fetching leaderboard: $error");
        return {"error": "Failed to fetch leaderboard"};
      }
    } else {
      dev.log("ConnectionModule not available for fetching leaderboard.");
      return {"error": "ConnectionModule not available"};
    }
  }


  static void setTimer(BuildContext context) {
    final appStateProvider = Provider.of<AppStateProvider>(context, listen: false);
    final isTimed = appStateProvider.getPluginState("MainPluginState")?["timer"] ?? false;

    if (isTimed) return; // Prevent reinitializing an existing timer

    appStateProvider.updatePluginState("MainPluginState", {
      "timer": true,
      "secondsRemaining": 10,
    });

    Timer.periodic(Duration(seconds: 1), (timer) {
      final currentSeconds = appStateProvider.getPluginState("MainPluginState")?["secondsRemaining"] ?? 0;

      if (currentSeconds > 0) {
        appStateProvider.updatePluginState("MainPluginState", {
          "secondsRemaining": currentSeconds - 1,
        });
      } else {
        appStateProvider.updatePluginState("MainPluginState", {"timer": false});
        timer.cancel();
      }
    });
  }

}

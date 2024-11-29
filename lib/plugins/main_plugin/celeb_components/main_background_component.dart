import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';
import '../../../providers/app_state_provider.dart';

class MainBackgroundComponent extends StatelessWidget {
  const MainBackgroundComponent({Key? key}) : super(key: key);

  /// Get the user level dynamically from the app state
  Future<String> _getUserLevel(BuildContext context) async {
    try {
      // Retrieve the LoginModuleState
      final loginPluginState = context.read<AppStateProvider>().getPluginState<Map<String, dynamic>>("LoginModuleState");
      debugPrint("LoginModuleState: $loginPluginState");

      // Check if user is logged in
      final isLoggedIn = loginPluginState?['logged'] ?? false;
      if (!isLoggedIn) {
        debugPrint("User is not logged in. Returning 'guest'.");
        return 'guest';
      }

      // Ensure `level` is a string
      final userLevel = loginPluginState?['level'];
      if (userLevel == null || userLevel is! String) {
        debugPrint("User level is not a string or is null. Falling back to 'default'.");
        return 'default';
      }

      debugPrint("User level fetched successfully: $userLevel");
      return userLevel;
    } catch (e) {
      debugPrint("Error fetching user level: $e");
      return 'default';
    }
  }

  /// Load category based on user level
  Future<String> _loadCategory(String userLevel) async {
    // Example logic to derive category from user level
    if (userLevel == 'premium') {
      return 'premium_category';
    } else if (userLevel == 'standard') {
      return 'standard_category';
    } else {
      return 'default';
    }
  }

  /// Get the background image path based on the category and user level
  Future<String> _getBackgroundImagePath(String category, String userLevel) async {
    final backgroundImagePath = 'assets/images/backgrounds/$userLevel/main_background_$category.png';

    // Check if the background image file exists
    try {
      await rootBundle.load(backgroundImagePath);
      return backgroundImagePath;
    } catch (e) {
      // Fallback to a default overlay background
      return 'assets/images/backgrounds/main_background_default_001.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getUserLevel(context), // Step 1: Fetch user level
      builder: (context, levelSnapshot) {
        if (levelSnapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.expand(
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (levelSnapshot.hasError) {
          return const SizedBox.expand(
            child: Center(child: Text("Error loading user level")),
          );
        } else {
          final userLevel = levelSnapshot.data!;

          return FutureBuilder<String>(
            future: _loadCategory(userLevel), // Step 2: Derive category based on user level
            builder: (context, categorySnapshot) {
              if (categorySnapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox.expand(
                  child: Center(child: CircularProgressIndicator()),
                );
              } else if (categorySnapshot.hasError) {
                return const SizedBox.expand(
                  child: Center(child: Text("Error loading category")),
                );
              } else {
                final category = categorySnapshot.data!;

                return FutureBuilder<String>(
                  future: _getBackgroundImagePath(category, userLevel), // Step 3: Get background image path
                  builder: (context, imageSnapshot) {
                    if (imageSnapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox.expand(
                        child: Center(child: CircularProgressIndicator()),
                      );
                    } else if (imageSnapshot.hasError) {
                      return const SizedBox.expand(
                        child: Center(child: Text("Error loading background image")),
                      );
                    } else {
                      final backgroundImagePath = imageSnapshot.data!;

                      return SizedBox.expand(
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(backgroundImagePath),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    }
                  },
                );
              }
            },
          );
        }
      },
    );
  }
}

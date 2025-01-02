import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';
import '../../../services/providers/app_state_provider.dart';
import '../../../services/shared_preferences_service.dart';

class MainBackgroundOverlayComponent extends StatelessWidget {
  const MainBackgroundOverlayComponent({Key? key}) : super(key: key);

  /// Fetch the category from MainPluginState
  String _getCategoryFromState(BuildContext context) {
    final mainPluginState = context.read<AppStateProvider>().getPluginState<Map<String, dynamic>>("MainPluginState");
    final category = mainPluginState?['celeb_category']?.replaceAll(' ', '_').toLowerCase() ?? 'default';
    debugPrint("Fetched and transformed category from MainPluginState: $category");
    return category;
  }

  /// Get the user level dynamically from SharedPreferences for the category
  Future<String> _getUserLevel(String category) async {
    try {
      final levelKey = 'level_${category.replaceAll(" ", "_").toLowerCase()}';
      final level = SharedPreferencesService().getInt(levelKey) ?? 1; // Default level to 1
      return level.toString();
    } catch (e) {
      debugPrint("Error fetching user level for category $category: $e");
      return '1';
    }
  }

  /// Get the background image path based on the category and user level
  Future<String> _getBackgroundImagePath(String category, String userLevel) async {
    final backgroundImagePath = 'assets/images/backgrounds/lev$userLevel/$category/main_background_overlay_$category.png';
    debugPrint("Background image path: $backgroundImagePath");
    try {
      await rootBundle.load(backgroundImagePath);
      return backgroundImagePath;
    } catch (e) {
      debugPrint("Failed to load background image at $backgroundImagePath. Falling back to default.");
      return 'assets/images/backgrounds/main_background_default.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final category = _getCategoryFromState(context); // Fetch category from MainPluginState

    return FutureBuilder<String>(
      future: _getUserLevel(category), // Step 1: Fetch user level from SharedPreferences
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
            future: _getBackgroundImagePath(category, userLevel), // Step 2: Get background image path
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
}

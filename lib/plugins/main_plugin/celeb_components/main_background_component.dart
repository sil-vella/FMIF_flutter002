// main_background_component.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

class MainBackgroundComponent extends StatelessWidget {
  const MainBackgroundComponent({Key? key}) : super(key: key);

  Future<String> _loadCategory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('celeb_category') ?? 'default';
  }

  Future<String> _getBackgroundImagePath(String category) async {
    final backgroundImagePath = 'assets/app_images/main_background_$category.png';

    // Check if the background image file exists
    try {
      await rootBundle.load(backgroundImagePath);
      return backgroundImagePath;
    } catch (e) {
      return 'assets/app_images/main_background_default.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _loadCategory(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.expand(
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return const SizedBox.expand(
            child: Center(child: Text("Error loading background")),
          );
        } else {
          final category = snapshot.data!;

          return FutureBuilder<String>(
            future: _getBackgroundImagePath(category),
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart'; // Import the confetti package
import '../../../providers/app_state_provider.dart';

class LevelUpScreen extends StatefulWidget {
  @override
  _LevelUpScreenState createState() => _LevelUpScreenState();
}

class _LevelUpScreenState extends State<LevelUpScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    // Initialize the controller for continuous play
    _confettiController = ConfettiController(duration: const Duration(seconds: 10));
    _confettiController.play(); // Start the confetti animation
    _loopFireworks(); // Loop the animation
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _loopFireworks() {
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        _confettiController.play(); // Restart the animation
        _loopFireworks(); // Continue looping
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Consumer<AppStateProvider>(
            builder: (context, appStateProvider, _) {
              // Fetch states dynamically
              final mainPluginState = appStateProvider.getPluginState<Map<String, dynamic>>("MainPluginState") ?? {};
              final loginPluginState = appStateProvider.getPluginState<Map<String, dynamic>>("LoginPluginState") ?? {};

              // Extract values from states
              final isLoggedIn = loginPluginState['logged'] ?? false;
              final selectedCategory = mainPluginState['celeb_category'] ?? "Unknown";
              final transformedCategory = 'level_${selectedCategory.replaceAll(' ', '_').toLowerCase()}';
              final categoryLevel = loginPluginState['category_levels']?[transformedCategory]?.toString() ?? 'N/A';
              final points = loginPluginState['points']?.toString() ?? "-";

              return FutureBuilder<String>(
                future: _getBackgroundImagePath(selectedCategory, categoryLevel),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(child: Text("Error loading background image"));
                  } else {
                    return Container(
                      // Make the background take up the full screen
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(snapshot.data!),
                          fit: BoxFit.cover, // Ensures the image covers the entire screen
                        ),
                      ),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(16.0), // Add padding inside the container
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8), // Slightly opaque white background
                            borderRadius: BorderRadius.circular(8.0), // Rounded corners
                          ),
                          child: isLoggedIn // Conditionally render content based on login state
                              ? Column(
                            mainAxisSize: MainAxisSize.min, // Centers the content vertically
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: Text(
                                  "$selectedCategory\nLevel ${_getPreviousLevel(categoryLevel)} completed!!",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black, // Update text color to contrast with the light background
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16.0), // Add spacing between elements
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/play'); // Navigate to the /play route
                                },
                                child: Text(
                                  "Level $categoryLevel",
                                ),
                              ),
                            ],
                          )
                              : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Please log in to view your level details.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black, // Update text color to contrast with the light background
                                ),
                              ),
                              const SizedBox(height: 20), // Add some spacing
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/'); // Navigate to the /home route
                                },
                                child: const Text(
                                  "Go to Home",
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    );
                  }
                },
              );
            },
          ),
          // Add the confetti widget
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive, // Make it radial
              emissionFrequency: 0.05,
              numberOfParticles: 30,
              gravity: 0.1, // Slow falling effect
            ),
          ),
        ],
      ),
    );
  }

  /// Helper function to calculate the previous level
  String _getPreviousLevel(String level) {
    final parsedLevel = int.tryParse(level);
    return parsedLevel != null && parsedLevel > 0 ? (parsedLevel - 1).toString() : "Unknown";
  }

  /// Updated `_getBackgroundImagePath` function
  Future<String> _getBackgroundImagePath(String category, String categoryLevel) async {
    final backgroundImagePath = 'assets/images/backgrounds/lev$categoryLevel/$category/lev_complete_$category.png';
    try {
      await rootBundle.load(backgroundImagePath);
      return backgroundImagePath;
    } catch (_) {
      return 'assets/images/backgrounds/lev_complete_default.png';
    }
  }
}

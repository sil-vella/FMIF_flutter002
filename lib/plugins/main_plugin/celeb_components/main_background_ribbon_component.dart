import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../providers/app_state_provider.dart';
import '../functions/animation_helper.dart';
import '../main_plugin_main.dart';

class RibbonComponent extends StatefulWidget {
  const RibbonComponent({Key? key}) : super(key: key);

  @override
  _RibbonComponentState createState() => _RibbonComponentState();
}

class _RibbonComponentState extends State<RibbonComponent>
    with TickerProviderStateMixin {
  late final AnimationController shrinkController;
  late final AnimationHelper animationHelper;

  @override
  void initState() {
    super.initState();
    animationHelper = AnimationHelper();
    shrinkController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
  }

  @override
  void dispose() {
    shrinkController.dispose();
    super.dispose();
  }

  Future<String> _loadCategory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('celeb_category') ?? 'default';
  }

  Future<String> _getBackgroundImagePath(String category) async {
    final backgroundImagePath = 'assets/app_images/ribbon_$category.png';

    try {
      await rootBundle.load(backgroundImagePath);
      return backgroundImagePath;
    } catch (e) {
      return 'assets/app_images/ribbon.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final pluginStateKey = "${MainPlugin().runtimeType}State";

    // Retrieve play state and ribbon animations
    final String? playState = context.select<AppStateProvider, String?>((appStateProvider) {
      final pluginState = appStateProvider.getPluginState<Map<String, dynamic>>(pluginStateKey) ?? {};
      return pluginState['play_state'] as String?;
    });

    final bool flushing = context.select<AppStateProvider, bool>((appStateProvider) {
      final pluginState = appStateProvider.getPluginState<Map<String, dynamic>>(pluginStateKey) ?? {};
      return pluginState['flushing'] as bool? ?? false; // Default to false if 'flushing' is null
    });

    // Retrieve ribbonAnims as List<String> safely
    final List<String> ribbonAnims = List<String>.from(
      context.select<AppStateProvider, List<dynamic>?>((appStateProvider) {
        final pluginState = appStateProvider.getPluginState<Map<String, dynamic>>(pluginStateKey) ?? {};
        return pluginState['plugin_anims']?['ribbon_anims'] ?? [];
      }) ?? [],
    );

    // Conditionally render the component only if not in aftermath states
    if (playState == 'aftermath_correct' || playState == 'aftermath_incorrect' || flushing == true)  {
      return const SizedBox.shrink();
    }

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
                Widget ribbonChild = Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(backgroundImagePath),
                      fit: BoxFit.cover,
                    ),
                  ),
                );

                // Apply the shrink and slide-down animation if specified
                if (playState == 'revealed_correct' || playState == 'revealed_incorrect' || playState == 'aftermath_incorrect' )  {
                  if (ribbonAnims.contains('shrinkAndSlideDown')) {
                    ribbonChild = animationHelper.shrinkAndSlideDown(
                      ribbonChild,
                      controller: shrinkController,
                      scaleCurve: Curves.easeInOut,
                      slideCurve: Curves.easeIn,
                      infinite: false, // Set to true if you want looping behavior
                      onComplete: () {
                      },
                    );
                  }
                }

                return ribbonChild;
              }
            },
          );
        }
      },
    );
  }
}

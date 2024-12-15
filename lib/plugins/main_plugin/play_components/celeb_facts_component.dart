import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/providers/app_state_provider.dart';
import '../../../utils/consts/theme_consts.dart';
import '../main_plugin_main.dart';

class CelebFactsComponent extends StatelessWidget {
  const CelebFactsComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pluginStateKey = "MainPluginState";

    // Listen for changes to celeb_facts
    final celebFacts = context.select<AppStateProvider, List<String>>((appStateProvider) {
      final pluginState = appStateProvider.getPluginState<Map<String, dynamic>>(pluginStateKey) ?? {};
      return List<String>.from(pluginState['celeb_facts'] ?? []);
    });

    // If celeb_facts is empty, display a placeholder message
    if (celebFacts.isEmpty) {
      return Container(
        color: AppColors.accentColor2,
        padding: const EdgeInsets.all(16.0),
        child: const Center(
          child: Text(
            "No facts available",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      );
    }

    return Container(
      color: AppColors.accentColor2, // Accent color for the background
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.2,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Facts:",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // Black text
                ),
              ),
              const SizedBox(height: 8),
              for (var fact in celebFacts)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 4),
                  child: Text(
                    "• $fact",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.black, // Black text for the facts
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

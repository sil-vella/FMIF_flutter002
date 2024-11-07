import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_state_provider.dart';
import '../main_plugin_main.dart';

class CelebFactsComponent extends StatelessWidget {
  const CelebFactsComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appStateProvider = Provider.of<AppStateProvider>(context);
    final pluginStateKey = "${MainPlugin().runtimeType}State";
    final pluginState = appStateProvider.getPluginState<Map<String, dynamic>>(pluginStateKey) ?? {};

    // Retrieve celebrity data from plugin state
    final celebFacts = pluginState['celeb_facts'] ?? [];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.2, // Set max height to 40% of screen
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Facts:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              for (var fact in celebFacts)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 4),
                  child: Text("• $fact", style: TextStyle(fontSize: 14)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

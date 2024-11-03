import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_state_provider.dart';
import '../main_plugin_main.dart';

class MainCelebComponent extends StatelessWidget {
  const MainCelebComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appStateProvider = Provider.of<AppStateProvider>(context);
    final pluginStateKey = "${MainPlugin().runtimeType}State";
    final pluginState = appStateProvider.getPluginState<Map<String, dynamic>>(pluginStateKey) ?? {};

    // Retrieve celebrity data from plugin state
    final celebName = pluginState['celeb_name'] ?? "Unknown";
    final celebImgUrl = pluginState['celeb_img_url'];
    final celebFacts = pluginState['celeb_facts'] ?? [];
    final otherCelebs = pluginState['other_celebs'] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          "Celebrity Details",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        if (celebImgUrl != null)
          Center(
            child: Image.network(
              celebImgUrl,
              width: 150,
              height: 150,
              fit: BoxFit.cover,
            ),
          ),
        const SizedBox(height: 16),
        Text(
          "Name: $celebName",
          style: TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 12),
        Text(
          "Facts:",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        for (var fact in celebFacts)
          Padding(
            padding: const EdgeInsets.only(left: 8.0, top: 4),
            child: Text("• $fact", style: TextStyle(fontSize: 14)),
          ),
        const SizedBox(height: 12),
        Text(
          "Other Celebrities:",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        for (var otherCeleb in otherCelebs)
          Padding(
            padding: const EdgeInsets.only(left: 8.0, top: 4),
            child: Text("• $otherCeleb", style: TextStyle(fontSize: 14)),
          ),
      ],
    );
  }
}

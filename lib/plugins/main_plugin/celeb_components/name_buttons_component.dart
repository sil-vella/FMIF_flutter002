import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';

import '../../../providers/app_state_provider.dart';
import '../functions/play_functions.dart';
import '../main_plugin_main.dart';

class NameButtonsComponent extends StatelessWidget {
  const NameButtonsComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pluginStateKey = "${MainPlugin().runtimeType}State";
    final appStateProvider = Provider.of<AppStateProvider>(context, listen: false);

    // Listen to `play_state` to control visibility of name buttons and Flush!! button
    final playState = context.select<AppStateProvider, String?>((appStateProvider) {
      final pluginState = appStateProvider.getPluginState<Map<String, dynamic>>(pluginStateKey) ?? {};
      return pluginState['play_state'] as String?;
    });

    // Show name buttons only if play_state is `in_play`
    final showNameButtons = playState == 'in_play';

    // Show Flush!! button only if play_state is `revealed_correct`
    final showFlushButton = playState == 'revealed_correct';

    // Retrieve celebrity data from plugin state with null checks
    final pluginState = appStateProvider.getPluginState<Map<String, dynamic>>(pluginStateKey) ?? {};
    final String? celebName = pluginState['celeb_name'] as String?;
    final otherNames = List<String>.from(pluginState['other_celebs'] ?? <String>[]);

    // Combine celebName and otherNames into one list, then shuffle
    final names = [
      if (celebName != null) celebName, // Add celebName only if it’s not null
      ...otherNames
    ];
    names.shuffle(Random());

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, // Center items in the column
          children: [
            if (showNameButtons)
              Wrap(
                alignment: WrapAlignment.center, // Center the wrap
                spacing: 8.0, // Spacing between buttons
                runSpacing: 8.0, // Spacing between rows of buttons
                children: names.map((name) {
                  return ElevatedButton(
                    onPressed: () {
                      // Call selectedCeleb function with the selected name
                      PlayFunctions.selectedCeleb(appStateProvider, pluginStateKey, name);
                    },
                    child: Text(name),
                  );
                }).toList(),
              ),
            if (showFlushButton)
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: ElevatedButton(
                  onPressed: () {
                    // Define what should happen when "Flush!!" is pressed
                    PlayFunctions.flushAction(appStateProvider, pluginStateKey); // Example action
                  },
                  child: Text("Flush!!"),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

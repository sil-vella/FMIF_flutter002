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
    final appStateProvider = Provider.of<AppStateProvider>(context);
    final pluginStateKey = "${MainPlugin().runtimeType}State";
    final pluginState = appStateProvider.getPluginState<Map<String, dynamic>>(pluginStateKey) ?? {};

    // Retrieve celebrity data from plugin state
    final celebName = pluginState['celeb_name'];
    final otherNames = List<String>.from(pluginState['other_celebs'] ?? []);

    // Combine celebName and otherNames into one list, then shuffle
    final names = [celebName, ...otherNames];
    names.shuffle(Random());

    return Container(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8.0, // Spacing between buttons
            runSpacing: 8.0, // Spacing between rows of buttons
            children: names.map((name) {
              return ElevatedButton(
                onPressed: () {
                  // Call selectedCeleb function with the selected name
                  PlayFunctions().selectedCeleb(appStateProvider, pluginState, pluginStateKey, name);
                },
                child: Text(name),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

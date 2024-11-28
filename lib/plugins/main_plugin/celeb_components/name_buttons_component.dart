import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';

import '../../../providers/app_state_provider.dart';
import '../../00_base/module_manager.dart';
import '../functions/play_functions.dart';
import '../main_plugin_main.dart';

class NameButtonsComponent extends StatefulWidget {
  const NameButtonsComponent({Key? key}) : super(key: key);

  @override
  State<NameButtonsComponent> createState() => _NameButtonsComponentState();
}

class _NameButtonsComponentState extends State<NameButtonsComponent> {
  bool _hasUsedRemoveOption = false; // Tracks if the "Remove one option" button has been used

  @override
  Widget build(BuildContext context) {
    final pluginStateKey = "${MainPlugin().runtimeType}State";
    final appStateProvider = Provider.of<AppStateProvider>(context, listen: false);

    // Listen to `play_state` to control visibility of name buttons and Flush!! button
    final playState = context.select<AppStateProvider, String?>((appStateProvider) {
      final pluginState = appStateProvider.getPluginState<Map<String, dynamic>>(pluginStateKey) ?? {};
      return pluginState['play_state'] as String?;
    });

    // Listen to `other_celebs` for updates
    final otherCelebs = context.select<AppStateProvider, List<String>>((appStateProvider) {
      final pluginState = appStateProvider.getPluginState<Map<String, dynamic>>(pluginStateKey) ?? {};
      return List<String>.from(pluginState['other_celebs'] ?? []);
    });

    // Listen to `hint` state and reset `_hasUsedRemoveOption` when `hint` changes to `false`
    final showRemoveOptionButton = context.select<AppStateProvider, bool>((appStateProvider) {
      final pluginState = appStateProvider.getPluginState<Map<String, dynamic>>(pluginStateKey) ?? {};
      final hint = pluginState['hint'] as bool? ?? false;

      // Reset _hasUsedRemoveOption if hint is false
      if (!hint && _hasUsedRemoveOption) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            _hasUsedRemoveOption = false;
          });
        });
      }

      // Show button only if `hint` is false and `play_state` is 'in_play'
      return !hint && playState == 'in_play';
    });

    // Show name buttons only if `play_state` is `in_play`
    final showNameButtons = playState == 'in_play';

    // Show Flush!! button only if `play_state` is `revealed_correct`
    final showFlushButton = playState == 'revealed_correct';

    // Retrieve celebrity data from plugin state with null checks
    final String? celebName = appStateProvider.getPluginState<Map<String, dynamic>>(pluginStateKey)?['celeb_name'] as String?;

    // Combine celebName and otherCelebs into one list, then shuffle
    final names = [
      if (celebName != null) celebName, // Add celebName only if it’s not null
      ...otherCelebs,
    ];
    names.shuffle(Random());

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, // Center items in the column
          children: [
            // Full-width button for "Remove one option" (only show if not used yet and conditions are met)
            if (!_hasUsedRemoveOption && showRemoveOptionButton)
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: SizedBox(
                  width: double.infinity, // Make the button full width
                  child: ElevatedButton(
                    onPressed: () {
                      // Trigger the rewarded ad to remove one option
                      _triggerRewardedAdToRemoveOption(
                        appStateProvider,
                        pluginStateKey,
                        names,
                      );
                    },
                    child: const Text("Help! Remove one option"),
                  ),
                ),
              ),
            if (showNameButtons)
              Wrap(
                alignment: WrapAlignment.center, // Center the wrap
                spacing: 8.0, // Spacing between buttons
                runSpacing: 8.0, // Spacing between rows of buttons
                children: names.map((name) {
                  return ElevatedButton(
                    onPressed: () {
                      // Call selectedCeleb function with the selected name
                      PlayFunctions.selectedCeleb(appStateProvider, pluginStateKey, name, context);
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
                    PlayFunctions.flushAction(appStateProvider, pluginStateKey, context); // Example action
                  },
                  child: const Text("Flush!!"),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _triggerRewardedAdToRemoveOption(
      AppStateProvider appStateProvider,
      String pluginStateKey,
      List<String> names,
      ) {
    // Retrieve the RewardedAdModule factory from ModuleManager
// Retrieve the RewardedAdService instance dynamically from ModuleManager
    final rewardedAdService = ModuleManager().getInstance<dynamic>("RewardedAdService");

    if (rewardedAdService != null) {
      // Use Function.apply to dynamically call the showAd method
      Function.apply(
        rewardedAdService.showAd,
        [], // No positional arguments
        {
          #appStateProvider: appStateProvider, // Pass AppStateProvider
          #context: context,                  // Pass BuildContext
        },
      );

      // Hide the button immediately after use
      setState(() {
        _hasUsedRemoveOption = true;
      });
    } else {
      // Handle case where RewardedAdService is not registered
      print("RewardedAdService is not registered in ModuleManager.");
    }

  }
}

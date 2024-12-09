import 'package:flush_me_im_famous/utils/consts/theme_consts.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'package:auto_size_text/auto_size_text.dart';
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
    final pluginStateKey = "MainPluginState";
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
                padding: const EdgeInsets.only(bottom: 5.0), // Match the margin of the name buttons row
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0), // Apply horizontal padding
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center, // Center the button in the row
                    children: [
                      Expanded(
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
                    ],
                  ),
                ),
              ),

            if (showNameButtons)
            // Full-width row to hold name buttons with matching margin as the "Help!" button
              Padding(
                padding: const EdgeInsets.only(bottom: 0.0), // Match the "Help!" button margin
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0), // Apply horizontal padding
                  child: Container(
                    color: AppColors.accentColor, // Apply background color to the row (replace Colors.blue with your desired color)
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center, // Center the buttons in the row
                      children: names.asMap().map((index, name) {
                        // Split the name into first and last name
                        List<String> nameParts = name.split(' '); // Split into parts based on space
                        String firstName = nameParts[0];
                        String surname = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

                        // Determine if the button is the middle one (if odd number of buttons)
                        bool isMiddleButton = names.length % 2 != 0 && index == names.length ~/ 2;

                        return MapEntry(
                          index,
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(1.0), // Add padding between buttons
                              child: Container(
                                decoration: BoxDecoration(
                                  border: isMiddleButton
                                      ? const Border(
                                    left: BorderSide(color: Colors.black, width: 2.0),
                                    right: BorderSide(color: Colors.black, width: 2.0),
                                  )
                                      : null, // Only add border to the middle button
                                ),
                                child: ElevatedButton(
                                  onPressed: () {
                                    // Call selectedCeleb function with the selected name
                                    PlayFunctions.selectedCeleb(appStateProvider, pluginStateKey, name, context);
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: WidgetStateProperty.all(Colors.transparent), // Remove the background color from the button
                                    overlayColor: WidgetStateProperty.all(Colors.transparent), // Remove the overlay effect
                                    elevation: WidgetStateProperty.all(0), // Remove the button's elevation
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center, // Center the names vertically
                                    crossAxisAlignment: CrossAxisAlignment.center, // Center the names horizontally
                                    children: [
                                      AutoSizeText(
                                        firstName,
                                        style: const TextStyle(
                                          fontSize: 16, // Set a base font size for first name
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 1, // Ensure the text doesn't overflow and stays on one line
                                        minFontSize: 12, // Minimum font size the text can shrink to
                                      ),
                                      if (surname.isNotEmpty) // Show surname only if it exists
                                        AutoSizeText(
                                          surname,
                                          style: const TextStyle(
                                            fontSize: 14, // Smaller font size for surname
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 1, // Ensure the text doesn't overflow
                                          minFontSize: 10, // Minimum font size the text can shrink to
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).values.toList(),
                    ),
                  ),
                ),
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
    }
  }
}

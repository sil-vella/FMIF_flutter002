// pref_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../screens/base_screen.dart';
import '../../../providers/app_state_provider.dart';
import '../../main_plugin/main_plugin_main.dart';

class ScreenOne extends BaseScreen {
  const ScreenOne({Key? key}) : super(key: key);

  @override
  String get title => "Screen One";

  @override
  Widget buildContent(BuildContext context) {
    final pluginStateKey = "${MainPlugin().runtimeType}State"; // Dynamically generate the state key

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Welcome to Screen One!"),
          const SizedBox(height: 20),
          // Display current state_example value
          Selector<AppStateProvider, int?>(
            selector: (context, appStateProvider) =>
            appStateProvider.getPluginState<Map<String, dynamic>>(pluginStateKey)?["state_example"],
            builder: (context, stateExample, child) {
              return Text("State Example: ${stateExample ?? 'N/A'}");
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              final appStateProvider = Provider.of<AppStateProvider>(context, listen: false);
              final currentState = appStateProvider.getPluginState<Map<String, dynamic>>(pluginStateKey);

              if (currentState != null && currentState.containsKey("state_example")) {
                appStateProvider.updatePluginState(
                  pluginStateKey,
                  {
                    "state_example": currentState["state_example"] + 1,
                  },
                );
              }
            },
            child: const Text("Increment State Example"),
          ),
        ],
      ),
    );
  }
}

// plugins/shared_plugin/admobs_main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../navigation/navigation_container.dart';
import '../../providers/app_state_provider.dart';
import '../../utils/consts/config.dart';
import '../00_base/app_plugin.dart';
import '../00_base/module_manager.dart';
import 'screens/screen_one.dart';
import 'screens/screen_two.dart';

class PluginExample implements AppPlugin {
  PluginExample._internal();

  static final PluginExample _instance = PluginExample._internal();

  factory PluginExample() => _instance;

  @override
  void initialize(BuildContext context) {
    print("PluginExample initialized");

    registerModules(); // Register any shared modules required by the plugin
    registerNavigation(context); // Register navigation items with context
    Provider.of<AppStateProvider>(context, listen: false)
        .registerPluginState("PluginBState", {"state_example": 0}); // Set plugin state

    connectToDb(); // Connect to the database if needed
  }

  @override
  void registerModules() {
    // Define modules if needed
  }

  /// Register navigation items for the shared plugin
  void registerNavigation(BuildContext context) {
    final navigationContainer = Provider.of<NavigationContainer>(context, listen: false);
    navigationContainer.registerNavigationLinks(
      drawerLinks: [
        ListTile(
          leading: const Icon(Icons.share),
          title: const Text('Screen One'),
          onTap: () {
            NavigationContainer.navigateTo('/screen_one'); // Use the route
          },
        ),
      ],
      bottomNavLinks: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.share),
          label: 'Screen One',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Screen Two',
        ),
      ],
      routes: {
        '/screen_one': (context) => const ScreenOne(),
        '/screen_two': (context) => const ScreenTwo(),
      },
    );
  }

  void connectToDb() {
    final createConnectionModule = ModuleManager().getModule<Function>("ConnectionModule");
    final String baseUrl = Config.apiUrl;

    if (createConnectionModule != null) {
      final connectionModule = createConnectionModule(baseUrl);
      connectionModule.sendGetRequest("/endpoint").then((response) {
        print("Response from ConnectionModule: $response");
      });
    } else {
      print("ConnectionModule is not available");
    }
  }
}

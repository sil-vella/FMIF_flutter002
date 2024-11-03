// plugins/shared_plugin/plugin_helper.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../navigation/navigation_container.dart';
import '../../../utils/consts/config.dart';
import '../../00_base/module_manager.dart';
import '../screens/screen_one.dart';
import '../screens/screen_two.dart';

class PluginHelper {
  static void connectToDb() {
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

  static void registerNavigation(BuildContext context) {
    final navigationContainer = Provider.of<NavigationContainer>(context, listen: false);
    navigationContainer.registerNavigationLinks(
      drawerLinks: [
        ListTile(
          leading: const Icon(Icons.share),
          title: const Text('Screen One'),
          onTap: () {
            NavigationContainer.navigateTo('/screen_one');
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
}

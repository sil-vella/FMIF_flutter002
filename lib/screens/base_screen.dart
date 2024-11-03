// base_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../navigation/navigation_container.dart';
import '../plugins/00_base/module_manager.dart';

abstract class BaseScreen extends StatelessWidget {
  const BaseScreen({Key? key}) : super(key: key);

  String get title;
  Widget buildContent(BuildContext context);

  @override
  Widget build(BuildContext context) {
    final navigationContainer = Provider.of<NavigationContainer>(context);

    // Retrieve BannerAdWidget if it has been registered by AdmobsPlugin
    final bannerModuleFactory = ModuleManager().getModule<Function>("BannerModule");
    final bannerWidget = bannerModuleFactory != null ? bannerModuleFactory() as Widget : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      drawer: navigationContainer.buildDrawer(context),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: buildContent(context), // Main content of the screen
          ),
          if (bannerWidget != null) ...[
            bannerWidget, // Display banner ad above the bottom navigation bar
          ],
        ],
      ),
      bottomNavigationBar: navigationContainer.buildBottomNavigationBar(),
    );
  }
}

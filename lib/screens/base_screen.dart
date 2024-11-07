import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../navigation/navigation_container.dart';
import '../plugins/00_base/module_manager.dart';

abstract class BaseScreen extends StatefulWidget {
  const BaseScreen({Key? key}) : super(key: key);

  String get title;

  @override
  BaseScreenState createState();
}

abstract class BaseScreenState<T extends BaseScreen> extends State<T> {
  @override
  Widget build(BuildContext context) {
    final navigationContainer = Provider.of<NavigationContainer>(context);

    // Retrieve BannerAdWidget if it has been registered by AdmobsPlugin
    final bannerModuleFactory = ModuleManager().getModule<Function>("BannerModule");
    final bannerWidget = bannerModuleFactory != null ? bannerModuleFactory() as Widget : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
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

  /// Abstract method to be implemented in subclasses
  Widget buildContent(BuildContext context);
}

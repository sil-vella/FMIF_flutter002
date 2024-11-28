import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../navigation/navigation_container.dart';
import '../plugins/00_base/module_manager.dart';

abstract class BaseScreen extends StatefulWidget {
  const BaseScreen({Key? key}) : super(key: key);

  /// Define a method to compute the title dynamically
  String computeTitle(BuildContext context);

  @override
  BaseScreenState createState();
}

abstract class BaseScreenState<T extends BaseScreen> extends State<T> {
  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationContainer>(
      builder: (context, navigationContainer, child) {
        // Dynamically retrieve the BannerAd widget factory function
        final bannerWidgetFactory = ModuleManager().getFunction<Function>("BannerModule");
        final bannerWidget = bannerWidgetFactory != null ? bannerWidgetFactory() : null;

        return Scaffold(
          appBar: AppBar(
            // Dynamically compute the title using the widget's computeTitle method
            title: Text(widget.computeTitle(context)),
            actions: [
              ...navigationContainer.appBarActions, // Dynamically updated AppBar actions
            ],
          ),
          drawer: navigationContainer.buildDrawer(context),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: buildContent(context), // Main content of the screen
              ),
              if (bannerWidget != null) ...[
                bannerWidget, // Dynamically display the banner ad
              ],
            ],
          ),
          bottomNavigationBar: navigationContainer.buildBottomNavigationBar(),
        );
      },
    );
  }

  /// Abstract method to be implemented in subclasses
  Widget buildContent(BuildContext context);
}

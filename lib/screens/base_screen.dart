// base_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../navigation/navigation_container.dart';
import '../plugins/admobs/modules/banner/banner_ad_widget.dart';

abstract class BaseScreen extends StatelessWidget {
  const BaseScreen({Key? key}) : super(key: key);

  String get title;
  Widget buildContent(BuildContext context);

  @override
  Widget build(BuildContext context) {
    final navigationContainer = Provider.of<NavigationContainer>(context);

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
          const BannerAdWidget(), // Banner ad widget goes here
        ],
      ),
      bottomNavigationBar: navigationContainer.buildBottomNavigationBar(),
    );
  }
}

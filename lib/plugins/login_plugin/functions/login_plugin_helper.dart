import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../navigation/navigation_container.dart';
import '../screens/login_screen.dart';

class PluginHelper {

  static void registerNavigation(BuildContext context) {
    final navigationContainer = Provider.of<NavigationContainer>(
        context, listen: false);
    navigationContainer.registerNavigationLinks(
      drawerLinks: [
        ListTile(
          leading: const Icon(Icons.account_circle), // Updated icon
          title: const Text('Account'),
          onTap: () {
            NavigationContainer.navigateTo('/login');
          },
        )
      ],
      bottomNavLinks: [],
      routes: {
        '/login': (context) => const LoginScreen(),
      },
    );
  }

}

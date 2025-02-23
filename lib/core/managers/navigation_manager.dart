import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../plugins/main_plugin/screens/home_screen.dart';

/// ✅ Holds route data, including optional drawer details
class RegisteredRoute {
  final String path;
  final Widget Function(BuildContext) screen;
  final String? drawerTitle;
  final IconData? drawerIcon;

  RegisteredRoute({
    required this.path,
    required this.screen,
    this.drawerTitle,
    this.drawerIcon,
  });

  GoRoute toGoRoute() {
    return GoRoute(
      path: path,
      builder: (context, state) => screen(context),
    );
  }
}

class NavigationManager extends ChangeNotifier {
  static final NavigationManager _instance = NavigationManager._internal();
  factory NavigationManager() => _instance;
  NavigationManager._internal();

  final List<RegisteredRoute> _routes = [];

  /// ✅ Getter for dynamically registered routes
  List<GoRoute> get routes => _routes.map((r) => r.toGoRoute()).toList();

  /// ✅ Getter for routes that should be in the drawer
  List<RegisteredRoute> get drawerRoutes =>
      _routes.where((r) => r.drawerTitle != null && r.drawerIcon != null).toList();

  /// ✅ Register a new route dynamically
  void registerRoute({
    required String path,
    required Widget Function(BuildContext) screen,
    String? drawerTitle,
    IconData? drawerIcon,
  }) {
    if (_routes.any((r) => r.path == path)) return; // Prevent duplicates

    _routes.add(RegisteredRoute(
      path: path,
      screen: screen,
      drawerTitle: drawerTitle,
      drawerIcon: drawerIcon,
    ));

    notifyListeners();
  }

  /// ✅ Create a dynamic GoRouter instance
  GoRouter get router {
    return GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
        ...routes, // ✅ Include dynamically registered plugin routes
      ],
    );
  }
}

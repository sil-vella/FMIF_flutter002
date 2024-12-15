import 'package:flutter/material.dart';

typedef NavigationLink = ListTile;
typedef BottomNavigationLink = BottomNavigationBarItem;

class NavigationContainer extends ChangeNotifier {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  final Map<String, List<NavigationLink>> _pluginDrawerLinks = {};
  final Map<String, List<BottomNavigationLink>> _pluginBottomNavLinks = {};
  final Map<String, Map<String, WidgetBuilder>> _pluginRoutes = {};
  final Map<String, List<Widget>> _pluginAppBarActions = {}; // Store AppBar actions per plugin

  List<NavigationLink> get drawerLinks => _pluginDrawerLinks.values.expand((e) => e).toList();
  List<BottomNavigationLink> get bottomNavLinks => _pluginBottomNavLinks.values.expand((e) => e).toList();
  Map<String, WidgetBuilder> get routes => _pluginRoutes.values.fold({}, (acc, e) => acc..addAll(e));
  List<Widget> get appBarActions => _pluginAppBarActions.values.expand((e) => e).toList(); // Expose AppBar actions

  /// Method for plugins to register navigation links and routes
  void registerNavigationLinks({
    required String pluginKey,
    required List<NavigationLink> drawerLinks,
    required List<BottomNavigationLink> bottomNavLinks,
    required Map<String, WidgetBuilder> routes,
  }) {
    _pluginDrawerLinks[pluginKey] = drawerLinks;
    _pluginBottomNavLinks[pluginKey] = bottomNavLinks;
    _pluginRoutes[pluginKey] = routes;
    notifyListeners(); // Notify listeners after updating navigation links
  }

  /// Method for plugins to register AppBar actions
  void registerAppBarItems(String pluginKey, List<Widget> actions) {
    _pluginAppBarActions[pluginKey] = actions;
    notifyListeners(); // Notify listeners about the update
  }

  /// Method to deregister navigation links and routes dynamically for a specific plugin
  void deregisterPlugin(String pluginKey) {
    _pluginDrawerLinks.remove(pluginKey);
    _pluginBottomNavLinks.remove(pluginKey);
    _pluginRoutes.remove(pluginKey);
    _pluginAppBarActions.remove(pluginKey);
    notifyListeners(); // Notify listeners after removing links and routes for the plugin
  }

  @override
  void notifyListeners() {
    super.notifyListeners();
  }

  /// Static method to navigate to a route
  static void navigateTo(String routeName) {
    navigatorKey.currentState?.pushNamed(routeName);
  }

  /// Builds the Drawer widget with registered links
  Widget buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            child: Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ...drawerLinks,
        ],
      ),
    );
  }

  /// Builds the BottomNavigationBar widget with registered links
  Widget? buildBottomNavigationBar() {
    if (bottomNavLinks.isEmpty) return null;

    return BottomNavigationBar(
      items: bottomNavLinks.take(4).toList(),
      onTap: (index) {
        if (index < routes.length) {
          final selectedRoute = routes.keys.elementAt(index);
          navigateTo(selectedRoute);
        }
      },
    );
  }

  /// Custom route generator to handle dynamically registered routes
  Route<dynamic>? generateRoute(RouteSettings settings) {
    final routeBuilder = routes[settings.name];
    if (routeBuilder != null) {
      return MaterialPageRoute(
        builder: (context) => routeBuilder(context),
        settings: settings,
      );
    }
    // Return null if the route is not found; Flutter will handle unknown routes
    return null;
  }
}

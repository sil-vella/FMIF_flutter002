import 'package:flutter/material.dart';

typedef NavigationLink = ListTile;
typedef BottomNavigationLink = BottomNavigationBarItem;

class NavigationContainer extends ChangeNotifier {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  final List<NavigationLink> _drawerLinks = [];
  final List<BottomNavigationLink> _bottomNavLinks = [];
  final Map<String, WidgetBuilder> _routes = {};
  final List<Widget> _appBarActions = []; // Store AppBar actions

  List<NavigationLink> get drawerLinks => _drawerLinks;
  List<BottomNavigationLink> get bottomNavLinks => _bottomNavLinks;
  Map<String, WidgetBuilder> get routes => _routes;
  List<Widget> get appBarActions => _appBarActions; // Expose AppBar actions

  /// Method for plugins to register navigation links and routes
  void registerNavigationLinks({
    required List<NavigationLink> drawerLinks,
    required List<BottomNavigationLink> bottomNavLinks,
    required Map<String, WidgetBuilder> routes,
  }) {
    _drawerLinks.addAll(drawerLinks);
    _bottomNavLinks.addAll(bottomNavLinks);
    _routes.addAll(routes);
    notifyListeners(); // Notify listeners after updating navigation links
  }

  /// Method for plugins to register AppBar actions
  void registerAppBarItems(List<Widget> actions) {
    _appBarActions.addAll(actions);
    notifyListeners(); // Notify listeners about the update
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
    if (_bottomNavLinks.isEmpty) return null;

    return BottomNavigationBar(
      items: _bottomNavLinks.take(4).toList(),
      onTap: (index) {
        if (index < _routes.length) {
          final selectedRoute = _routes.keys.elementAt(index);
          navigateTo(selectedRoute);
        }
      },
    );
  }

  /// Custom route generator to handle dynamically registered routes
  Route<dynamic>? generateRoute(RouteSettings settings) {
    final routeBuilder = _routes[settings.name];
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

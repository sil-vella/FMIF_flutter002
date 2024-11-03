// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_state_provider.dart';
import 'navigation/navigation_container.dart';
import 'plugins/00_base/plugin_manager.dart';
import 'plugins/00_base/plugin_registry.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Register all plugins before starting the app
  registerPlugins();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppStateProvider()),
        ChangeNotifierProvider(create: (context) => NavigationContainer()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Access NavigationContainer from the Provider
    final navigationContainer = Provider.of<NavigationContainer>(context, listen: false);

    // Initialize plugins after the first frame to ensure BuildContext is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PluginManager().initializeAllPlugins(context);
    });

    return MaterialApp(
      title: 'My App',
      navigatorKey: NavigationContainer.navigatorKey,
      home: const HomeScreen(), // Start with HomeScreen, which uses BaseScreen
      onGenerateRoute: navigationContainer.generateRoute, // Use custom route generator
    );
  }
}

// main.dart
import 'package:flush_me_im_famous/utils/consts/theme_consts.dart';

import 'services/shared_preferences_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/providers/app_state_provider.dart';
import 'navigation/navigation_container.dart';
import 'plugins/00_base/plugin_manager.dart';
import 'plugins/00_base/plugin_registry.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Log app start
  debugPrint('App starting: Initializing SharedPreferencesService...');

  // Initialize SharedPreferencesService
  await SharedPreferencesService().init();
  debugPrint('SharedPreferencesService initialized.');

  // Register all plugins before starting the app
  debugPrint('Registering plugins...');
  registerPlugins();
  debugPrint('Plugins registered.');

  // Run the onStartup hook for all registered plugins
  debugPrint('Running onStartup hooks for plugins...');
  PluginManager().runOnStartup();
  debugPrint('onStartup hooks completed.');

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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    debugPrint('MyApp initialized.');

    // Add the observer to track lifecycle changes
    WidgetsBinding.instance.addObserver(this);
    debugPrint('Lifecycle observer added.');

    // Initialize plugins after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('Initializing all plugins after first frame...');
      PluginManager().initializeAllPlugins(context);
      debugPrint('All plugins initialized.');
    });
  }

  @override
  void dispose() {
    debugPrint('MyApp disposed: Cleaning up resources.');

    // Remove the observer when the app is disposed
    WidgetsBinding.instance.removeObserver(this);
    debugPrint('Lifecycle observer removed.');

    // Call disposePlugins when the app is disposed
    debugPrint('Disposing all plugins...');
    PluginManager().disposeAllPlugins(context);
    debugPrint('All plugins disposed.');

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint('AppLifecycleState changed: $state');
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.inactive) {
      debugPrint('App is inactive. Disposing plugins...');
      PluginManager().disposeAllPlugins(context);
      debugPrint('Plugins disposed due to inactivity.');
    } else if (state == AppLifecycleState.resumed) {
      debugPrint('App is resumed. You can add logic to reinitialize plugins if needed.');
    } else if (state == AppLifecycleState.paused) {
      debugPrint('App is paused. Resources can be freed here if necessary.');
    } else if (state == AppLifecycleState.detached) {
      debugPrint('App is detached. This is the final cleanup state.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final navigationContainer = Provider.of<NavigationContainer>(context, listen: false);

    debugPrint('Building MaterialApp...');

    return MaterialApp(
      title: 'FMIF',
      navigatorKey: NavigationContainer.navigatorKey,
      theme: AppTheme.darkTheme, // Apply the custom theme here
      home: const HomeScreen(),
      onGenerateRoute: navigationContainer.generateRoute,
    );
  }
}

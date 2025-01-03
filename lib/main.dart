import 'dart:math';
import 'dart:developer' as dev;

import 'package:flush_me_im_famous/plugins/00_base/module_manager.dart';
import 'package:flush_me_im_famous/plugins/main_plugin/functions/animation_helper.dart';
import 'package:flush_me_im_famous/plugins/main_plugin/modules/audio_module/audio_module.dart';
import 'package:flush_me_im_famous/services/shared_preferences_service.dart';
import 'package:flush_me_im_famous/utils/consts/theme_consts.dart';
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
  await PluginManager().runOnStartup();
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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      debugPrint('Initializing all plugins after first frame...');
      await appInitialization();
      debugPrint('App initialization complete.');
    });
  }

  Future<void> appInitialization() async {
    debugPrint('App Initialization: Starting SharedPreferencesService initialization...');
    await SharedPreferencesService().init();
    debugPrint('SharedPreferencesService initialized.');

    debugPrint('Registering plugins...');
    registerPlugins();
    debugPrint('Plugins registered.');

    debugPrint('Running onStartup hooks...');
    await PluginManager().runOnStartup();
    debugPrint('onStartup hooks completed.');

    debugPrint('Initializing all plugins...');
    await PluginManager().initializeAllPlugins(context);

    // Retrieve the AudioHelper function and apply the saved mute state
    final audioHelperFactory = ModuleManager().getFunction<Function>("AudioHelper");
    if (audioHelperFactory != null) {
      final audioHelper = audioHelperFactory.call() as AudioHelper;
      await audioHelper.applySavedMuteState(context);
    } else {
      debugPrint('Error: AudioHelper function is not registered.');
    }
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
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);

    final appStateProvider = Provider.of<AppStateProvider>(context, listen: false);
    debugPrint('AppLifecycleState changed to: $state');

    // Retrieve the AudioHelper function for lifecycle-related audio handling
    final audioHelperFactory = ModuleManager().getFunction<Function>("AudioHelper");
    final audioHelper = audioHelperFactory?.call() as AudioHelper?;

    if (state == AppLifecycleState.inactive) {
      appStateProvider.updateMainAppState('main_state', 'inactive');
      try {
        await audioHelper?.stopAll();
        await audioHelper?.dispose();
        AnimationHelper.stopAllAnimations();
        AnimationHelper.disposeAllControllers();
      } catch (e) {
        debugPrint('Error during stopAll sounds: $e');
      }
    } else if (state == AppLifecycleState.paused) {
      final isAdShowing = context.read<AppStateProvider>().getPluginState<Map<String, dynamic>>("AdmobsPluginState")?['interstitial01']?['isShowing'] ?? false;

      if (!isAdShowing) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          NavigationContainer.navigatorKey.currentState?.pushNamed('/');
        });

        try {
          await audioHelper?.stopAll();
          await audioHelper?.dispose();
          AnimationHelper.stopAllAnimations();
          AnimationHelper.disposeAllControllers();
          PluginManager().disposeAllPlugins(context);
        } catch (e) {
          debugPrint('Error during pause cleanup: $e');
        }
      } else {
        await audioHelper?.stopAll();
        await audioHelper?.dispose();
      }
    } else if (state == AppLifecycleState.resumed) {
      final appState = context.read<AppStateProvider>().getMainAppState('main_state');
      if (appState != 'inactive') {
        debugPrint('App state is not inactive. Reinitializing app state...');
        try {
          await appInitialization();
          debugPrint('App reinitialized successfully.');
        } catch (e) {
          debugPrint('Error during app reinitialization: $e');
        }
      } else {
        appStateProvider.updateMainAppState('main_state', 'in_play');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final navigationContainer = Provider.of<NavigationContainer>(context, listen: false);

    return MaterialApp(
      title: 'FMIF',
      navigatorKey: NavigationContainer.navigatorKey,
      theme: AppTheme.darkTheme, // Apply the custom theme here
      home: const HomeScreen(),
      onGenerateRoute: navigationContainer.generateRoute,
    );
  }
}

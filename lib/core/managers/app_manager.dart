import 'package:flush_me_im_famous/core/managers/plugin_manager.dart';
import 'package:flutter/material.dart';
import '../../plugins/plugin_registry.dart';
import '../../tools/logging/logger.dart'; // ✅ Import Logger
import '../services/shared_preferences.dart';
import 'hooks_manager.dart';
import 'module_manager.dart';
import 'navigation_manager.dart';
import 'services_manager.dart';
import 'state_manager.dart'; // ✅ Import StateManager

class AppManager extends ChangeNotifier {
  static final Logger _log = Logger(); // ✅ Use a static logger for static methods

  static final AppManager _instance = AppManager._internal();

  static late BuildContext globalContext;

  final NavigationContainer navigationContainer;
  final PluginManager pluginManager;
  final ModuleManager moduleManager;
  final HooksManager hooksManager;
  final ServicesManager servicesManager;
  final StateManager stateManager;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  factory AppManager() {
    if (!_instance._isInitialized) {
      _instance._initializePlugins();
    }
    return _instance;
  }

  AppManager._internal()
      : navigationContainer = NavigationContainer(),
        hooksManager = HooksManager(),
        stateManager = StateManager(), // ✅ Initialize StateManager first
        pluginManager = PluginManager(HooksManager(), StateManager()), // ✅ Pass StateManager
        moduleManager = ModuleManager(),
        servicesManager = ServicesManager() {
    servicesManager.autoRegisterAllServices();
  }

  /// Trigger hooks dynamically
  void triggerHook(String hookName) {
    hooksManager.triggerHook(hookName);
  }

  /// Initializes plugins and services
  Future<void> _initializePlugins() async {
    _log.info('Initializing plugins...');

    final plugins = PluginRegistry.getPlugins(pluginManager, navigationContainer, stateManager);

    for (var entry in plugins.entries) {
      final pluginKey = entry.key;
      final plugin = entry.value;

      _log.info('Registering plugin: $pluginKey');
      pluginManager.registerPlugin(pluginKey, plugin);

      // ✅ Let PluginBase handle module registration
      plugin.registerModules();
    }

    hooksManager.triggerHook('app_startup');
    hooksManager.triggerHook('reg_nav');

    _isInitialized = true;
    notifyListeners();
    _log.info('Plugins initialized successfully.');
  }


  /// Cleans up app resources
  void _disposeApp() {
    _log.info('Disposing app resources...'); // ✅ Use local reference

    moduleManager.dispose();
    pluginManager.dispose();
    servicesManager.dispose();

    notifyListeners();
    _log.info('App resources disposed successfully.'); // ✅ Use local reference
  }
}

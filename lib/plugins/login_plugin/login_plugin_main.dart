import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state_provider.dart';
import '../../utils/consts/config.dart';
import '../00_base/module_manager.dart';
import '../api/modules/connection_module.dart';
import 'functions/login_plugin_helper.dart';
import '../00_base/app_plugin.dart';
import 'modules/login/login_module.dart';
import 'modules/register/register_module.dart';

class LoginPlugin implements AppPlugin {
  LoginPlugin._internal();

  static final LoginPlugin _instance = LoginPlugin._internal();

  factory LoginPlugin() => _instance;

  @override
  void onStartup() {
    // Add any non-context-dependent startup logic here
  }

  @override
  void initialize(BuildContext context) async {

    // Register modules
    registerModules();

    // Register navigation
    PluginHelper.registerNavigation(context);

    // Access and initialize app state
    final pluginStateKey = "${runtimeType}State";
    final appStateProvider = Provider.of<AppStateProvider>(context, listen: false);
    appStateProvider.updatePluginState(pluginStateKey, reset());

  }

  void registerModules() {
    // Register the shared ConnectionModule as an instance
    final connectionModule = ConnectionModule(Config.apiUrl);

    // Register factory functions for LoginModule and RegisterModule
    ModuleManager().registerFunction(
      "LoginModule",
          () => LoginModule(connectionModule: connectionModule), // Factory function that creates a new LoginModule
    );

    ModuleManager().registerFunction(
      "RegisterModule",
          () => RegisterModule(connectionModule: connectionModule), // Factory function that creates a new RegisterModule
    );
  }




  // Default state
  Map<String, dynamic> reset() {
    return {
      "logged": false,
    };
  }
}

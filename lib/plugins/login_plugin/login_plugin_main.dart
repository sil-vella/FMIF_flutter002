import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/providers/app_state_provider.dart';
import '../../utils/consts/config.dart';
import '../00_base/module_manager.dart';
import '../api/modules/connection_module.dart';
import 'functions/login_plugin_helper.dart';
import '../00_base/app_plugin.dart';
import 'modules/UpdateUser/update_user.dart';
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
    const pluginKey = "LoginPluginState";
    final appStateProvider = Provider.of<AppStateProvider>(context, listen: false);
    appStateProvider.registerPluginState(pluginKey, reset());

  }

  void registerModules() {
    // Register the shared ConnectionModule as an instance
    final connectionModule = ConnectionModule(Config.apiUrl);

    // Register factory functions for LoginModule and RegisterModule
    ModuleManager().registerFunction(
      "LoginModule",
          () => LoginModule(connectionModule: connectionModule), // Factory function that creates a new LoginModule
    );
    // Register the updateGuessed function dynamically in ModuleManager
    ModuleManager().registerFunction(
      "LoginModule.getUserDetails",
          ({required String username}) =>
          LoginModule(connectionModule: connectionModule).getUserDetails(
            username: username,
          ),
    );

    ModuleManager().registerFunction(
      "RegisterModule",
          () => RegisterModule(connectionModule: connectionModule), // Factory function that creates a new RegisterModule
    );

    // Register UserUpdateModule as a function (factory function)
    ModuleManager().registerFunction(
      "UserUpdateModule",
          () => UserUpdateModule(connectionModule: connectionModule),  // Factory function for UserUpdateModule
    );

    // Register the updatePoints function dynamically in ModuleManager
    ModuleManager().registerFunction(
      "UserUpdateModule.updatePoints",
          ({required String username, required int points, required BuildContext context}) =>
          UserUpdateModule(connectionModule: connectionModule).updatePoints(
            username: username,
            points: points,
            context: context,
          ),
    );

    // Register the updateGuessed function dynamically in ModuleManager
    ModuleManager().registerFunction(
      "UserUpdateModule.updateGuessed",
          ({required String username, required String guessedName, required String guessedCategory, required BuildContext context}) =>
          UserUpdateModule(connectionModule: connectionModule).updateGuessed(
            username: username,
            guessedName: guessedName,
            guessedCategory: guessedCategory,
            context: context,
          ),
    );

  }

  // Default state
  Map<String, dynamic> reset() {
    return {
      "logged": false,
    };
  }

  @override
  void dispose() {
    // Clean up resources related to this plugin
    ModuleManager().unregisterFunction("LoginModule");
    ModuleManager().unregisterFunction("LoginModule.getUserDetails");
    ModuleManager().unregisterFunction("RegisterModule");
    ModuleManager().unregisterFunction("UserUpdateModule");
    ModuleManager().unregisterFunction("UserUpdateModule.updatePoints");
    ModuleManager().unregisterFunction("UserUpdateModule.updateGuessed");
  }
}

// plugins/base/app_plugins_base.dart
import 'package:flush_me_im_famous/plugins/00_base/plugin_manager.dart';
import 'package:flutter/material.dart';

// Updated dispose method in AppPlugin
abstract class AppPlugin {
  void onStartup();
  Future<void> initialize(BuildContext context);
  void dispose() {
    // Plugin-specific cleanup
    print('Disposing ${runtimeType} resources');
    // Deregister itself from PluginManager
    PluginManager().deregisterPlugin(this);
  }
}

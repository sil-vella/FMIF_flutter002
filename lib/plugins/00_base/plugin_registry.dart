// plugins/plugin_registry.dart
import 'package:flush_me_im_famous/plugins/login_plugin/login_plugin_main.dart';

import '../main_plugin/main_plugin_main.dart';

import '../admobs/admobs_main.dart';
import '../api/api.dart';
import 'plugin_manager.dart';

void registerPlugins() {

  PluginManager().registerPlugin(Api());
  PluginManager().registerPlugin(AdmobsPlugin());

  PluginManager().registerPlugin(MainPlugin());
  PluginManager().registerPlugin(LoginPlugin());

}
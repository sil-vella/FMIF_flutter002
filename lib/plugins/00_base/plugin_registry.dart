// plugins/plugin_registry.dart
import '../admobs/admobs_main.dart';
import '../example_plugin/example_plugin_main.dart';
import '../api/api.dart';
import 'plugin_manager.dart';

void registerPlugins() {
  PluginManager().registerPlugin(PluginExample());
  PluginManager().registerPlugin(Api());
  PluginManager().registerPlugin(AdmobsPlugin());

}
import '../managers/module_manager.dart';
import '../managers/hooks_manager.dart';
import '../managers/state_manager.dart';
import '../../tools/logging/logger.dart';
import '../00_base/module_base.dart';

abstract class PluginBase {
  final HooksManager hooksManager;
  final ModuleManager moduleManager;
  final Logger log = Logger();

  /// Map for hooks
  final Map<String, HookCallback> hookMap = {};

  /// Stores instance keys for modules registered by this plugin
  final List<String> registeredModuleKeys = [];

  PluginBase(this.hooksManager, this.moduleManager);

  /// Initialize the plugin (registers modules, hooks, and states)
  void initialize(StateManager stateManager) {
    registerModules();
    registerHooks();
    registerStates(stateManager); // ✅ Register states
  }

  /// Register hooks dynamically from the hookMap
  void registerHooks() {
    hookMap.forEach((hookName, callback) {
      hooksManager.registerHook(hookName, callback);
    });
  }

  /// ✅ Register modules with hardcoded or dynamic instance keys
  void registerModules() {
    final modules = createModules();
    for (var entry in modules.entries) {
      final module = entry.value;
      final instanceKey = entry.key ?? "${module.moduleKey}_${DateTime.now().millisecondsSinceEpoch}";

      registeredModuleKeys.add(instanceKey);
      moduleManager.registerModule(module, instanceKey: instanceKey);
      log.info('✅ Plugin registered module: ${module.moduleKey} with instance key: $instanceKey');
    }
  }

  /// ✅ Plugins must override this method to define their modules
  /// Returns a `Map<String?, ModuleBase>` where:
  /// - The key is the instance key (null = auto-generate)
  /// - The value is the module instance
  Map<String?, ModuleBase> createModules();

  /// ✅ Each plugin must override this to define its states
  Map<String, Map<String, dynamic>> getInitialStates();

  /// ✅ Registers the plugin states using StateManager
  void registerStates(StateManager stateManager) {
    for (var entry in getInitialStates().entries) {
      final stateKey = entry.key;
      final stateData = entry.value;

      if (!stateManager.isPluginStateRegistered(stateKey)) {
        stateManager.registerPluginState(stateKey, stateData);
        log.info("✅ Registered plugin state: $stateKey");
      }
    }
  }

  /// Dispose the plugin (removes modules and hooks)
  void dispose() {
    // ✅ Remove all module instances registered by this plugin
    for (var instanceKey in registeredModuleKeys) {
      moduleManager.deregisterModule(instanceKey);
      log.info('🗑 Plugin deregistered module instance: $instanceKey');
    }
    registeredModuleKeys.clear(); // ✅ Ensure the list is emptied

    // ✅ Remove hooks
    hookMap.keys.forEach(hooksManager.deregisterHook);
  }
}

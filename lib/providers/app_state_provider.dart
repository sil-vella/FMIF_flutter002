// providers/app_state_provider.dart
import 'package:flutter/material.dart';

class AppStateProvider with ChangeNotifier {
  // Map to hold state for each plugin by name
  final Map<String, dynamic> _pluginStates = {};

  // State for the main app
  Map<String, dynamic> _mainAppState = {'main_state': 'idle'};

  /// Register a new plugin state with a unique key
  void registerPluginState(String pluginKey, dynamic initialState) {
    if (!_pluginStates.containsKey(pluginKey)) {
      _pluginStates[pluginKey] = initialState;
      notifyListeners();
    } else {
      print("Plugin state for $pluginKey is already registered.");
    }
  }

  /// Retrieve state for a specific plugin
  T? getPluginState<T>(String pluginKey) {
    return _pluginStates[pluginKey] as T?;
  }

  /// Update state for a specific plugin
  void updatePluginState(String pluginKey, dynamic newState) {
    if (_pluginStates.containsKey(pluginKey)) {
      _pluginStates[pluginKey] = newState;
      notifyListeners();
    } else {
      print("No state registered for plugin: $pluginKey");
    }
  }

  // ------ Main App State Methods ------

  /// Set initial main app state with a default main_state of 'idle'
  void setMainAppState(Map<String, dynamic> initialState) {
    _mainAppState = {'main_state': 'idle', ...initialState};
    notifyListeners();
  }

  /// Retrieve main app state
  Map<String, dynamic> get mainAppState => _mainAppState;

  /// Update a specific property in the main app state
  void updateMainAppState(String key, dynamic value) {
    _mainAppState[key] = value;
    notifyListeners();
  }
}

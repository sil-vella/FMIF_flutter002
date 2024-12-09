import 'package:flutter/material.dart';

class AppStateProvider with ChangeNotifier {
  final Map<String, dynamic> _pluginStates = {}; // Stores states for plugins
  Map<String, dynamic> _mainAppState = {'main_state': 'idle'}; // Default main app state

  // ------ Plugin State Methods ------
  /// Check if a plugin state is registered
  bool isPluginStateRegistered(String pluginKey) {
    return _pluginStates.containsKey(pluginKey);
  }

  /// Register a plugin state dynamically
  void registerPluginState(String pluginKey, dynamic initialState) {
    if (!_pluginStates.containsKey(pluginKey)) {
      _pluginStates[pluginKey] = initialState;
      print("Registered state for key: $pluginKey"); // Debug log
      notifyListeners();
    }
  }

  /// Retrieve a plugin state dynamically
  T? getPluginState<T>(String pluginKey) {
    final pluginState = _pluginStates[pluginKey];
    print("Retrieved state for key: $pluginKey: $pluginState"); // Debug log
    if (pluginState is Map && T == Map<String, dynamic>) {
      return Map<String, dynamic>.from(pluginState) as T;
    }
    return pluginState as T?;
  }

  /// Update a plugin state dynamically
  Future<void> updatePluginState(String pluginKey, Map<String, dynamic> newState) async {
    if (_pluginStates.containsKey(pluginKey)) {
      print("Existing state for $pluginKey: ${_pluginStates[pluginKey]}");
      _pluginStates[pluginKey] = {
        ..._pluginStates[pluginKey],
        ...newState,
      };
      print("Updated state for $pluginKey: ${_pluginStates[pluginKey]}");
    } else {
      print("No existing state for $pluginKey. Creating new state.");
      _pluginStates[pluginKey] = newState; // Create new state
      print("Created new state for $pluginKey: ${_pluginStates[pluginKey]}");
    }
    notifyListeners();
  }



  // ------ Main App State Methods ------

  /// Set the initial main app state
  void setMainAppState(Map<String, dynamic> initialState) {
    _mainAppState = {'main_state': 'idle', ...initialState};
    print("Main app state initialized: $_mainAppState"); // Debug log
    notifyListeners();
  }

  /// Get the main app state as a whole
  Map<String, dynamic> get mainAppState => _mainAppState;

  /// Update a specific key-value pair in the main app state
  void updateMainAppState(String key, dynamic value) {
    _mainAppState[key] = value;
    print("Main app state updated: key=$key, value=$value"); // Debug log
    notifyListeners();
  }

  /// Retrieve a specific value from the main app state
  T? getMainAppState<T>(String key) {
    final value = _mainAppState[key] as T?;
    print("Retrieved main app state value for key=$key: $value"); // Debug log
    return value;
  }
}

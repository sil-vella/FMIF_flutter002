// providers/app_state_provider.dart
import 'package:flutter/material.dart';

class AppStateProvider with ChangeNotifier {
  final Map<String, dynamic> _pluginStates = {};
  Map<String, dynamic> _mainAppState = {'main_state': 'idle'};

  bool isPluginStateRegistered(String pluginKey) {
    return _pluginStates.containsKey(pluginKey);
  }

  void registerPluginState(String pluginKey, dynamic initialState) {
    if (!_pluginStates.containsKey(pluginKey)) {
      _pluginStates[pluginKey] = initialState;
      notifyListeners();
    }
  }

  T? getPluginState<T>(String pluginKey) {
    final pluginState = _pluginStates[pluginKey];
    if (pluginState is Map && T == Map<String, dynamic>) {
      return Map<String, dynamic>.from(pluginState) as T;
    }
    return pluginState as T?;
  }

  // Updated to return Future<void> for async compatibility
  Future<void> updatePluginState(String pluginKey, Map<String, dynamic> newState) async {
    if (_pluginStates.containsKey(pluginKey)) {
      _pluginStates[pluginKey] = {
        ..._pluginStates[pluginKey],
        ...newState,
      };
      notifyListeners();
    }
  }

  // ------ Main App State Methods ------
  void setMainAppState(Map<String, dynamic> initialState) {
    _mainAppState = {'main_state': 'idle', ...initialState};
    notifyListeners();
  }

  Map<String, dynamic> get mainAppState => _mainAppState;

  void updateMainAppState(String key, dynamic value) {
    _mainAppState[key] = value;
    notifyListeners();
  }

  // Method to retrieve a specific value from the main app state
  T? getMainAppState<T>(String key) {
    return _mainAppState[key] as T?;
  }
}

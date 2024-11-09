// providers/app_state_provider.dart
import 'package:flutter/material.dart';

class AppStateProvider with ChangeNotifier {
  final Map<String, dynamic> _pluginStates = {};
  Map<String, dynamic> _mainAppState = {'main_state': 'idle'};

  void registerPluginState(String pluginKey, dynamic initialState) {
    if (!_pluginStates.containsKey(pluginKey)) {
      _pluginStates[pluginKey] = initialState;
      notifyListeners();
    } else {
      print("Plugin state for $pluginKey is already registered.");
    }
  }

  T? getPluginState<T>(String pluginKey) {
    final pluginState = _pluginStates[pluginKey];
    if (pluginState is Map && T == Map<String, dynamic>) {
      return Map<String, dynamic>.from(pluginState) as T;
    }
    return pluginState as T?;
  }

  void updatePluginState(String pluginKey, Map<String, dynamic> newState) {
    if (_pluginStates.containsKey(pluginKey)) {
      _pluginStates[pluginKey] = {
        ..._pluginStates[pluginKey],
        ...newState,
      };
      notifyListeners();
    } else {
      print("No state registered for plugin: $pluginKey");
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
}

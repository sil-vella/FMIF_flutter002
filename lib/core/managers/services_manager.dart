import 'package:flutter/material.dart';
import '../../tools/logging/logger.dart';
import '../00_base/service_base.dart';
import '../services/shared_preferences.dart';

class ServicesManager extends ChangeNotifier {
  static final Logger _log = Logger();
  static final ServicesManager _instance = ServicesManager._internal();
  factory ServicesManager() => _instance;
  ServicesManager._internal();

  final Map<String, ServicesBase> _services = {};

  static final List<MapEntry<String, ServicesBase>> _allServices = [
    MapEntry('shared_pref', SharedPrefManager()),
  ];

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  Future<void> autoRegisterAllServices() async {
    if (_isInitialized) return;

    for (var entry in _allServices) {
      final serviceKey = entry.key;
      final service = entry.value;

      if (!_services.containsKey(serviceKey)) {
        _services[serviceKey] = service;
        await service.initialize(); // ✅ Ensure all services initialize asynchronously
        _log.info('✅ Service registered: $serviceKey');
      }
    }

    _isInitialized = true;
    notifyListeners(); // ✅ Notify UI after services initialize
  }

  /// ✅ Get service safely
  T? getService<T extends ServicesBase>() {
    for (var service in _services.values) {
      if (service is T) {
        return service;
      }
    }
    _log.error("❌ Service ${T.toString()} not found.");
    return null;
  }

  @override
  void dispose() {
    for (var service in _services.values) {
      service.dispose();
    }
    _services.clear();
    super.dispose();
  }
}

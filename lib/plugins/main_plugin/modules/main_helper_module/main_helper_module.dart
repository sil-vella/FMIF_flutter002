import 'dart:async';
import 'dart:math';
import 'package:provider/provider.dart';
import '../../../../core/00_base/module_base.dart';
import '../../../../core/managers/app_manager.dart';
import '../../../../core/managers/services_manager.dart';
import '../../../../core/managers/state_manager.dart';
import '../../../../tools/logging/logger.dart';
import '../../../../utils/consts/theme_consts.dart';

class MainHelperModule extends ModuleBase {
  static final Logger _log = Logger(); // ✅ Use a static logger for static methods
  final ServicesManager _servicesManager = ServicesManager();
  static final Random _random = Random();

  Timer? _timer;
  int _remainingTime = 0;
  bool _isPaused = false;

  /// ✅ Constructor with module key
  MainHelperModule() : super("main_helper_module") {
    _log.info('✅ MainHelperModule initialized.');
  }


  /// Retrieve background by index (looping if out of range)
  static String getBackground(int index) {
    if (AppBackgrounds.backgrounds.isEmpty) {
      _log.error('No backgrounds available.');
      return ''; // Return an empty string or a default background
    }
    return AppBackgrounds.backgrounds[index % AppBackgrounds.backgrounds.length];
  }

  /// Retrieve a random background
  static String getRandomBackground() {
    if (AppBackgrounds.backgrounds.isEmpty) {
      _log.error('No backgrounds available.');
      return ''; // Return an empty string or a default background
    }
    return AppBackgrounds.backgrounds[_random.nextInt(AppBackgrounds.backgrounds.length)];
  }

  /// Update user information in Shared Preferences
  Future<void> updateUserInfo(String key, dynamic value) async {
    final sharedPref = _servicesManager.getService('shared_pref');

    if (sharedPref != null) {
      try {
        if (value is String) {
          await sharedPref.callServiceMethod('setString', [key, value]);
        } else if (value is int) {
          await sharedPref.callServiceMethod('setInt', [key, value]);
        } else if (value is bool) {
          await sharedPref.callServiceMethod('setBool', [key, value]);
        } else if (value is double) {
          await sharedPref.callServiceMethod('setDouble', [key, value]);
        } else {
          _log.error('Unsupported value type for key: $key');
          return;
        }
        _log.info('Updated $key: $value');
      } catch (e) {
        _log.error('Error updating user info: $e');
      }
    } else {
      _log.error('SharedPrefManager not available.');
    }
  }

  /// Retrieve stored user information
  Future<dynamic> getUserInfo(String key) async {
    final sharedPref = _servicesManager.getService('shared_pref');

    if (sharedPref != null) {
      try {
        dynamic value;
        if (key == 'points') {
          value = await sharedPref.callServiceMethod('getInt', [key]);
        } else {
          value = await sharedPref.callServiceMethod('getString', [key]);
        }
        _log.info('Retrieved $key: $value');
        return value;
      } catch (e) {
        _log.error('Error retrieving user info: $e');
      }
    } else {
      _log.error('SharedPrefManager not available.');
    }
    return null;
  }

  /// ✅ Start a countdown timer with pause functionality
  void startTimer(int seconds, Function callback) {
    final stateManager = Provider.of<StateManager>(AppManager.globalContext, listen: false);

    _log.info("⏳ Timer started for $seconds seconds...");

    _remainingTime = seconds; // ✅ Initialize remaining time
    _isPaused = false;

    // ✅ Set initial state: timer is running
    stateManager.updatePluginState("game_timer", {
      "isRunning": true,
      "duration": _remainingTime,
    });

    _timer?.cancel(); // Cancel any existing timer before starting a new one
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_isPaused) {
        timer.cancel();
        return;
      }

      _remainingTime--;

      // ✅ Update state every second
      stateManager.updatePluginState("game_timer", {
        "isRunning": true,
        "duration": _remainingTime,
      });

      if (_remainingTime <= 0) {
        timer.cancel();
        _log.info("✅ Timer completed.");

        // ✅ Set final state: timer stopped
        stateManager.updatePluginState("game_timer", {
          "isRunning": false,
          "duration": 0,
        });

        callback(); // Execute callback function
      }
    });
  }

  /// ✅ Pause the timer
  void pauseTimer() {
    if (_timer != null && !_isPaused) {
      _isPaused = true;
      _timer?.cancel();
      _log.info("⏸ Timer paused at $_remainingTime seconds.");

      // ✅ Update state to reflect the pause
      final stateManager = Provider.of<StateManager>(AppManager.globalContext, listen: false);
      stateManager.updatePluginState("game_timer", {
        "isRunning": false,
        "duration": _remainingTime,
      });
    }
  }

  /// ✅ Resume the timer correctly
  void resumeTimer(Function callback) {
    if (_isPaused && _remainingTime > 0) {
      _isPaused = false;
      _log.info("▶ Timer resumed with $_remainingTime seconds left.");

      // ✅ Update state: Mark timer as running again
      final stateManager = Provider.of<StateManager>(AppManager.globalContext, listen: false);
      stateManager.updatePluginState("game_timer", {
        "isRunning": true,
        "duration": _remainingTime, // ✅ Ensure it continues from remaining time
      });

      // ✅ Restart the countdown
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (_isPaused) {
          timer.cancel();
          return;
        }

        _remainingTime--;

        // ✅ Update UI state
        stateManager.updatePluginState("game_timer", {
          "isRunning": true,
          "duration": _remainingTime,
        });

        if (_remainingTime <= 0) {
          timer.cancel();
          _log.info("✅ Timer completed.");

          // ✅ Mark timer as stopped
          stateManager.updatePluginState("game_timer", {
            "isRunning": false,
            "duration": 0,
          });

          callback(); // ✅ Execute callback function
        }
      });
    }
  }


  /// ✅ Stop and reset the timer
  void stopTimer() {
    _timer?.cancel();
    _remainingTime = 0;
    _isPaused = false;

    _log.info("⏹ Timer stopped.");

    // ✅ Update state to reflect the stop
    final stateManager = Provider.of<StateManager>(AppManager.globalContext, listen: false);
    stateManager.updatePluginState("game_timer", {
      "isRunning": false,
      "duration": 0,
    });
  }


}

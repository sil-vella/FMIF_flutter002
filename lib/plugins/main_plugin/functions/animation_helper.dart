import 'package:flutter/material.dart';
import 'main_plugin_helper.dart';

import 'package:flutter/material.dart';
import 'main_plugin_helper.dart';

class AnimationManager {
  // Store references to AnimationControllers by ID
  static final Map<String, AnimationController> _controllers = {};

  // Register an AnimationController with an ID
  static void registerController(String id, AnimationController controller) {
    _controllers[id] = controller;
  }

  // Remove a controller when no longer needed
  static void removeController(String id) {
    _controllers[id]?.dispose(); // Dispose of the controller when removing it
    _controllers.remove(id);
  }

  // Repeat an animation by ID with additional parameters
  static void repeatAnimation(
      String id, {
        bool reverse = false,
        Duration? duration,
        Curve curve = Curves.linear,
        bool infinite = true,
      }) {
    final controller = _controllers[id];
    if (controller != null) {
      // If a duration is specified, update the controller's duration
      if (duration != null) {
        controller.duration = duration;
      }

      // Reset the animation and apply the curve
      controller.reset();
      controller.forward();
      final animation = CurvedAnimation(parent: controller, curve: curve);

      // Control the repetition behavior
      if (infinite) {
        controller.repeat(reverse: reverse);
      } else {
        controller.forward();
      }
    }
  }

  // Reset an animation by ID
  static void resetAnimation(String id) {
    final controller = _controllers[id];
    if (controller != null) {
      controller.reset();
    }
  }

  // Stop an animation by ID
  static void stopAnimation(String id) {
    final controller = _controllers[id];
    if (controller != null) {
      controller.stop();
    }
  }
}

class AnimationHelper extends PluginHelper {
  // Initializes and returns an AnimationController
  static AnimationController initController({
    required TickerProvider vsync,
    required String id,
    Duration duration = const Duration(seconds: 1),
  }) {
    final controller = AnimationController(vsync: vsync, duration: duration);
    AnimationManager.registerController(id, controller);
    return controller;
  }

  // Bounce animation
  static Widget bounce(
      Widget child, {
        required AnimationController controller,
        double beginOffsetY = -0.01,
        double endOffsetY = 0.01,
        Duration? duration,
        Curve curve = Curves.easeInOut,
        bool infinite = true,
      }) {
    if (duration != null) controller.duration = duration;
    if (infinite) controller.repeat(reverse: true);
    final animation = Tween<Offset>(
      begin: Offset(0.0, beginOffsetY),
      end: Offset(0.0, endOffsetY),
    ).animate(CurvedAnimation(parent: controller, curve: curve));

    return SlideTransition(position: animation, child: child);
  }

  // Side-to-side animation
  static Widget sideToSide(
      Widget child, {
        required AnimationController controller,
        double beginOffsetX = -0.007,
        double endOffsetX = 0.007,
        Duration? duration,
        Curve curve = Curves.easeInOut,
        bool infinite = true,
      }) {
    if (duration != null) controller.duration = duration;
    if (infinite) controller.repeat(reverse: true);
    final animation = Tween<Offset>(
      begin: Offset(beginOffsetX, 0.0),
      end: Offset(endOffsetX, 0.0),
    ).animate(CurvedAnimation(parent: controller, curve: curve));

    return SlideTransition(position: animation, child: child);
  }

  // Pulse animation
  static Widget pulse(
      Widget child, {
        required AnimationController controller,
        double beginScale = 0.97,
        double endScale = 1.02,
        Duration? duration,
        Curve curve = Curves.easeInOut,
        bool infinite = true,
      }) {
    if (duration != null) controller.duration = duration;
    if (infinite) controller.repeat(reverse: true);
    final animation = Tween<double>(
      begin: beginScale,
      end: endScale,
    ).animate(CurvedAnimation(parent: controller, curve: curve));

    return ScaleTransition(scale: animation, child: child);
  }
}

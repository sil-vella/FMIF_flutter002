import 'dart:developer' as dev;
import 'dart:math';

import 'package:flutter/material.dart';
import 'login_plugin_helper.dart';

class AnimationHelper extends PluginHelper {
  void _resetController(AnimationController controller) {
    controller.stop();
    controller.reset();
  }

  Widget slideUp(
      Widget child, {
        required AnimationController controller,
        Duration duration = const Duration(seconds: 2),
        Curve curve = Curves.easeInOut,
        Offset begin = const Offset(0.0, 1.0),  // Start fully below the original position
        Offset end = const Offset(0.0, 0.0),    // End at the original position
        bool infinite = false,
        VoidCallback? onComplete,
      }) {
    _resetController(controller); // Stop and reset the controller
    controller.duration = duration;

    // Define the animation to slide up
    final animation = Tween<Offset>(begin: begin, end: end)
        .animate(CurvedAnimation(parent: controller, curve: curve));

    // Start the animation based on the infinite flag
    if (infinite) {
      controller.repeat();
    } else {
      controller.forward();
    }

    // Listen for animation completion
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && !infinite) {
        onComplete?.call();
      }
    });

    // Apply the SlideTransition to create the slide-up effect
    return SlideTransition(position: animation, child: child);
  }

}

import 'package:flutter/material.dart';

class AnimationHelper {
  // Initializes and returns an AnimationController
  static AnimationController initController({
    required TickerProvider vsync,
    Duration duration = const Duration(seconds: 1),
  }) {
    return AnimationController(
      vsync: vsync,
      duration: duration,
    );
  }

  // Bounce animation that moves the widget up and down infinitely
  static Widget bounce(
      Widget child, {
        required AnimationController controller,
        double beginOffsetY = -0.01,
        double endOffsetY = 0.01,
      }) {
    final animation = Tween<Offset>(
      begin: Offset(0.0, beginOffsetY),
      end: Offset(0.0, endOffsetY),
    ).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOut),
    );

    return SlideTransition(
      position: animation,
      child: child,
    );
  }

  // Side-to-side animation that moves the widget left and right infinitely
  static Widget sideToSide(
      Widget child, {
        required AnimationController controller,
        double beginOffsetX = -0.007,
        double endOffsetX = 0.007,
      }) {
    final animation = Tween<Offset>(
      begin: Offset(beginOffsetX, 0.0),
      end: Offset(endOffsetX, 0.0),
    ).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOut),
    );

    return SlideTransition(
      position: animation,
      child: child,
    );
  }

  // Pulse animation that increases and decreases the size of the widget infinitely
  static Widget pulse(
      Widget child, {
        required AnimationController controller,
        double beginScale = 0.97,
        double endScale = 1.02,
      }) {
    final animation = Tween<double>(
      begin: beginScale,
      end: endScale,
    ).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOut),
    );

    return ScaleTransition(
      scale: animation,
      child: child,
    );
  }
}

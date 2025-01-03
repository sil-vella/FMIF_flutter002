import 'dart:math';
import 'package:flutter/material.dart';
import 'main_plugin_helper.dart';

class CustomShakeCurve extends Curve {
  final double accelerationFactor; // Controls the acceleration phase
  final double decelerationFactor; // Controls the deceleration phase

  const CustomShakeCurve({
    this.accelerationFactor = 2.0, // Default values
    this.decelerationFactor = 2.0,
  });

  @override
  double transform(double t) {
    // Customizable quadratic ease-in-out logic
    return pow(t, accelerationFactor).toDouble() * (3 - pow(t, decelerationFactor).toDouble());
  }
}

class AnimationHelper extends PluginHelper {
  static final Map<AnimationController, bool> _controllerRegistry = {};

  /// Restart all registered animation controllers
  static Future<void> restartAllControllers() async {
    for (var controller in _controllerRegistry.keys) {
      if (!_controllerRegistry[controller]!) { // Ensure the controller is not disposed
        try {
          controller.reset(); // Reset the animation
          controller.forward(); // Start the animation
          debugPrint("Controller restarted: $controller");
        } catch (e) {
          debugPrint("Failed to restart controller (possibly disposed): $e");
        }
      } else {
        debugPrint("Controller is already disposed and cannot be restarted: $controller");
      }
    }
  }


  /// Register a controller, ensuring no duplicates
  static void registerController(AnimationController controller) {
    if (!_controllerRegistry.containsKey(controller)) {
      _controllerRegistry[controller] = false; // Not yet disposed
      debugPrint("Controller registered: $controller");
    }
  }

  /// Dispose a controller if it hasn't been disposed
  static void disposeController(AnimationController controller) {
    if (_controllerRegistry.containsKey(controller) && !_controllerRegistry[controller]!) {
      controller.dispose();
      _controllerRegistry[controller] = true; // Mark as disposed
      debugPrint("Controller disposed: $controller");
    } else {
      debugPrint("Attempted to dispose a controller that is already disposed or not registered: $controller");
    }
  }

  /// Dispose all registered controllers
  static void disposeAllControllers() {
    _controllerRegistry.forEach((controller, isDisposed) {
      if (!isDisposed) {
        controller.dispose();
        debugPrint("Controller disposed: $controller");
      }
    });
    _controllerRegistry.clear();
    debugPrint("All controllers disposed.");
  }

  /// Check if a controller is disposed
  static bool isDisposed(AnimationController controller) {
    return _controllerRegistry[controller] ?? true; // Default to true if not found
  }

  /// Stop all animations for registered controllers
  static void stopAllAnimations() {
    for (var controller in _controllerRegistry.keys) {
      if (controller.isAnimating) {
        controller.stop();
        debugPrint("Controller stopped: $controller");
      }
    }
  }

  /// Clear registry after all controllers are disposed
  static void clearRegistry() {
    _controllerRegistry.clear();
    debugPrint("Controller registry cleared.");
  }

  void _resetController(AnimationController controller) {
    try {
      controller.stop();
      controller.reset();
      debugPrint("Controller reset: $controller");
    } catch (e) {
      debugPrint("Failed to reset controller (possibly disposed): $e");
    }
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

  Widget flyAway(
      Widget child, {
        required AnimationController controller,
        Duration slideUpDuration = const Duration(seconds: 2),
        Duration pauseDuration = const Duration(seconds: 2),
        Duration flyAwayDuration = const Duration(seconds: 4),
        Offset begin = const Offset(0.0, 1.0),       // Start below the original position
        Offset middle = const Offset(0.0, 0.0),      // Center/original position
        Offset end = const Offset(0.0, -6.0),        // Move offscreen upwards
        Curve initialSlideCurve = Curves.easeOutCubic,   // Gentle start to center
        Curve flyAwayCurve = Curves.easeInCubic,         // Exponential lift-off
        bool infinite = false,
        VoidCallback? onComplete,
      }) {
    _resetController(controller);
    controller.duration = slideUpDuration + pauseDuration + flyAwayDuration;

    // Register controller globally
    registerController(controller);

    // Define the animation sequence with individual weights for each phase
    final animation = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween<Offset>(begin: begin, end: middle).chain(CurveTween(curve: initialSlideCurve)),
        weight: slideUpDuration.inMilliseconds.toDouble(), // Weight for slide-up
      ),
      TweenSequenceItem(
        tween: ConstantTween<Offset>(middle), // Pause at the original position
        weight: pauseDuration.inMilliseconds.toDouble(), // Weight for pause
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(begin: middle, end: end).chain(CurveTween(curve: flyAwayCurve)),
        weight: flyAwayDuration.inMilliseconds.toDouble(), // Weight for fly-away
      ),
    ]).animate(controller);

    // Start the animation based on the infinite flag
    if (infinite) {
      controller.repeat();
    } else {
      controller.forward();
    }

    // Trigger onComplete callback after animation ends if not infinite
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && !infinite) {
        onComplete?.call();
      }
    });

    return SlideTransition(position: animation, child: child);
  }

  Widget bounce(
      Widget child, {
        required AnimationController controller,
        Duration duration = const Duration(seconds: 3),
        Curve curve = Curves.easeInOut,
        Offset begin = const Offset(0.0, -0.09),
        Offset end = const Offset(0.0, 0.09),
        bool reverse = true,
        bool infinite = true,
        VoidCallback? onComplete,
      }) {
    _resetController(controller); // Stop and reset the controller
    controller.duration = duration;

    // Register controller globally
    registerController(controller);

    if (infinite) {
      controller.repeat(reverse: reverse);
    } else {
      controller.forward();
    }

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && !infinite) {
        onComplete?.call();
      }
    });

    final animation = Tween<Offset>(begin: begin, end: end)
        .animate(CurvedAnimation(parent: controller, curve: curve));

    return SlideTransition(position: animation, child: child);
  }

  Widget sideToSide(
      Widget child, {
        required AnimationController controller,
        Duration duration = const Duration(seconds: 4),
        Curve curve = Curves.easeInOut,
        Offset begin = const Offset(-0.04, 0.0),
        Offset end = const Offset(0.04, 0.0),
        bool reverse = true,
        bool infinite = true,
        VoidCallback? onComplete,
      }) {
    _resetController(controller); // Stop and reset the controller
    controller.duration = duration;

    // Register controller globally
    registerController(controller);

    if (infinite) {
      controller.repeat(reverse: reverse);
    } else {
      controller.forward();
    }

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && !infinite) {
        onComplete?.call();
      }
    });

    final animation = Tween<Offset>(begin: begin, end: end)
        .animate(CurvedAnimation(parent: controller, curve: curve));

    return SlideTransition(position: animation, child: child);
  }

  Widget pulse(
      Widget child, {
        required AnimationController controller,
        Duration duration = const Duration(seconds: 6),
        Curve curve = Curves.easeInOut,
        double begin = 0.93,
        double end = 1.0,
        bool reverse = true,
        bool infinite = true,
        VoidCallback? onComplete,
      }) {
    _resetController(controller); // Stop and reset the controller
    controller.duration = duration;

    // Register controller globally
    registerController(controller);

    if (infinite) {
      controller.repeat(reverse: reverse);
    } else {
      controller.forward();
    }

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && !infinite) {
        onComplete?.call();
      }
    });

    final animation = Tween<double>(begin: begin, end: end)
        .animate(CurvedAnimation(parent: controller, curve: curve));

    return ScaleTransition(scale: animation, child: child);
  }

  Widget shakeAndDrop(
      Widget child, {
        required AnimationController shakeController,
        required AnimationController dropController,
        Duration shakeDuration = const Duration(milliseconds: 100),
        Duration shakeTotalDuration = const Duration(seconds: 4),
        Duration dropDuration = const Duration(seconds: 2),
        Duration dropStartDelay = const Duration(seconds: 2),
        Curve shakeCurve = Curves.easeInOut,
        Curve dropCurve = Curves.easeIn,
        Offset shakeBegin = const Offset(-10.0, 0.0),
        Offset shakeEnd = const Offset(10.0, 0.0),
        Offset dropBegin = const Offset(0.0, 0.0),
        Offset dropEnd = const Offset(0.0, 100.0),
        bool infinite = false,
        VoidCallback? onComplete,
      }) {
    _resetController(shakeController); // Stop and reset controllers
    _resetController(dropController);

    // Register controller globally
    registerController(shakeController);
    registerController(dropController);

    shakeController.duration = shakeDuration;
    shakeController.repeat(reverse: true);

    Future.delayed(shakeTotalDuration, () {
      shakeController.stop();
    });

    Future.delayed(dropStartDelay, () {
      dropController.duration = dropDuration;
      dropController.forward();
    });

    dropController.addStatusListener((status) {
      if (status == AnimationStatus.completed && !infinite) {
        shakeController.stop();
        onComplete?.call();
      }
    });

    final shakeAnimation = Tween<Offset>(begin: shakeBegin, end: shakeEnd)
        .animate(CurvedAnimation(parent: shakeController, curve: shakeCurve));

    final dropAnimation = Tween<Offset>(begin: dropBegin, end: dropEnd)
        .animate(CurvedAnimation(parent: dropController, curve: dropCurve));

    return AnimatedBuilder(
      animation: Listenable.merge([shakeController, dropController]),
      builder: (context, child) {
        final shakeOffset = shakeAnimation.value;
        final dropOffset = dropAnimation.value;
        return Transform.translate(
          offset: shakeOffset + dropOffset,
          child: child,
        );
      },
      child: child,
    );
  }

  Widget slideUpAndDown(
      Widget child, {
        required AnimationController controller,
        Duration duration = const Duration(seconds: 4),
        Curve curve = Curves.easeInOut,
        Offset begin = const Offset(0.0, -1.0),
        Offset middle = const Offset(0.0, 0.0),
        Offset end = const Offset(0.0, -1.0),
        bool infinite = false,
        VoidCallback? onComplete,
      }) {
    _resetController(controller); // Stop and reset the controller
    controller.duration = duration;

    // Register controller globally
    registerController(controller);

    final animation = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween<Offset>(begin: begin, end: middle).chain(CurveTween(curve: curve)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: ConstantTween<Offset>(middle),
        weight: 2,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(begin: middle, end: end).chain(CurveTween(curve: curve)),
        weight: 1,
      ),
    ]).animate(controller);

    if (infinite) {
      controller.repeat();
    } else {
      controller.forward();
    }

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && !infinite) {
        onComplete?.call();
      }
    });

    return SlideTransition(position: animation, child: child);
  }

  Widget cutTape(
      Widget child, {
        required AnimationController controller,
        Duration duration = const Duration(seconds: 1),
        Curve scaleCurve = Curves.easeInOut,
        Curve rotateCurve = Curves.easeInOut,
        double scaleBegin = 1.0,
        double scaleEnd = 0.9,
        double rotationBegin = 0.0, // Start angle (in radians)
        double rotationEnd = pi / 2, // 90 degrees downward (in radians)
        double translateY = 0.0, // Amount to translate along the Y-axis
        Duration yAxisDelay = const Duration(milliseconds: 800), // Delay for Y-axis animation
        Alignment pivot = Alignment.centerLeft, // Default pivot point
        VoidCallback? onComplete,
      }) {
    _resetController(controller); // Reset the controller
    controller.duration = duration;

    // Register controller globally
    registerController(controller);

    // Define animations for scale, rotation, and delayed translation
    final scaleAnimation = Tween<double>(begin: scaleBegin, end: scaleEnd)
        .animate(CurvedAnimation(parent: controller, curve: scaleCurve));
    final rotationAnimation = Tween<double>(begin: rotationBegin, end: rotationEnd)
        .animate(CurvedAnimation(parent: controller, curve: rotateCurve));
    final translateAnimation = Tween<double>(begin: 0.0, end: translateY).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          yAxisDelay.inMilliseconds / duration.inMilliseconds, // Start delay for Y-axis
          1.0, // End at the same time as the rest of the animation
          curve: Curves.easeInOut,
        ),
      ),
    );

    // Start the animation
    controller.forward();

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        onComplete?.call();
      }
    });

    // Return an AnimatedBuilder to combine scale, rotation, and translation with pivot
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Transform(
          alignment: pivot, // Use the provided pivot point
          transform: Matrix4.identity()
            ..translate(0.0, translateAnimation.value) // Apply delayed Y-axis translation
            ..scale(scaleAnimation.value, 1) // Horizontal shrink only
            ..rotateZ(rotationAnimation.value), // Rotate in 2D plane around Z-axis
          child: child,
        );
      },
      child: child,
    );
  }
}

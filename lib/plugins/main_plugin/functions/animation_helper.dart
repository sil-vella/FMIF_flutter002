import 'package:flutter/material.dart';
import 'main_plugin_helper.dart';

class AnimationHelper extends PluginHelper {
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
    controller.duration = duration;
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
    controller.duration = duration;
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
    controller.duration = duration;
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
        Duration shakeDuration = const Duration(milliseconds: 100), // Fast shake cycle
        Duration shakeTotalDuration = const Duration(seconds: 4),    // Total shake time
        Duration dropDuration = const Duration(seconds: 2),          // Drop for 2 seconds
        Duration dropStartDelay = const Duration(seconds: 2),        // Delay before drop starts
        Curve shakeCurve = Curves.easeInOut,
        Curve dropCurve = Curves.easeIn,
        Offset shakeBegin = const Offset(-10.0, 0.0),
        Offset shakeEnd = const Offset(10.0, 0.0),
        Offset dropBegin = const Offset(0.0, 0.0),
        Offset dropEnd = const Offset(0.0, 100.0),
        bool infinite = false,
        VoidCallback? onComplete,
      }) {
    // Set fast shake cycle duration
    shakeController.duration = shakeDuration;

    // Start shaking continuously
    shakeController.repeat(reverse: true);

    // Schedule shake to stop after total shake duration
    Future.delayed(shakeTotalDuration, () {
      shakeController.stop();
    });

    // Ensure drop starts exactly after the drop delay
    Future.delayed(dropStartDelay, () {
      dropController.duration = dropDuration;
      dropController.forward();
    });

    // Call the onComplete callback when the drop animation completes
    dropController.addStatusListener((status) {
      if (status == AnimationStatus.completed && !infinite) {
        shakeController.stop(); // Stop shaking when the drop completes
        onComplete?.call();
      }
    });

    // Define shake animation and drop animation
    final shakeAnimation = Tween<Offset>(begin: shakeBegin, end: shakeEnd)
        .animate(CurvedAnimation(parent: shakeController, curve: shakeCurve));

    final dropAnimation = Tween<Offset>(begin: dropBegin, end: dropEnd)
        .animate(CurvedAnimation(parent: dropController, curve: dropCurve));

    // Use AnimatedBuilder to apply both animations together
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
        Duration duration = const Duration(seconds: 4), // Total duration for one full cycle
        Curve curve = Curves.easeInOut,
        Offset begin = const Offset(0.0, -1.0),       // Start at -100% vertical offset
        Offset middle = const Offset(0.0, 0.0),       // Original position for pause
        Offset end = const Offset(0.0, -1.0),         // End back at -100% offset
        bool infinite = false,
        VoidCallback? onComplete,
      }) {
    // Set the total duration
    controller.duration = duration;

    // Define the animation sequence with slide up, pause, and slide down phases
    final animation = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween<Offset>(begin: begin, end: middle).chain(CurveTween(curve: curve)),
        weight: 1, // Slide up in 1 second (25% of total time)
      ),
      TweenSequenceItem(
        tween: ConstantTween<Offset>(middle), // Pause at original position
        weight: 2, // Pause for 2 seconds (50% of total time)
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(begin: middle, end: end).chain(CurveTween(curve: curve)),
        weight: 1, // Slide down in 1 second (25% of total time)
      ),
    ]).animate(controller);

    // Start the animation with repeat or forward based on `infinite`
    if (infinite) {
      controller.repeat();
    } else {
      controller.forward();
    }

    // Listener for animation completion
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && !infinite) {
        onComplete?.call();
      }
    });

    // Return the animated child with SlideTransition
    return SlideTransition(position: animation, child: child);
  }

}

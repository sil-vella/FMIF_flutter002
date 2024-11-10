import 'package:flutter/material.dart';
import 'main_plugin_helper.dart';

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
}

import 'package:flutter/material.dart';
import 'main_plugin_helper.dart';

class AnimationHelper extends PluginHelper {
  static Widget bounce(
      Widget child, {
        required AnimationController controller,
        VoidCallback? onComplete,
      }) {
    controller.duration = Duration(seconds: 3);
    controller.repeat(reverse: true);

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        onComplete?.call();
      }
    });

    final animation = Tween<Offset>(
      begin: Offset(0.0, -0.09),
      end: Offset(0.0, 0.09),
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

    return SlideTransition(position: animation, child: child);
  }

  static Widget sideToSide(
      Widget child,
      {required AnimationController controller,
        VoidCallback? onComplete}) {
    controller.duration = Duration(seconds: 4);
    controller.repeat(reverse: true);

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        onComplete?.call();
      }
    });

    final animation = Tween<Offset>(
      begin: Offset(-0.04, 0.0),
      end: Offset(0.04, 0.0),
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

    return SlideTransition(position: animation, child: child);
  }

  static Widget pulse(
      Widget child,
      {required AnimationController controller,
        VoidCallback? onComplete}) {
    controller.duration = Duration(seconds: 6);
    controller.repeat(reverse: true);

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        onComplete?.call();
      }
    });

    final animation = Tween<double>(begin: 0.93, end: 1.00).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut));

    return ScaleTransition(scale: animation, child: child);
  }

  static Widget shakeAndDrop(
      Widget child, {
        required AnimationController shakeController,
        required AnimationController dropController,
        VoidCallback? onComplete,
      }) {
    shakeController.duration = Duration(milliseconds: 200);
    shakeController.forward();

    Future.delayed(Duration(seconds: 2), () {
      if (dropController.status == AnimationStatus.dismissed) {
        dropController.forward();
      }
    });

    dropController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        shakeController.stop();
        onComplete?.call();
      }
    });

    final shakeAnimation = Tween<Offset>(
      begin: Offset(-10.0, 0.0),
      end: Offset(10.0, 0.0),
    ).animate(
      CurvedAnimation(
        parent: shakeController,
        curve: Curves.easeInOut,
      ),
    );

    final dropAnimation = Tween<Offset>(
      begin: Offset(0.0, 0.0),
      end: Offset(0.0, 100.0),
    ).animate(
      CurvedAnimation(
        parent: dropController,
        curve: Curves.easeIn,
      ),
    );

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

  // New slide up and down animation
  static Widget slideUpAndDown(
      Widget child, {
        required AnimationController controller,
        VoidCallback? onComplete,
      }) {
    controller.duration = Duration(seconds: 4); // Total duration: 1 second up, 2 seconds wait, 1 second down
    controller.forward();

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        onComplete?.call();
      }
    });

    final animation = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween<Offset>(begin: Offset(0.0, 0.5), end: Offset(0.0, 0.0))
            .chain(CurveTween(curve: Curves.easeOut)), // Slide up in 1 second
        weight: 1,
      ),
      TweenSequenceItem(
        tween: ConstantTween<Offset>(Offset(0.0, 0.0)), // Pause at the top for 2 seconds
        weight: 2,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(begin: Offset(0.0, 0.0), end: Offset(0.0, 0.5))
            .chain(CurveTween(curve: Curves.easeIn)), // Slide down in 1 second
        weight: 1,
      ),
    ]).animate(controller);

    return SlideTransition(position: animation, child: child);
  }
}
import 'dart:async';
import 'dart:developer' as dev;
import 'dart:math';
import 'package:flush_me_im_famous/plugins/main_plugin/functions/play_functions.dart';
import 'package:flutter/material.dart';
import '../../../services/shared_preferences_service.dart';
import 'package:provider/provider.dart';
import '../../../services/providers/app_state_provider.dart';
import '../../00_base/module_manager.dart';

class TimerClockComponent extends StatefulWidget {
  const TimerClockComponent({Key? key}) : super(key: key);

  @override
  State<TimerClockComponent> createState() => _TimerClockComponentState();
}

class _TimerClockComponentState extends State<TimerClockComponent> {
  int secondsRemaining = 0;
  Timer? _timer;
  late Map<String, dynamic> mainPluginState;

  @override
  void initState() {
    super.initState();

    final appStateProvider = Provider.of<AppStateProvider>(context, listen: false);

    // Retrieve MainPluginState during init
    mainPluginState = appStateProvider.getPluginState<Map<String, dynamic>>("MainPluginState") ?? {};

    // Check category and fetch level from SharedPreferences
    final category = mainPluginState['celeb_category'] ?? "Unknown";
    final levelKey = 'level_${category.replaceAll(" ", "_").toLowerCase()}';
    final level = SharedPreferencesService().getInt(levelKey) ?? 0; // Default level to 0

    if (level >= 2) {
      switch (level) {
        case 2:
          secondsRemaining = 10;
          break;
        case 4:
          secondsRemaining = 15;
          break;
        case 5:
          secondsRemaining = 10;
          break;
        default:
          secondsRemaining = 10;
      }

      if (mainPluginState['play_state'] == 'in_play') {
        final audioHelper = ModuleManager().getInstance<dynamic>("AudioHelper");

        audioHelper?.playSpecific(
          context,
          audioHelper.timerSounds,
          "ticking",
        );
        _startCountdown(() async {
          audioHelper?.stopSound(audioHelper.timerSounds, "ticking");
          // Play time up sound
          audioHelper?.playSpecific(
            context,
            audioHelper.timerSounds,
            "time_up",
          );

          appStateProvider.updatePluginState("MainPluginState", {
            'play_state': 'revealed_incorrect',
            'flushing': 'false',
            'plugin_anims': {
              'head_anims': ['pulse', 'sideToSide', 'bounce'],
              'ribbon_anims': ['cut_tape'],
            }
          });
          dev.log("Calling activateAftermath for revealed_incorrect.");
          await PlayFunctions.activateAftermath(appStateProvider, "MainPluginState", context);
        });
      }
    }
  }

  void _startCountdown(VoidCallback onComplete) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining > 0) {
        setState(() {
          secondsRemaining--;
        });
      } else {
        timer.cancel();
        onComplete();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (secondsRemaining == 0) {
      return const SizedBox.shrink(); // Don't display if timer is zero
    }

    final angle = (secondsRemaining / 10) * 2 * pi;
    return Center(
      child: CustomPaint(
        size: const Size(50, 50),
        painter: AnalogCountdownPainter(angle, secondsRemaining),
      ),
    );
  }
}

class AnalogCountdownPainter extends CustomPainter {
  final double angle;
  final int secondsRemaining;

  AnalogCountdownPainter(this.angle, this.secondsRemaining);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw clock face
    final facePaint = Paint()
      ..color = Colors.grey.shade200
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, facePaint);

    // Draw clock border
    final borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawCircle(center, radius, borderPaint);

    // Draw clock hand
    final handPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final handLength = radius * 0.8;
    final handX = center.dx + handLength * cos(angle - pi / 2);
    final handY = center.dy + handLength * sin(angle - pi / 2);
    canvas.drawLine(center, Offset(handX, handY), handPaint);

    // Draw seconds text
    final textPainter = TextPainter(
      text: TextSpan(
        text: secondsRemaining > 0 ? '$secondsRemaining' : '',
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    final textOffset = Offset(
      center.dx - textPainter.width / 2,
      center.dy - textPainter.height / 2,
    );
    textPainter.paint(canvas, textOffset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

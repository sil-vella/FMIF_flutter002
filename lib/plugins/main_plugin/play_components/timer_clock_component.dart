import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_state_provider.dart';

class TimerClockComponent extends StatelessWidget {
  const TimerClockComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appStateProvider = Provider.of<AppStateProvider>(context);
    final secondsRemaining =
        appStateProvider.getPluginState("MainPluginState")?["secondsRemaining"] ?? 10;
    final angle = (secondsRemaining / 10) * 2 * pi; // Calculate angle for the analog clock hand

    return Center(
      child: CustomPaint(
        size: const Size(50, 50), // Adjust size as needed
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

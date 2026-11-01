import 'dart:math';
import 'package:flutter/material.dart';

class SiriWave extends StatefulWidget {
  final bool listening;

  const SiriWave({super.key, required this.listening});

  @override
  State<SiriWave> createState() => _SiriWaveState();
}

class _SiriWaveState extends State<SiriWave>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    if (widget.listening) {
      controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant SiriWave oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.listening) {
      controller.repeat();
    } else {
      controller.stop();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(260, 260),
          painter: SiriWavePainter(controller.value),
        );
      },
    );
  }
}

class SiriWavePainter extends CustomPainter {
  final double progress;

  SiriWavePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (int i = 0; i < 3; i++) {
      final radius = 80 + (progress * 40) + (i * 18);

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = Colors.cyan.withValues(alpha: (0.35 - i * 0.08).clamp(0.05, 0.4));

      canvas.drawCircle(center, radius, paint);
    }

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..color = Colors.deepPurpleAccent;

    final path = Path();

    for (double x = 0; x <= size.width; x++) {
      final y =
          size.height / 2 +
          sin((x / size.width * 4 * pi) + (progress * 2 * pi)) * 15;

      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant SiriWavePainter oldDelegate) {
    return true;
  }
}

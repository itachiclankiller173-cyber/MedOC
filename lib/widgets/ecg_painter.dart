import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedECG extends StatefulWidget {
  const AnimatedECG({super.key});

  @override
  State<AnimatedECG> createState() => _AnimatedECGState();
}

class _AnimatedECGState extends State<AnimatedECG>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
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
          painter: ECGPainter(controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class ECGPainter extends CustomPainter {
  final double progress;

  ECGPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint gridPaint = Paint()
      ..color = Colors.teal.withValues(alpha: 0.08)
      ..strokeWidth = 1;

    const double gap = 25;

    for (double x = 0; x < size.width; x += gap) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    for (double y = 0; y < size.height; y += gap) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final Paint ecgPaint = Paint()
      ..color = Colors.teal
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Path path = Path();

    final double centerY = size.height / 2;

    path.moveTo(0, centerY);

    final double visibleWidth = size.width * progress;

    for (double x = 0; x <= visibleWidth; x++) {
      double y = centerY;

      final double cycle = (x % 180);

      if (cycle < 40) {
        y = centerY;
      } else if (cycle < 55) {
        y = centerY - 8;
      } else if (cycle < 70) {
        y = centerY;
      } else if (cycle < 82) {
        y = centerY + 30;
      } else if (cycle < 88) {
        y = centerY - 80;
      } else if (cycle < 98) {
        y = centerY + 45;
      } else if (cycle < 120) {
        y = centerY;
      } else if (cycle < 145) {
        y = centerY - 18 * sin((cycle - 120) / 25 * pi);
      } else {
        y = centerY;
      }

      path.lineTo(x, y);
    }

    canvas.drawPath(path, ecgPaint);

    final Paint glow = Paint()
      ..color = Colors.tealAccent
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    canvas.drawCircle(Offset(visibleWidth, centerY), 5, glow);

    canvas.drawCircle(
      Offset(visibleWidth, centerY),
      3,
      Paint()..color = Colors.tealAccent,
    );
  }

  @override
  bool shouldRepaint(covariant ECGPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

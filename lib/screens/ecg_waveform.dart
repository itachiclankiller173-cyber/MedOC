import 'dart:math' as math;
import 'package:flutter/material.dart';

class EcgWaveform extends StatefulWidget {
  const EcgWaveform({super.key});

  @override
  State<EcgWaveform> createState() => _EcgWaveformState();
}

class _EcgWaveformState extends State<EcgWaveform>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF071923),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.teal.shade700),
      ),
      padding: const EdgeInsets.all(8),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _EcgPainter(_controller.value),
            child: const SizedBox.expand(),
          );
        },
      ),
    );
  }
}

class _EcgPainter extends CustomPainter {
  final double progress;

  _EcgPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFF173541)
      ..strokeWidth = 0.5;

    for (double x = 0; x < size.width; x += 15) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    for (double y = 0; y < size.height; y += 15) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final path = Path();
    final center = size.height / 2;
    const cycle = 120.0;

    for (double x = 0; x <= size.width; x++) {
      final p = (x + progress * cycle) % cycle;
      double y = center;

      if (p >= 12 && p < 28) {
        y = center - 7 * math.sin((p - 12) / 16 * math.pi);
      } else if (p >= 35 && p < 43) {
        y = center + (p - 35) * 2;
      } else if (p >= 43 && p < 49) {
        y = center + 16 - (p - 43) * 7;
      } else if (p >= 49 && p < 56) {
        y = center - 26 + (p - 49) * 4;
      } else if (p >= 56 && p < 63) {
        y = center + 2 - (p - 56) * 0.3;
      } else if (p >= 72 && p < 96) {
        y = center - 9 * math.sin((p - 72) / 24 * math.pi);
      }

      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final glow = Paint()
      ..color = Colors.tealAccent.withValues(alpha: 0.25)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final line = Paint()
      ..color = Colors.tealAccent
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, glow);
    canvas.drawPath(path, line);
  }

  @override
  bool shouldRepaint(covariant _EcgPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

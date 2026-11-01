
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

class EcgScreen extends StatefulWidget {
  const EcgScreen({super.key});

  @override
  State<EcgScreen> createState() => _EcgScreenState();
}

class _EcgScreenState extends State<EcgScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _bpmTimer;

  int _bpm = 72;
  int _elapsedSeconds = 0;
  bool _isRunning = true;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _bpmTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) {
        if (!mounted || !_isRunning) return;

        setState(() {
          // Demo values only. Not measured from a person.
          _bpm = 68 + math.Random().nextInt(11);
          _elapsedSeconds += 3;
        });
      },
    );
  }

  @override
  void dispose() {
    _bpmTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _toggleSimulation() {
    setState(() {
      _isRunning = !_isRunning;

      if (_isRunning) {
        _controller.repeat();
        _bpmTimer?.cancel();
        _bpmTimer = Timer.periodic(
          const Duration(seconds: 3),
          (_) {
            if (!mounted || !_isRunning) return;
            setState(() {
              _bpm = 68 + math.Random().nextInt(11);
              _elapsedSeconds += 3;
            });
          },
        );
      } else {
        _controller.stop();
        _bpmTimer?.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFF0B1220);
    const panel = Color(0xFF151F30);
    const green = Color(0xFF35E6A0);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'MEDOC ECG Monitor',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Clear simulation warning
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF392817),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.orangeAccent.withValues(alpha: 0.65),
                ),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orangeAccent,
                    size: 28,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SIMULATED DEMO',
                          style: TextStyle(
                            color: Colors.orangeAccent,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'This waveform and all readings are artificial. '
                          'No ECG sensor is connected. Not for medical '
                          'decisions.',
                          style: TextStyle(
                            color: Colors.white70,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'Heart rate',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: panel,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.favorite,
                    color: Colors.redAccent,
                    size: 38,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '$_bpm',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 44,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(bottom: 9, left: 7),
                              child: Text(
                                'BPM',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Text(
                          'Simulated heart rate',
                          style: TextStyle(
                            color: green,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: _isRunning
                          ? green.withValues(alpha: 0.12)
                          : Colors.white10,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _isRunning ? 'DEMO ON' : 'PAUSED',
                      style: TextStyle(
                        color: _isRunning ? green : Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            Row(
              children: [
                const Expanded(
                  child: Text(
                    'ECG waveform',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(
                  Icons.circle,
                  size: 9,
                  color: _isRunning ? green : Colors.grey,
                ),
                const SizedBox(width: 6),
                Text(
                  _isRunning ? 'ANIMATING' : 'STOPPED',
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 11,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 230,
                color: const Color(0xFF071710),
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: _EcgPainter(
                        progress: _controller.value,
                      ),
                      child: const SizedBox.expand(),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Illustrative waveform • Not a real ECG recording',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 22),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: panel,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.timer_outlined,
                    color: Colors.lightBlueAccent,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Demo duration',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                  Text(
                    '${(_elapsedSeconds ~/ 60).toString().padLeft(2, '0')}:'
                    '${(_elapsedSeconds % 60).toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _toggleSimulation,
                icon: Icon(
                  _isRunning ? Icons.pause : Icons.play_arrow,
                ),
                label: Text(
                  _isRunning ? 'Pause Simulation' : 'Resume Simulation',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: green,
                  foregroundColor: background,
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            const Center(
              child: Text(
                'MEDOC • ECG DEMO MODE',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 11,
                  letterSpacing: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EcgPainter extends CustomPainter {
  final double progress;

  _EcgPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFF17432E)
      ..strokeWidth = 0.6;

    // ECG-style background grid
    const cell = 15.0;

    for (double x = 0; x <= size.width; x += cell) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        gridPaint,
      );
    }

    for (double y = 0; y <= size.height; y += cell) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    final centerY = size.height * 0.52;
    final amplitude = size.height * 0.30;

    final glowPaint = Paint()
      ..color = const Color(0xFF35E6A0).withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    final linePaint = Paint()
      ..color = const Color(0xFF35E6A0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();

    for (double x = 0; x <= size.width; x += 1) {
      // Three illustrative beats across the screen.
      final position =
          (x / size.width * 3 - progress * 3) % 1.0;
      final phase = position < 0 ? position + 1.0 : position;

      double gaussian(double center, double spread) {
        final d = (phase - center) / spread;
        return math.exp(-0.5 * d * d);
      }

      // P wave, QRS complex and T wave.
      final wave =
          0.12 * gaussian(0.20, 0.045) -
          0.15 * gaussian(0.365, 0.014) +
          1.00 * gaussian(0.400, 0.012) -
          0.25 * gaussian(0.438, 0.018) +
          0.30 * gaussian(0.66, 0.075);

      final y = centerY - wave * amplitude;
      final point = Offset(x, y);

      if (x == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _EcgPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

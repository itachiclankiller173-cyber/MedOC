import 'dart:math';

import 'package:flutter/material.dart';

class SiriOrb extends StatefulWidget {
  final bool listening;

  const SiriOrb({super.key, required this.listening});

  @override
  State<SiriOrb> createState() => _SiriOrbState();
}

class _SiriOrbState extends State<SiriOrb> with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    if (widget.listening) {
      controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant SiriOrb oldWidget) {
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
        final scale = widget.listening
            ? 1 + sin(controller.value * 2 * pi) * 0.08
            : 1.0;

        return Transform.scale(
          scale: scale,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.cyanAccent,
                  Colors.blue,
                  Colors.deepPurple,
                  Colors.black,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyan.withValues(alpha: .5),
                  blurRadius: 35,
                  spreadRadius: 6,
                ),
                BoxShadow(
                  color: Colors.deepPurple.withValues(alpha: .4),
                  blurRadius: 50,
                  spreadRadius: 8,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

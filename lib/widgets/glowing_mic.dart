import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';

class GlowingMic extends StatelessWidget {
  final bool listening;
  final VoidCallback onTap;

  const GlowingMic({super.key, required this.listening, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AvatarGlow(
      animate: listening,
      glowColor: Colors.cyan,
      duration: const Duration(milliseconds: 1800),
      repeat: true,
      glowRadiusFactor: 0.4,
      child: Material(
        shape: const CircleBorder(),
        elevation: 12,
        color: listening ? Colors.red : Colors.teal,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: const SizedBox(
            width: 90,
            height: 90,
            child: Icon(Icons.mic, color: Colors.white, size: 45),
          ),
        ),
      ),
    );
  }
}

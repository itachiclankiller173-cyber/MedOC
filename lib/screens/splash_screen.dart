import 'dart:async';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../widgets/ecg_painter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoAnimation;
  late Animation<double> _textAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _logoAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _textAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();

    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FFFD),
      body: Stack(
        children: [
          const Positioned.fill(child: AnimatedECG()),

          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.teal.withAlpha(13),
                  Colors.white,
                  Colors.teal.withAlpha(13),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: _logoAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.teal.withAlpha(80),
                          blurRadius: 25,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      "assets/images/image.png",
                      width: 140,
                      height: 140,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                FadeTransition(
                  opacity: _textAnimation,
                  child: const Text(
                    "MedOC",
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                      letterSpacing: 2,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                FadeTransition(
                  opacity: _textAnimation,
                  child: const Text(
                    "AI Healthcare Assistant",
                    style: TextStyle(fontSize: 20, color: Colors.black54),
                  ),
                ),

                const SizedBox(height: 50),

                const CircularProgressIndicator(color: Colors.teal),

                const SizedBox(height: 15),

                const Text(
                  "Loading...",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

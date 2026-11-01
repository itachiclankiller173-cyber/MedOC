
import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../screens/forgot_password_screen.dart';
import '../services/auth_service.dart';
import '../auth/register_screen.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final AuthService auth = AuthService();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool loading = false;
  bool obscure = true;

  late final AnimationController _ecgController;

  static const navy = Color(0xFF123B5D);
  static const teal = Color(0xFF079BA4);
  static const pale = Color(0xFFF2FAFC);

  @override
  void initState() {
    super.initState();
    _ecgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  void dispose() {
    _ecgController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => loading = true);

    try {
      final error = await auth.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (!mounted) return;
      setState(() => loading = false);

      if (error == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const DashboardScreen(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login failed. Please try again.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  InputDecoration fieldDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFF8199AE),
        fontSize: 15,
      ),
      prefixIcon: Icon(icon, color: navy, size: 23),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white.withOpacity(0.58),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 20,
        horizontal: 17,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Color(0xFFB8D9E9)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(
          color: Color(0xFFB8D9E9),
          width: 1.3,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: teal, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pale,
      body: Stack(
        children: [
          // Full-screen artwork: ECG and curves are part of the background.
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _ecgController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _MedicalBackgroundPainter(
                    progress: _ecgController.value,
                  ),
                );
              },
            ),
          ),

          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(23, 22, 23, 25),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 47,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Brand
                        Row(
                          children: [
                            Container(
                              width: 53,
                              height: 53,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [teal, Color(0xFF087E91)],
                                ),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Icon(
                                Icons.favorite_rounded,
                                color: Colors.white,
                                size: 31,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'MEDOC',
                                  style: TextStyle(
                                    color: navy,
                                    fontSize: 27,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 2.3,
                                  ),
                                ),
                                Text(
                                  'Your health, connected.',
                                  style: TextStyle(
                                    color: navy,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.verified_user_outlined,
                              color: teal,
                              size: 24,
                            ),
                          ],
                        ),

                        const SizedBox(height: 44),

                        const Text(
                          'Welcome Back',
                          style: TextStyle(
                            color: navy,
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 9),
                        const Text(
                          'Sign in to continue to your\nMEDOC dashboard.',
                          style: TextStyle(
                            color: Color(0xFF6F8FA8),
                            fontSize: 16,
                            height: 1.55,
                          ),
                        ),

                        const SizedBox(height: 31),

                        // Translucent form card lets the artwork flow behind it.
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(
                            20, 25, 20, 23,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.79),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.9),
                              width: 1.4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF2C8295)
                                    .withOpacity(0.09),
                                blurRadius: 28,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  autofillHints: const [
                                    AutofillHints.email,
                                  ],
                                  autocorrect: false,
                                  validator: (value) {
                                    final email = value?.trim() ?? '';
                                    if (email.isEmpty) {
                                      return 'Please enter your email';
                                    }
                                    if (!email.contains('@') ||
                                        !email.contains('.')) {
                                      return 'Enter a valid email address';
                                    }
                                    return null;
                                  },
                                  decoration: fieldDecoration(
                                    hint: 'Email address',
                                    icon: Icons.mail_outline_rounded,
                                  ),
                                ),

                                const SizedBox(height: 20),

                                TextFormField(
                                  controller: passwordController,
                                  obscureText: obscure,
                                  textInputAction: TextInputAction.done,
                                  autofillHints: const [
                                    AutofillHints.password,
                                  ],
                                  onFieldSubmitted: (_) {
                                    if (!loading) login();
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your password';
                                    }
                                    return null;
                                  },
                                  decoration: fieldDecoration(
                                    hint: 'Password',
                                    icon: Icons.lock_outline_rounded,
                                    suffix: IconButton(
                                      tooltip: obscure
                                          ? 'Show password'
                                          : 'Hide password',
                                      onPressed: () {
                                        setState(() {
                                          obscure = !obscure;
                                        });
                                      },
                                      icon: Icon(
                                        obscure
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        color: navy,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 6),

                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const ForgotPasswordScreen(),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'Forgot Password?',
                                      style: TextStyle(
                                        color: Color(0xFF078A96),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 13),

                                SizedBox(
                                  width: double.infinity,
                                  height: 59,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF20ADB4),
                                          Color(0xFF087D91),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(19),
                                      boxShadow: [
                                        BoxShadow(
                                          color: teal.withOpacity(0.22),
                                          blurRadius: 16,
                                          offset: const Offset(0, 7),
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton(
                                      onPressed: loading ? null : login,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        disabledBackgroundColor:
                                            Colors.grey.shade400,
                                        foregroundColor: Colors.white,
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(19),
                                        ),
                                      ),
                                      child: loading
                                          ? const SizedBox(
                                              width: 23,
                                              height: 23,
                                              child:
                                                  CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2.2,
                                              ),
                                            )
                                          : const Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Login',
                                                  style: TextStyle(
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                SizedBox(width: 13),
                                                Icon(
                                                  Icons.arrow_forward_rounded,
                                                  size: 24,
                                                ),
                                              ],
                                            ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 23),

                                Row(
                                  children: [
                                    const Expanded(
                                      child: Divider(
                                        color: Color(0xFFD0E2EC),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                      ),
                                      child: Text(
                                        'OR',
                                        style: TextStyle(
                                          color: Colors.blueGrey.shade400,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    const Expanded(
                                      child: Divider(
                                        color: Color(0xFFD0E2EC),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 22),

                                SizedBox(
                                  width: double.infinity,
                                  height: 55,
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const RegisterScreen(),
                                        ),
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.person_add_alt_1_rounded,
                                    ),
                                    label: const Text('Create an Account'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: navy,
                                      side: const BorderSide(
                                        color: Color(0xFF13A5C2),
                                        width: 1.5,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(19),
                                      ),
                                      textStyle: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 24),

                                const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.shield_outlined,
                                      color: Color(0xFF527995),
                                      size: 21,
                                    ),
                                    SizedBox(width: 9),
                                    Flexible(
                                      child: Text(
                                        'Secure sign-in • Your health matters',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Color(0xFF7C9AB1),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        const Center(
                          child: Text(
                            'ECG artwork is illustrative only.',
                            style: TextStyle(
                              color: Color(0xFF7795A9),
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MedicalBackgroundPainter extends CustomPainter {
  final double progress;

  _MedicalBackgroundPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Soft blue-white background.
    final backgroundPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFF8FCFF),
          Color(0xFFE5F7FA),
          Color(0xFFD4F0F4),
        ],
      ).createShader(rect);

    canvas.drawRect(rect, backgroundPaint);

    // Large organic teal shape behind the login form.
    final flowingShape = Path()
      ..moveTo(size.width * 0.53, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * 0.49)
      ..cubicTo(
        size.width * 0.78,
        size.height * 0.47,
        size.width * 0.69,
        size.height * 0.39,
        size.width * 0.53,
        size.height * 0.42,
      )
      ..cubicTo(
        size.width * 0.39,
        size.height * 0.45,
        size.width * 0.31,
        size.height * 0.40,
        size.width * 0.53,
        0,
      )
      ..close();

    canvas.drawPath(
      flowingShape,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFF48BBD0),
            Color(0xFF12A9B0),
            Color(0xFFBCEBF0),
          ],
        ).createShader(rect),
    );

    // Fine grid integrated into the teal artwork.
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.10)
      ..strokeWidth = 0.6;

    final gridArea = Rect.fromLTWH(
      size.width * 0.53,
      0,
      size.width * 0.47,
      size.height * 0.44,
    );

    canvas.save();
    canvas.clipRect(gridArea);

    for (double x = gridArea.left; x < size.width; x += 22) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, gridArea.bottom),
        gridPaint,
      );
    }

    for (double y = 0; y < gridArea.bottom; y += 22) {
      canvas.drawLine(
        Offset(gridArea.left, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    // Subtle ECG motif drawn directly on the background.
    final ecg = Path();
    final baseline = size.height * 0.295;
    final left = size.width * 0.42;
    final right = size.width * 0.97;
    final width = right - left;

    for (int i = 0; i <= 500; i++) {
      final x = left + width * i / 500;
      final phase =
          ((i / 500 * 2.3 - progress * 2.3) % 1.0 + 1.0) % 1.0;

      double pulse(double center, double spread) {
        final d = (phase - center) / spread;
        return math.exp(-d * d / 2);
      }

      final wave = 0.09 * pulse(0.22, 0.05) -
          0.12 * pulse(0.38, 0.018) +
          0.75 * pulse(0.415, 0.012) -
          0.20 * pulse(0.45, 0.02) +
          0.17 * pulse(0.68, 0.08);

      final y = baseline - wave * size.height * 0.13;
      if (i == 0) {
        ecg.moveTo(x, y);
      } else {
        ecg.lineTo(x, y);
      }
    }

    canvas.drawPath(
      ecg,
      Paint()
        ..color = Colors.white.withOpacity(0.32)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    canvas.drawPath(
      ecg,
      Paint()
        ..color = const Color(0xFFB9FFFF).withOpacity(0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round,
    );

    canvas.restore();

    // Flowing lower ribbons.
    final bottomWave = Path()
      ..moveTo(0, size.height * 0.87)
      ..cubicTo(
        size.width * 0.22,
        size.height * 0.81,
        size.width * 0.36,
        size.height * 0.99,
        size.width * 0.62,
        size.height * 0.92,
      )
      ..cubicTo(
        size.width * 0.82,
        size.height * 0.87,
        size.width * 0.91,
        size.height * 0.97,
        size.width,
        size.height * 0.93,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      bottomWave,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF75D7D6),
            Color(0xFF168CA9),
            Color(0xFF14547B),
          ],
        ).createShader(rect),
    );

    final ribbon = Path()
      ..moveTo(0, size.height * 0.925)
      ..cubicTo(
        size.width * 0.24,
        size.height * 0.86,
        size.width * 0.38,
        size.height * 1.02,
        size.width * 0.65,
        size.height * 0.955,
      );

    canvas.drawPath(
      ribbon,
      Paint()
        ..color = const Color(0xFF8CF5EB).withOpacity(0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _MedicalBackgroundPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

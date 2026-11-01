import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class CognitiveHealthScreen extends StatefulWidget {
  const CognitiveHealthScreen({super.key});

  @override
  State<CognitiveHealthScreen> createState() => _CognitiveHealthScreenState();
}

class _CognitiveHealthScreenState extends State<CognitiveHealthScreen> {
  int currentQuestion = 0;
  int score = 0;

  bool testStarted = false;
  bool testFinished = false;

  final List<String> memoryItems = ["🍎", "🚗", "⭐", "🐱"];

  final List<String> memoryOptions = ["🐶", "⭐", "🍌", "🏠"];

  final List<String> patternOptions = ["🔵", "🔴", "🟢", "🟡"];

  String? selectedAnswer;

  Timer? reactionTimer;
  Stopwatch stopwatch = Stopwatch();

  bool reactionReady = false;
  bool reactionStarted = false;

  int reactionTime = 0;

  @override
  void dispose() {
    reactionTimer?.cancel();
    super.dispose();
  }

  void startTest() {
    setState(() {
      testStarted = true;
      testFinished = false;
      currentQuestion = 0;
      score = 0;
      selectedAnswer = null;
      reactionReady = false;
      reactionStarted = false;
      reactionTime = 0;
    });
  }

  void selectAnswer(String answer, String correctAnswer) {
    if (selectedAnswer != null) return;

    setState(() {
      selectedAnswer = answer;

      if (answer == correctAnswer) {
        score++;
      }
    });

    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;

      if (currentQuestion < 4) {
        setState(() {
          currentQuestion++;
          selectedAnswer = null;
        });

        if (currentQuestion == 4) {
          startReactionTest();
        }
      } else {
        finishTest();
      }
    });
  }

  void finishTest() {
    reactionTimer?.cancel();

    setState(() {
      testFinished = true;
      testStarted = false;
    });
  }

  void startReactionTest() {
    reactionReady = false;
    reactionStarted = false;

    final random = Random();

    final delay = 1500 + random.nextInt(3000);

    reactionTimer = Timer(Duration(milliseconds: delay), () {
      if (!mounted) return;

      setState(() {
        reactionReady = true;
        reactionStarted = true;
        stopwatch.reset();
        stopwatch.start();
      });
    });
  }

  void reactionPressed() {
    if (!reactionStarted) return;

    stopwatch.stop();

    final milliseconds = stopwatch.elapsedMilliseconds;

    setState(() {
      reactionTime = milliseconds;
      reactionStarted = false;

      if (milliseconds < 700) {
        score++;
      }
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      finishTest();
    });
  }

  String getResultTitle() {
    if (score >= 5) {
      return "Excellent";
    } else if (score >= 4) {
      return "Good";
    } else if (score >= 3) {
      return "Average";
    } else {
      return "Needs Attention";
    }
  }

  Color getResultColor() {
    if (score >= 5) {
      return Colors.green;
    } else if (score >= 4) {
      return Colors.teal;
    } else if (score >= 3) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cognitive Health Check"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: testFinished
          ? buildResultScreen()
          : testStarted
          ? buildTestScreen()
          : buildIntroduction(),
    );
  }

  Widget buildIntroduction() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),

          const CircleAvatar(
            radius: 55,
            backgroundColor: Color(0xffE0F2F1),
            child: Icon(Icons.psychology, size: 65, color: Colors.teal),
          ),

          const SizedBox(height: 25),

          const Text(
            "Cognitive Health Check",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 15),

          const Text(
            "A short interactive activity to check memory, "
            "attention, pattern recognition, and response speed.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),

          const SizedBox(height: 30),

          Card(
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: const [
                  _InfoRow(
                    icon: Icons.timer,
                    title: "Duration",
                    text: "About 2–3 minutes",
                  ),
                  SizedBox(height: 18),
                  _InfoRow(
                    icon: Icons.quiz,
                    title: "Activities",
                    text: "5 simple cognitive tasks",
                  ),
                  SizedBox(height: 18),
                  _InfoRow(
                    icon: Icons.score,
                    title: "Scoring",
                    text: "A simple activity score is generated",
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 25),

          Card(
            color: Colors.amber.shade50,
            child: const Padding(
              padding: EdgeInsets.all(18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Colors.orange, size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "This activity is for general wellness and "
                      "self-awareness only. It cannot diagnose dementia, "
                      "memory disorders, ADHD, or other medical conditions. "
                      "If you have concerns about memory or thinking, "
                      "talk to a qualified healthcare professional.",
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton.icon(
              onPressed: startTest,
              icon: const Icon(Icons.play_arrow),
              label: const Text(
                "START TEST",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget buildTestScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: (currentQuestion + 1) / 5,
            minHeight: 8,
            color: Colors.teal,
            backgroundColor: Colors.grey.shade300,
          ),

          const SizedBox(height: 15),

          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "Task ${currentQuestion + 1} of 5",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),

          const SizedBox(height: 30),

          if (currentQuestion == 0) buildMemoryQuestion(),

          if (currentQuestion == 1) buildNumberQuestion(),

          if (currentQuestion == 2) buildAttentionQuestion(),

          if (currentQuestion == 3) buildPatternQuestion(),

          if (currentQuestion == 4) buildReactionQuestion(),
        ],
      ),
    );
  }

  Widget buildMemoryQuestion() {
    return Column(
      children: [
        const Icon(Icons.memory, size: 55, color: Colors.teal),

        const SizedBox(height: 15),

        const Text(
          "Memory Test",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 10),

        const Text(
          "Remember these four items:",
          style: TextStyle(fontSize: 16),
        ),

        const SizedBox(height: 25),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: memoryItems
              .map(
                (item) => Container(
                  width: 65,
                  height: 65,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(item, style: const TextStyle(fontSize: 32)),
                ),
              )
              .toList(),
        ),

        const SizedBox(height: 30),

        const Text(
          "Which item was shown?",
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 20),

        ...memoryOptions.map((option) => buildAnswerButton(option, "⭐")),
      ],
    );
  }

  Widget buildNumberQuestion() {
    return Column(
      children: [
        const Icon(Icons.numbers, size: 55, color: Colors.blue),

        const SizedBox(height: 15),

        const Text(
          "Number Sequence",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 15),

        const Text("What number comes next?", style: TextStyle(fontSize: 17)),

        const SizedBox(height: 30),

        const Text(
          "2   →   4   →   6   →   8   →   ?",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 35),

        buildAnswerButton("9", "10"),
        buildAnswerButton("10", "10"),
        buildAnswerButton("11", "10"),
        buildAnswerButton("12", "10"),
      ],
    );
  }

  Widget buildAttentionQuestion() {
    return Column(
      children: [
        const Icon(Icons.visibility, size: 55, color: Colors.orange),

        const SizedBox(height: 15),

        const Text(
          "Attention Test",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 15),

        const Text("Select the RED circle.", style: TextStyle(fontSize: 17)),

        const SizedBox(height: 30),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            buildColorCircle(Colors.blue, "Blue"),
            buildColorCircle(Colors.red, "Red"),
            buildColorCircle(Colors.green, "Green"),
            buildColorCircle(Colors.orange, "Orange"),
          ],
        ),
      ],
    );
  }

  Widget buildColorCircle(Color color, String name) {
    return GestureDetector(
      onTap: () {
        selectAnswer(name, "Red");
      },
      child: Column(
        children: [
          CircleAvatar(radius: 32, backgroundColor: color),
          const SizedBox(height: 8),
          Text(name),
        ],
      ),
    );
  }

  Widget buildPatternQuestion() {
    return Column(
      children: [
        const Icon(Icons.extension, size: 55, color: Colors.deepPurple),

        const SizedBox(height: 15),

        const Text(
          "Pattern Recognition",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 15),

        const Text(
          "Which color should come next?",
          style: TextStyle(fontSize: 17),
        ),

        const SizedBox(height: 30),

        const Text("🔵  🔴  🔵  🔴  🔵  ?", style: TextStyle(fontSize: 35)),

        const SizedBox(height: 35),

        ...patternOptions.map((option) => buildAnswerButton(option, "🔴")),
      ],
    );
  }

  Widget buildReactionQuestion() {
    return Column(
      children: [
        const Icon(Icons.flash_on, size: 55, color: Colors.amber),

        const SizedBox(height: 15),

        const Text(
          "Reaction Test",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 15),

        Text(
          reactionStarted
              ? "TAP NOW!"
              : reactionReady
              ? "TAP!"
              : "Wait for the button to change...",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: reactionStarted ? Colors.red : Colors.grey,
          ),
        ),

        const SizedBox(height: 40),

        GestureDetector(
          onTap: reactionPressed,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: reactionStarted ? Colors.red : Colors.grey.shade400,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 15,
                ),
              ],
            ),
            child: Center(
              child: Text(
                reactionStarted ? "TAP" : "WAIT",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 30),

        if (reactionTime > 0)
          Text(
            "Reaction time: $reactionTime ms",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
      ],
    );
  }

  Widget buildAnswerButton(String answer, String correctAnswer) {
    final bool selected = selectedAnswer == answer;

    Color buttonColor = Colors.white;

    if (selected) {
      buttonColor = answer == correctAnswer
          ? Colors.green.shade100
          : Colors.red.shade100;
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton(
        onPressed: selectedAnswer == null
            ? () => selectAnswer(answer, correctAnswer)
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: Colors.black87,
          elevation: 2,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          answer,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget buildResultScreen() {
    final resultColor = getResultColor();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 25),

          CircleAvatar(
            radius: 60,
            backgroundColor: resultColor.withValues(alpha: 0.12),
            child: Icon(
              score >= 3 ? Icons.check_circle : Icons.info_outline,
              size: 70,
              color: resultColor,
            ),
          ),

          const SizedBox(height: 25),

          const Text(
            "Test Complete",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 25),

          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                children: [
                  const Text(
                    "Your Score",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "$score / 5",
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      color: resultColor,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    getResultTitle(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: resultColor,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 25),

          Card(
            color: Colors.teal.shade50,
            child: const Padding(
              padding: EdgeInsets.all(18),
              child: Column(
                children: [
                  Icon(Icons.info_outline, color: Colors.teal, size: 30),
                  SizedBox(height: 10),
                  Text(
                    "What does this mean?",
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "This score reflects performance on this short "
                    "activity only. It should not be used to diagnose "
                    "a medical or cognitive condition.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          Card(
            color: Colors.amber.shade50,
            child: const Padding(
              padding: EdgeInsets.all(18),
              child: Text(
                "If you or someone you know has persistent or worsening "
                "problems with memory, attention, thinking, or daily "
                "activities, consider discussing the concern with a "
                "qualified healthcare professional.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
            ),
          ),

          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton.icon(
              onPressed: startTest,
              icon: const Icon(Icons.refresh),
              label: const Text(
                "TAKE TEST AGAIN",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const _InfoRow({required this.icon, required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.teal, size: 30),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 3),
              Text(text, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }
}

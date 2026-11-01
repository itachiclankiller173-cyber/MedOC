import 'package:flutter/material.dart';

class HealthRiskCheckerScreen extends StatefulWidget {
  const HealthRiskCheckerScreen({super.key});

  @override
  State<HealthRiskCheckerScreen> createState() =>
      _HealthRiskCheckerScreenState();
}

class _HealthRiskCheckerScreenState extends State<HealthRiskCheckerScreen> {
  final ageController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final bpController = TextEditingController();
  final sugarController = TextEditingController();

  bool smoker = false;
  bool alcohol = false;
  bool exercise = true;

  double healthScore = 0;
  String risk = "";
  String advice = "";

  void calculateRisk() {
    double score = 100;

    int age = int.tryParse(ageController.text) ?? 0;
    double weight = double.tryParse(weightController.text) ?? 0;
    double height = (double.tryParse(heightController.text) ?? 1) / 100;

    double bmi = weight / (height * height);

    if (age > 45) score -= 10;

    if (bmi > 25) score -= 15;

    if (smoker) score -= 20;

    if (alcohol) score -= 10;

    if (!exercise) score -= 10;

    if (score < 0) score = 0;

    String level;

    if (score >= 80) {
      level = "🟢 Low Risk";
    } else if (score >= 60) {
      level = "🟡 Moderate Risk";
    } else {
      level = "🔴 High Risk";
    }

    setState(() {
      healthScore = score;
      risk = level;

      advice = """
AI Recommendations

• Drink enough water

• Exercise 30 minutes daily

• Eat more fruits & vegetables

• Maintain healthy body weight

• Schedule regular health check-ups

⚠ This assessment is for informational purposes only and is not a medical diagnosis.
""";
    });
  }

  Widget inputField(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Health Risk Checker"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            inputField("Age", ageController, Icons.person),

            inputField("Height (cm)", heightController, Icons.height),

            inputField("Weight (kg)", weightController, Icons.monitor_weight),

            inputField("Blood Pressure", bpController, Icons.favorite),

            inputField("Blood Sugar", sugarController, Icons.bloodtype),

            SwitchListTile(
              title: const Text("Smoker"),
              value: smoker,
              onChanged: (v) {
                setState(() {
                  smoker = v;
                });
              },
            ),

            SwitchListTile(
              title: const Text("Alcohol"),
              value: alcohol,
              onChanged: (v) {
                setState(() {
                  alcohol = v;
                });
              },
            ),

            SwitchListTile(
              title: const Text("Exercise Regularly"),
              value: exercise,
              onChanged: (v) {
                setState(() {
                  exercise = v;
                });
              },
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.analytics),
                label: const Text(
                  "Analyze Health",
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
                onPressed: calculateRisk,
              ),
            ),

            const SizedBox(height: 25),

            if (risk.isNotEmpty)
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text(
                        "Health Score",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 15),

                      Text(
                        "${healthScore.toStringAsFixed(0)}/100",
                        style: const TextStyle(
                          fontSize: 40,
                          color: Colors.teal,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        risk,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const Divider(height: 35),

                      Text(advice, style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

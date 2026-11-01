import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class AIDiseasePredictionScreen extends StatefulWidget {
  const AIDiseasePredictionScreen({super.key});

  @override
  State<AIDiseasePredictionScreen> createState() =>
      _AIDiseasePredictionScreenState();
}

class _AIDiseasePredictionScreenState extends State<AIDiseasePredictionScreen> {
  final TextEditingController symptomsController = TextEditingController();

  bool loading = false;

  List<String> possibleConditions = [];
  String confidence = "";
  String advice = "";
  String specialist = "";
  String emergency = "";

  final List<String> exampleSymptoms = [
    "Fever",
    "Cough",
    "Headache",
    "Body pain",
    "Sore throat",
    "Stomach pain",
  ];

  @override
  void dispose() {
    symptomsController.dispose();
    super.dispose();
  }

  void clearResults() {
    setState(() {
      symptomsController.clear();

      possibleConditions = [];
      confidence = "";
      advice = "";
      specialist = "";
      emergency = "";
    });
  }

  void addExampleSymptom(String symptom) {
    final currentText = symptomsController.text.trim();

    setState(() {
      if (currentText.isEmpty) {
        symptomsController.text = symptom;
      } else if (!currentText.toLowerCase().contains(symptom.toLowerCase())) {
        symptomsController.text = "$currentText, $symptom";
      }
    });
  }

  Future<void> predictDisease() async {
    final symptoms = symptomsController.text.trim();

    if (symptoms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your symptoms")),
      );
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      loading = true;

      possibleConditions = [];
      confidence = "";
      advice = "";
      specialist = "";
      emergency = "";
    });

    try {
      final response = await http
          .post(
            Uri.parse("${ApiConfig.baseUrl}/predict-disease"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"symptoms": symptoms}),
          )
          .timeout(const Duration(seconds: 60));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data["success"] == false) {
          throw Exception(data["error"] ?? "Prediction failed");
        }

        final conditions = data["possible_conditions"];

        setState(() {
          if (conditions is List) {
            possibleConditions = conditions
                .map((item) => item.toString())
                .toList();
          }

          confidence = data["confidence"]?.toString() ?? "Not available";

          advice =
              data["advice"]?.toString() ??
              "Please consult a healthcare professional.";

          specialist =
              data["recommended_specialist"]?.toString() ?? "General Physician";

          emergency = data["emergency"]?.toString() ?? "Unknown";
        });
      } else {
        throw Exception("Server returned ${response.statusCode}");
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Analysis error: $e"),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  bool get isEmergency {
    return emergency.trim().toLowerCase() == "yes";
  }

  Color get emergencyColor {
    if (isEmergency) {
      return Colors.red;
    }

    if (emergency.toLowerCase() == "no") {
      return Colors.green;
    }

    return Colors.orange;
  }

  Widget resultCard(
    String title,
    String value, {
    IconData icon = Icons.info,
    Color color = Colors.teal,
  }) {
    if (value.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.12),
              child: Icon(icon, color: color),
            ),

            const SizedBox(width: 14),

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

                  const SizedBox(height: 6),

                  Text(value, style: const TextStyle(fontSize: 15)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasResults =
        possibleConditions.isNotEmpty ||
        confidence.isNotEmpty ||
        advice.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Disease Prediction"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,

        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Clear",
            onPressed: loading ? null : clearResults,
          ),
        ],
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: ListView(
            children: [
              const Text(
                "Analyze Your Symptoms",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              const Text(
                "Enter your symptoms and MedOC AI will provide possible conditions for informational purposes.",
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: symptomsController,
                maxLines: 6,
                textInputAction: TextInputAction.done,

                decoration: InputDecoration(
                  labelText: "Symptoms",
                  alignLabelWithHint: true,

                  hintText: "Example:\nFever, cough, headache, body pain...",

                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 110),
                    child: Icon(Icons.health_and_safety),
                  ),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                "Quick examples:",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 8),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: exampleSymptoms.map((symptom) {
                  return ActionChip(
                    label: Text(symptom),
                    onPressed: () {
                      addExampleSymptom(symptom);
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 25),

              SizedBox(
                height: 52,

                child: ElevatedButton.icon(
                  onPressed: loading ? null : predictDisease,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),

                  icon: loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.psychology),

                  label: Text(
                    loading ? "Analyzing..." : "Analyze Symptoms",

                    style: const TextStyle(fontSize: 17),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              if (hasResults) ...[
                const Text(
                  "AI Analysis",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 15),

                // Emergency warning
                if (isEmergency)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),

                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),

                      borderRadius: BorderRadius.circular(16),

                      border: Border.all(color: Colors.red),
                    ),

                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.red,
                          size: 30,
                        ),

                        SizedBox(width: 12),

                        Expanded(
                          child: Text(
                            "Possible emergency detected. Please seek immediate medical care or contact local emergency services.",
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Possible conditions
                if (possibleConditions.isNotEmpty)
                  Card(
                    elevation: 2,

                    margin: const EdgeInsets.only(bottom: 12),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),

                    child: Padding(
                      padding: const EdgeInsets.all(16),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.medical_information,
                                color: Colors.teal,
                              ),

                              SizedBox(width: 10),

                              Text(
                                "Possible Conditions",
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          ...List.generate(possibleConditions.length, (index) {
                            return Container(
                              width: double.infinity,

                              margin: const EdgeInsets.only(bottom: 8),

                              padding: const EdgeInsets.all(12),

                              decoration: BoxDecoration(
                                color: Colors.teal.withValues(alpha: 0.06),

                                borderRadius: BorderRadius.circular(10),
                              ),

                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  CircleAvatar(
                                    radius: 12,
                                    backgroundColor: Colors.teal,

                                    child: Text(
                                      "${index + 1}",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  Expanded(
                                    child: Text(
                                      possibleConditions[index],

                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),

                resultCard(
                  "Confidence",
                  confidence,
                  icon: Icons.analytics,
                  color: Colors.blue,
                ),

                resultCard(
                  "Recommended Specialist",
                  specialist,
                  icon: Icons.local_hospital,
                  color: Colors.purple,
                ),

                resultCard(
                  "Advice",
                  advice,
                  icon: Icons.lightbulb,
                  color: Colors.orange,
                ),

                resultCard(
                  "Emergency Status",
                  emergency,
                  icon: Icons.warning,
                  color: emergencyColor,
                ),

                const SizedBox(height: 8),

                const Card(
                  color: Color(0xFFFFF3E0),

                  child: Padding(
                    padding: EdgeInsets.all(14),

                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Icon(Icons.info_outline, color: Colors.orange),

                        SizedBox(width: 10),

                        Expanded(
                          child: Text(
                            "This is an AI-generated informational assessment and not a confirmed medical diagnosis. Consult a healthcare professional for proper diagnosis.",
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

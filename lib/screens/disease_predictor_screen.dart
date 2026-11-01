import 'package:flutter/material.dart';

class DiseasePredictorScreen extends StatefulWidget {
  const DiseasePredictorScreen({super.key});

  @override
  State<DiseasePredictorScreen> createState() =>
      _DiseasePredictorScreenState();
}

class _DiseasePredictorScreenState extends State<DiseasePredictorScreen> {
  final Set<String> selectedSymptoms = {};

  List<Prediction> predictions = [];
  bool hasChecked = false;

  // Symptoms organized by category
  final Map<String, List<String>> symptomCategories = {
    "General": [
      "Fever",
      "Fatigue",
      "Chills",
      "Body Pain",
      "Weakness",
      "Loss of Appetite",
    ],
    "Respiratory": [
      "Cough",
      "Sore Throat",
      "Runny Nose",
      "Nasal Congestion",
      "Shortness of Breath",
      "Wheezing",
      "Chest Pain",
    ],
    "Head & Neurological": [
      "Headache",
      "Dizziness",
      "Loss of Smell",
      "Loss of Taste",
    ],
    "Digestive": [
      "Nausea",
      "Vomiting",
      "Diarrhea",
      "Abdominal Pain",
    ],
    "Musculoskeletal": [
      "Joint Pain",
      "Back Pain",
    ],
    "Skin": [
      "Skin Rash",
    ],
  };

  void predictDisease() {
    if (selectedSymptoms.isEmpty) {
      setState(() {
        hasChecked = true;
        predictions = [];
      });
      return;
    }

    // Urgent symptoms are handled first
    if (selectedSymptoms.contains("Chest Pain") ||
        selectedSymptoms.contains("Shortness of Breath")) {
      setState(() {
        hasChecked = true;
        predictions = [
          Prediction(
            name: "Urgent Medical Evaluation Recommended",
            score: 100,
            risk: "Urgent",
            description:
                "Chest pain or breathing difficulty can have many causes and should not be diagnosed by this app.",
            recommendations: [
              "Seek urgent medical evaluation.",
              "Do not ignore severe or worsening symptoms.",
              "Call local emergency services if symptoms are severe.",
            ],
          ),
        ];
      });
      return;
    }

    final List<DiseaseRule> diseaseRules = [
      DiseaseRule(
        name: "Influenza (Flu)",
        symptoms: {
          "Fever",
          "Cough",
          "Body Pain",
          "Fatigue",
          "Chills",
          "Headache",
        },
        minimumMatch: 3,
        risk: "Moderate",
        description:
            "A viral respiratory illness that may cause fever, cough and body aches.",
        recommendations: [
          "Rest and drink plenty of fluids.",
          "Monitor your symptoms.",
          "Consult a healthcare professional if symptoms worsen.",
        ],
      ),

      DiseaseRule(
        name: "Common Cold",
        symptoms: {
          "Cough",
          "Runny Nose",
          "Sore Throat",
          "Nasal Congestion",
          "Headache",
        },
        minimumMatch: 2,
        risk: "Low",
        description:
            "A common viral illness affecting the upper respiratory tract.",
        recommendations: [
          "Get adequate rest.",
          "Drink warm fluids.",
          "Monitor symptoms.",
        ],
      ),

      DiseaseRule(
        name: "Possible Viral Fever",
        symptoms: {
          "Fever",
          "Body Pain",
          "Fatigue",
          "Headache",
          "Weakness",
          "Chills",
        },
        minimumMatch: 2,
        risk: "Moderate",
        description:
            "Fever with general body symptoms may be caused by a viral infection.",
        recommendations: [
          "Stay hydrated.",
          "Rest adequately.",
          "Monitor your temperature.",
          "Seek medical advice if symptoms persist.",
        ],
      ),

      DiseaseRule(
        name: "Gastrointestinal Infection",
        symptoms: {
          "Nausea",
          "Vomiting",
          "Diarrhea",
          "Abdominal Pain",
          "Fever",
          "Loss of Appetite",
        },
        minimumMatch: 2,
        risk: "Moderate",
        description:
            "Digestive symptoms may be associated with an infection or irritation.",
        recommendations: [
          "Drink fluids to avoid dehydration.",
          "Eat light foods if tolerated.",
          "Seek medical care if symptoms are severe or persistent.",
        ],
      ),

      DiseaseRule(
        name: "Possible Migraine or Headache Disorder",
        symptoms: {
          "Headache",
          "Dizziness",
          "Nausea",
          "Vomiting",
        },
        minimumMatch: 2,
        risk: "Moderate",
        description:
            "Headache and related symptoms may require medical evaluation.",
        recommendations: [
          "Rest in a quiet environment.",
          "Stay hydrated.",
          "Seek medical advice for severe or unusual headaches.",
        ],
      ),

      DiseaseRule(
        name: "Possible Allergic Reaction",
        symptoms: {
          "Skin Rash",
          "Runny Nose",
          "Nasal Congestion",
          "Wheezing",
        },
        minimumMatch: 2,
        risk: "Moderate",
        description:
            "Some symptoms may be associated with an allergic reaction.",
        recommendations: [
          "Avoid possible triggers if known.",
          "Monitor symptoms carefully.",
          "Seek urgent care if breathing problems develop.",
        ],
      ),

      DiseaseRule(
        name: "Possible Joint or Musculoskeletal Condition",
        symptoms: {
          "Joint Pain",
          "Body Pain",
          "Back Pain",
          "Weakness",
        },
        minimumMatch: 2,
        risk: "Low",
        description:
            "Pain involving joints or muscles may have different causes.",
        recommendations: [
          "Rest the affected area.",
          "Avoid activities that worsen the pain.",
          "Consult a healthcare professional if pain continues.",
        ],
      ),
    ];

    List<Prediction> results = [];

    for (final rule in diseaseRules) {
      final matchedSymptoms =
          selectedSymptoms.intersection(rule.symptoms).length;

      if (matchedSymptoms >= rule.minimumMatch) {
        int score = ((matchedSymptoms / rule.symptoms.length) * 100).round();

        // Add a small boost when multiple important symptoms match
        score = score.clamp(20, 95);

        results.add(
          Prediction(
            name: rule.name,
            score: score,
            risk: rule.risk,
            description: rule.description,
            recommendations: rule.recommendations,
          ),
        );
      }
    }

    // Sort highest match first
    results.sort((a, b) => b.score.compareTo(a.score));

    setState(() {
      hasChecked = true;
      predictions = results.take(3).toList();
    });
  }

  void clearSelection() {
    setState(() {
      selectedSymptoms.clear();
      predictions.clear();
      hasChecked = false;
    });
  }

  Color getRiskColor(String risk) {
    switch (risk) {
      case "Low":
        return Colors.green;
      case "Moderate":
        return Colors.orange;
      case "High":
        return Colors.red;
      case "Urgent":
        return Colors.red.shade900;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FA),

      appBar: AppBar(
        backgroundColor: const Color(0xFF00897B),
        foregroundColor: Colors.white,
        elevation: 0,

        title: const Text(
          "MEDOC",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),

        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Reset",
            onPressed: clearSelection,
          ),
        ],
      ),

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header Card
            Container(
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF00897B),
                    Color(0xFF26A69A),
                  ],
                ),

                borderRadius: BorderRadius.circular(20),
              ),

              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.health_and_safety,
                    color: Colors.white,
                    size: 40,
                  ),

                  SizedBox(height: 12),

                  Text(
                    "AI Symptom Checker",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 6),

                  Text(
                    "Select your symptoms to receive possible health information.",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Selected counter
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Select Symptoms",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),

                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2F1),
                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: Text(
                    "${selectedSymptoms.length} Selected",
                    style: const TextStyle(
                      color: Color(0xFF00796B),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Symptom categories
            ...symptomCategories.entries.map((entry) {
              final category = entry.key;
              final categorySymptoms = entry.value;

              return Card(
                elevation: 1,
                margin: const EdgeInsets.only(bottom: 12),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),

                child: ExpansionTile(
                  initiallyExpanded: category == "General",

                  title: Text(
                    category,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),

                  children: categorySymptoms.map((symptom) {
                    return CheckboxListTile(
                      title: Text(symptom),

                      value: selectedSymptoms.contains(symptom),

                      activeColor: const Color(0xFF00897B),

                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            selectedSymptoms.add(symptom);
                          } else {
                            selectedSymptoms.remove(symptom);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              );
            }),

            const SizedBox(height: 10),

            // Predict button
            SizedBox(
              height: 55,

              child: ElevatedButton.icon(
                onPressed: predictDisease,

                icon: const Icon(Icons.psychology),

                label: const Text(
                  "Analyze Symptoms",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00897B),
                  foregroundColor: Colors.white,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // No symptom warning
            if (hasChecked && selectedSymptoms.isEmpty)
              _buildMessageCard(
                icon: Icons.info_outline,
                color: Colors.orange,
                message: "Please select at least one symptom.",
              ),

            // No matches
            if (hasChecked &&
                selectedSymptoms.isNotEmpty &&
                predictions.isEmpty)
              _buildMessageCard(
                icon: Icons.medical_services_outlined,
                color: Colors.blue,
                message:
                    "No strong match was found. A healthcare professional can provide a proper evaluation.",
              ),

            // Prediction results
            ...predictions.asMap().entries.map((entry) {
              final index = entry.key;
              final prediction = entry.value;

              return _buildPredictionCard(
                prediction,
                index + 1,
              );
            }),

            const SizedBox(height: 20),

            // Medical Disclaimer
            Container(
              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(16),
              ),

              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange,
                  ),

                  SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      "Important: MEDOC provides general health information only. "
                      "It does not diagnose diseases or replace a doctor. "
                      "If you have severe, sudden, or worsening symptoms, seek professional medical care.",
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionCard(
    Prediction prediction,
    int rank,
  ) {
    final riskColor = getRiskColor(prediction.risk);

    return Card(
      elevation: 3,

      margin: const EdgeInsets.only(bottom: 16),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),

      child: Padding(
        padding: const EdgeInsets.all(18),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rank and score
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF00897B),

                  child: Text(
                    "$rank",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    prediction.name,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Match score
            Row(
              children: [
                const Text(
                  "Symptom Match",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const Spacer(),

                Text(
                  "${prediction.score}%",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00897B),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            LinearProgressIndicator(
              value: prediction.score / 100,
              minHeight: 8,
              borderRadius: BorderRadius.circular(10),
              color: const Color(0xFF00897B),
              backgroundColor: Colors.grey.shade200,
            ),

            const SizedBox(height: 16),

            // Risk level
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 7,
              ),

              decoration: BoxDecoration(
                color: riskColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),

              child: Text(
                "Risk Level: ${prediction.risk}",
                style: TextStyle(
                  color: riskColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 14),

            Text(
              prediction.description,
              style: const TextStyle(
                fontSize: 15,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              "Recommendations",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            ...prediction.recommendations.map(
              (recommendation) => Padding(
                padding: const EdgeInsets.only(bottom: 6),

                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      size: 20,
                      color: Color(0xFF00897B),
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: Text(
                        recommendation,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageCard({
    required IconData icon,
    required Color color,
    required String message,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 30,
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Disease matching rule
class DiseaseRule {
  final String name;
  final Set<String> symptoms;
  final int minimumMatch;
  final String risk;
  final String description;
  final List<String> recommendations;

  DiseaseRule({
    required this.name,
    required this.symptoms,
    required this.minimumMatch,
    required this.risk,
    required this.description,
    required this.recommendations,
  });
}

// Prediction result
class Prediction {
  final String name;
  final int score;
  final String risk;
  final String description;
  final List<String> recommendations;

  Prediction({
    required this.name,
    required this.score,
    required this.risk,
    required this.description,
    required this.recommendations,
  });
}
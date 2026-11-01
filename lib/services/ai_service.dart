import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  // Real Android phone
final String baseUrl = "http://192.168.1.5:8000";

  // ==========================================================
  // HEALTH SUMMARY
  // ==========================================================

  Future<String> getHealthSummary({
    required String name,
    required String heartRate,
    required String bloodPressure,
    required String oxygen,
    required String temperature,
    required String sleep,
    required String water,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/chat"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "message":
              """
Patient Name: $name

Heart Rate: $heartRate

Blood Pressure: $bloodPressure

SpO₂: $oxygen

Temperature: $temperature

Sleep: $sleep hours

Water Intake: $water litres

Give a short healthcare summary and health suggestions.
""",
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["reply"] ?? "No AI response";
      }

      return "AI Server Error (${response.statusCode})\n${response.body}";
    } catch (e) {
      return "Connection Error:\n$e";
    }
  }

  // ==========================================================
  // MEDICAL REPORT ANALYZER
  // ==========================================================

  Future<String> analyzeMedicalReport(String reportText) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/chat"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "message":
              """
You are MedOC AI.

Analyze this medical report.

Explain in simple language.

Include:

1. Important findings
2. Abnormal values
3. Possible meaning
4. Health suggestions
5. Whether the patient should consult a doctor

Medical Report:

$reportText
""",
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["reply"] ?? "No AI response";
      }

      return "AI Server Error (${response.statusCode})\n${response.body}";
    } catch (e) {
      return "Connection Error:\n$e";
    }
  }

  // ==========================================================
  // DISEASE PREDICTION
  // ==========================================================

  Future<Map<String, dynamic>> predictDisease(String symptoms) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/predict-disease"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"symptoms": symptoms}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return {"error": "Server Error (${response.statusCode})"};
    } catch (e) {
      return {"error": e.toString()};
    }
  }

  // ==========================================================
  // AI GAIT ANALYSIS
  // ==========================================================
  Future<String> analyzeInjuryImage(String imagePath) async {
    try {
      final request = http.MultipartRequest(
        "POST",
        Uri.parse("$baseUrl/analyze-injury"),
      );

      request.files.add(await http.MultipartFile.fromPath("image", imagePath));

      final response = await request.send();

      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);

        if (data["success"] == true) {
          final assessment = data["assessment"];

          return assessment?["description"] ?? "Image received successfully.";
        }

        return data["error"] ?? "Unable to analyze image.";
      }

      return "AI Server Error (${response.statusCode})";
    } catch (e) {
      return "Connection Error:\n$e";
    }
  }

  Future<String> analyzeGait({
    required int score,
    required String balance,
    required bool stableWalking,
    required bool normalStepLength,
    required bool symmetricalSteps,
    required bool normalFootPlacement,
    required bool normalArmSwing,
    required bool noDraggingFeet,
    required bool noLimping,
    required bool normalTurning,
    required bool pain,
    required bool dizziness,
    required bool weakness,
    required bool numbness,
    String notes = "",
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/gait-analysis"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "score": score,
          "balance": balance,
          "stable_walking": stableWalking,
          "normal_step_length": normalStepLength,
          "symmetrical_steps": symmetricalSteps,
          "normal_foot_placement": normalFootPlacement,
          "normal_arm_swing": normalArmSwing,
          "no_dragging_feet": noDraggingFeet,
          "no_limping": noLimping,
          "normal_turning": normalTurning,
          "pain": pain,
          "dizziness": dizziness,
          "weakness": weakness,
          "numbness": numbness,
          "notes": notes,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return data["reply"] ?? "No gait analysis response";
      }

      return "AI Server Error (${response.statusCode})\n${response.body}";
    } catch (e) {
      return "Connection Error:\n$e";
    }
  }
}

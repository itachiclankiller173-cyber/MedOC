import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/health_ai_service.dart';
import '../services/patient_service.dart';

class AIHealthSummary extends StatefulWidget {
  final String heartRate;
  final String oxygen;
  final String bloodPressure;
  final String sleep;
  final String hydration;

  const AIHealthSummary({
    super.key,
    required this.heartRate,
    required this.oxygen,
    required this.bloodPressure,
    required this.sleep,
    required this.hydration,
  });

  @override
  State<AIHealthSummary> createState() => _AIHealthSummaryState();
}

class _AIHealthSummaryState extends State<AIHealthSummary> {
  String? patientId;
  String patientName = "";

  @override
  void initState() {
    super.initState();
    _saveSummaryForPatient();
  }

  Future<void> _saveSummaryForPatient() async {
    final patient = await PatientService().getSelectedPatient();

    if (patient == null) return;

    final ai = HealthAIService();

    final result = ai.analyze(
      heartRate: widget.heartRate,
      oxygen: widget.oxygen,
      bloodPressure: widget.bloodPressure,
      sleep: widget.sleep,
      hydration: widget.hydration,
    );

    final prefs = await SharedPreferences.getInstance();

    final summaryData = {
      "patientId": patient.id,
      "patientName": patient.name,
      "heartRate": widget.heartRate,
      "oxygen": widget.oxygen,
      "bloodPressure": widget.bloodPressure,
      "sleep": widget.sleep,
      "hydration": widget.hydration,
      "summary": result,
      "updatedAt": DateTime.now().toIso8601String(),
    };

    await prefs.setString("ai_summary_${patient.id}", jsonEncode(summaryData));

    patientId = patient.id;
    patientName = patient.name;
  }

  @override
  Widget build(BuildContext context) {
    final ai = HealthAIService();

    final result = ai.analyze(
      heartRate: widget.heartRate,
      oxygen: widget.oxygen,
      bloodPressure: widget.bloodPressure,
      sleep: widget.sleep,
      hydration: widget.hydration,
    );

    final bool hasWarning = !result.startsWith(
      "Your entered health parameters look",
    );

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.smart_toy, color: Colors.teal),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    "MedOC AI Health Summary",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),

            if (patientName.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                "Patient: $patientName",
                style: const TextStyle(
                  color: Colors.teal,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],

            const SizedBox(height: 15),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  hasWarning ? Icons.warning_amber_rounded : Icons.check_circle,
                  color: hasWarning ? Colors.orange : Colors.green,
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    result,
                    style: const TextStyle(fontSize: 15, height: 1.5),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            const Text(
              "Note: This summary is for general health monitoring and "
              "does not replace professional medical advice.",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

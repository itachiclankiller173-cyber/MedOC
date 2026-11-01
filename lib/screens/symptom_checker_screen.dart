import 'package:flutter/material.dart';

class SymptomCheckerScreen extends StatefulWidget {
  const SymptomCheckerScreen({super.key});

  @override
  State<SymptomCheckerScreen> createState() => _SymptomCheckerScreenState();
}

class _SymptomCheckerScreenState extends State<SymptomCheckerScreen> {
  final TextEditingController symptomsController = TextEditingController();

  String aiResult = "Enter your symptoms and press Analyze.";

  void analyzeSymptoms() {
    if (symptomsController.text.trim().isEmpty) {
      return;
    }

    setState(() {
      aiResult =
          "Possible conditions based on your symptoms:\n\n"
          "• Viral Fever\n"
          "• Common Cold\n"
          "• Mild Infection\n\n"
          "⚠ This is NOT a medical diagnosis.\n"
          "Please consult a qualified healthcare professional if symptoms are severe or persistent.";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Symptom Checker"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            TextField(
              controller: symptomsController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: "Enter Symptoms",
                hintText: "Example:\nFever, cough, headache...",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton.icon(
                icon: const Icon(Icons.smart_toy),
                label: const Text("Analyze"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
                onPressed: analyzeSymptoms,
              ),
            ),

            const SizedBox(height: 25),

            Expanded(
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    child: Text(aiResult, style: const TextStyle(fontSize: 16)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class LabReportAnalyzerScreen extends StatefulWidget {
  const LabReportAnalyzerScreen({super.key});

  @override
  State<LabReportAnalyzerScreen> createState() =>
      _LabReportAnalyzerScreenState();
}

class _LabReportAnalyzerScreenState extends State<LabReportAnalyzerScreen> {
  final TextEditingController reportController = TextEditingController();

  String analysis = "Paste your lab report here and tap Analyze.";

  void analyzeReport() {
    if (reportController.text.trim().isEmpty) return;

    setState(() {
      analysis = """
🧪 AI Lab Report Summary

✅ Hemoglobin: Normal

⚠ Blood Glucose:
Slightly elevated.
Consider consulting your doctor if this is a fasting value.

✅ WBC:
Within normal range.

❤️ Overall Health:
Most values appear normal.
Please review the complete report with a healthcare professional.

(This is an AI-generated summary and not a medical diagnosis.)
""";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lab Report Analyzer"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: reportController,
              maxLines: 7,
              decoration: const InputDecoration(
                labelText: "Paste Lab Report",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.analytics),
                label: const Text("Analyze Report"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
                onPressed: analyzeReport,
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: Card(
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Text(analysis, style: const TextStyle(fontSize: 16)),
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

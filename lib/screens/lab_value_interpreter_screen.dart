import 'package:flutter/material.dart';

class LabValueInterpreterScreen extends StatefulWidget {
  const LabValueInterpreterScreen({super.key});

  @override
  State<LabValueInterpreterScreen> createState() =>
      _LabValueInterpreterScreenState();
}

class _LabValueInterpreterScreenState extends State<LabValueInterpreterScreen> {
  final hbController = TextEditingController();
  final sugarController = TextEditingController();
  final wbcController = TextEditingController();
  final plateletController = TextEditingController();
  final creatinineController = TextEditingController();

  String result = "";

  void analyzeValues() {
    double hb = double.tryParse(hbController.text) ?? 0;
    double sugar = double.tryParse(sugarController.text) ?? 0;
    double wbc = double.tryParse(wbcController.text) ?? 0;
    double platelets = double.tryParse(plateletController.text) ?? 0;
    double creatinine = double.tryParse(creatinineController.text) ?? 0;

    String report = "🧪 Lab Value Interpretation\n\n";

    // Hemoglobin
    if (hb == 0) {
      report += "Hemoglobin: Not entered\n\n";
    } else if (hb < 12) {
      report += "Hemoglobin: LOW\nPossible anemia.\n\n";
    } else if (hb > 17) {
      report += "Hemoglobin: HIGH\nNeeds medical evaluation.\n\n";
    } else {
      report += "Hemoglobin: NORMAL\n\n";
    }

    // Blood Sugar
    if (sugar == 0) {
      report += "Blood Sugar: Not entered\n\n";
    } else if (sugar < 70) {
      report += "Blood Sugar: LOW\nPossible hypoglycemia.\n\n";
    } else if (sugar > 140) {
      report +=
          "Blood Sugar: HIGH\nMay indicate diabetes or poor sugar control.\n\n";
    } else {
      report += "Blood Sugar: NORMAL\n\n";
    }

    // WBC
    if (wbc == 0) {
      report += "WBC: Not entered\n\n";
    } else if (wbc < 4000) {
      report += "WBC: LOW\nConsult your doctor.\n\n";
    } else if (wbc > 11000) {
      report += "WBC: HIGH\nMay indicate infection or inflammation.\n\n";
    } else {
      report += "WBC: NORMAL\n\n";
    }

    // Platelets
    if (platelets == 0) {
      report += "Platelets: Not entered\n\n";
    } else if (platelets < 150000) {
      report += "Platelets: LOW\nRisk of bleeding may be increased.\n\n";
    } else if (platelets > 450000) {
      report += "Platelets: HIGH\nNeeds medical review.\n\n";
    } else {
      report += "Platelets: NORMAL\n\n";
    }

    // Creatinine
    if (creatinine == 0) {
      report += "Creatinine: Not entered\n\n";
    } else if (creatinine > 1.3) {
      report += "Creatinine: HIGH\nKidney function may require evaluation.\n\n";
    } else {
      report += "Creatinine: NORMAL\n\n";
    }

    report +=
        "⚠ This interpretation is for educational purposes only and is NOT a medical diagnosis.\nPlease consult a qualified healthcare professional for medical advice.";

    setState(() {
      result = report;
    });
  }

  Widget buildField(
    String title,
    TextEditingController controller,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: title,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lab Value Interpreter"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  buildField(
                    "Hemoglobin (g/dL)",
                    hbController,
                    Icons.bloodtype,
                  ),

                  buildField(
                    "Blood Sugar (mg/dL)",
                    sugarController,
                    Icons.water_drop,
                  ),

                  buildField("WBC (/µL)", wbcController, Icons.science),

                  buildField(
                    "Platelets (/µL)",
                    plateletController,
                    Icons.medical_services,
                  ),

                  buildField(
                    "Creatinine (mg/dL)",
                    creatinineController,
                    Icons.monitor_heart,
                  ),

                  const SizedBox(height: 10),

                  ElevatedButton(
                    onPressed: analyzeValues,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      "Analyze",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),

                  const SizedBox(height: 20),

                  if (result.isNotEmpty)
                    Card(
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          result,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class MedicineCheckerScreen extends StatefulWidget {
  const MedicineCheckerScreen({super.key});

  @override
  State<MedicineCheckerScreen> createState() => _MedicineCheckerScreenState();
}

class _MedicineCheckerScreenState extends State<MedicineCheckerScreen> {
  final TextEditingController medicineController = TextEditingController();

  String result = "";

  void analyzeMedicine() {
    if (medicineController.text.isEmpty) return;

    setState(() {
      result =
          """
Medicine: ${medicineController.text}

Purpose
Pain relief / Fever reduction (Demo)

Common Side Effects
• Nausea
• Dizziness
• Headache

Precautions
• Take after food.
• Drink plenty of water.
• Follow your doctor's advice.

AI Note
This is only a demonstration. Always consult your doctor or pharmacist before taking any medicine.
""";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Medicine Checker"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            TextField(
              controller: medicineController,
              decoration: InputDecoration(
                labelText: "Enter Medicine Name",
                prefixIcon: const Icon(Icons.medication),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: analyzeMedicine,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Analyze"),
              ),
            ),

            const SizedBox(height: 20),

            if (result.isNotEmpty)
              Expanded(
                child: Card(
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      child: Text(result, style: const TextStyle(fontSize: 16)),
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

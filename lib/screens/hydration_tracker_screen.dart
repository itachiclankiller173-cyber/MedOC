import 'package:flutter/material.dart';

import '../services/firestore_service.dart';
import '../services/patient_service.dart';

class HydrationTrackerScreen extends StatefulWidget {
  const HydrationTrackerScreen({super.key});

  @override
  State<HydrationTrackerScreen> createState() => _HydrationTrackerScreenState();
}

class _HydrationTrackerScreenState extends State<HydrationTrackerScreen> {
  final FirestoreService firestore = FirestoreService();

  final intakeController = TextEditingController();
  final goalController = TextEditingController();

  String patientId = "";

  bool loading = true;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  void dispose() {
    intakeController.dispose();
    goalController.dispose();
    super.dispose();
  }

  Future<void> initialize() async {
    final patient = await PatientService().getSelectedPatient();

    if (patient == null) {
      setState(() {
        loading = false;
      });
      return;
    }

    patientId = patient.id;

    await loadHydration();
  }

  Future<void> loadHydration() async {
    try {
      final doc = await firestore.getHydration(patientId);

      if (doc.exists) {
        final data = doc.data()!;

        intakeController.text = data["waterIntake"] ?? "";
        goalController.text = data["goal"] ?? "";
      }
    } catch (_) {}

    setState(() {
      loading = false;
    });
  }

  Future<void> saveHydration() async {
    if (patientId.isEmpty) return;

    await firestore.saveHydration(
      patientId: patientId,
      waterIntake: intakeController.text,
      goal: goalController.text,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Hydration Data Saved")));

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Hydration Tracker"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.water_drop, size: 90, color: Colors.blue),

            const SizedBox(height: 25),

            TextField(
              controller: intakeController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: "Water Intake Today (Litres)",
                prefixIcon: Icon(Icons.local_drink),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 18),

            TextField(
              controller: goalController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: "Daily Goal (Litres)",
                prefixIcon: Icon(Icons.flag),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: saveHydration,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  "SAVE HYDRATION",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 25),

            Card(
              elevation: 4,
              child: ListTile(
                leading: const Icon(Icons.water_drop, color: Colors.blue),
                title: const Text("Today's Hydration"),
                subtitle: Text(
                  "${intakeController.text.isEmpty ? "0" : intakeController.text} L / "
                  "${goalController.text.isEmpty ? "0" : goalController.text} L",
                ),
              ),
            ),

            const SizedBox(height: 20),

            Card(
              elevation: 4,
              child: ListTile(
                leading: const Icon(Icons.smart_toy, color: Colors.teal),
                title: const Text("Future AI Feature"),
                subtitle: const Text(
                  "MedOC AI will analyze your hydration level and recommend daily water intake based on age, weight and weather.",
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

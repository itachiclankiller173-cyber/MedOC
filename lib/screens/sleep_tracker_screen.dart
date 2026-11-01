import 'package:flutter/material.dart';

import '../services/firestore_service.dart';
import '../services/patient_service.dart';

class SleepTrackerScreen extends StatefulWidget {
  const SleepTrackerScreen({super.key});

  @override
  State<SleepTrackerScreen> createState() => _SleepTrackerScreenState();
}

class _SleepTrackerScreenState extends State<SleepTrackerScreen> {
  final FirestoreService firestore = FirestoreService();

  final hoursController = TextEditingController();
  final bedController = TextEditingController();
  final wakeController = TextEditingController();

  String quality = "Good";
  String patientId = "";

  bool loading = true;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  void dispose() {
    hoursController.dispose();
    bedController.dispose();
    wakeController.dispose();
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

    await loadSleep();
  }

  Future<void> loadSleep() async {
    try {
      final doc = await firestore.getSleep(patientId);

      if (doc.exists) {
        final data = doc.data()!;

        hoursController.text = data["sleepHours"] ?? "";
        bedController.text = data["bedTime"] ?? "";
        wakeController.text = data["wakeUpTime"] ?? "";
        quality = data["quality"] ?? "Good";
      }
    } catch (_) {}

    setState(() {
      loading = false;
    });
  }

  Future<void> saveSleep() async {
    if (patientId.isEmpty) return;

    await firestore.saveSleep(
      patientId: patientId,
      sleepHours: hoursController.text,
      bedTime: bedController.text,
      wakeUpTime: wakeController.text,
      quality: quality,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Sleep Data Saved")));
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Sleep Tracker"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.bedtime, size: 90, color: Colors.teal),

            const SizedBox(height: 25),

            TextField(
              controller: hoursController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: "Sleep Duration (Hours)",
                prefixIcon: Icon(Icons.schedule),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 18),

            TextField(
              controller: bedController,
              decoration: const InputDecoration(
                labelText: "Bed Time (Ex: 10:30 PM)",
                prefixIcon: Icon(Icons.nightlight_round),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 18),

            TextField(
              controller: wakeController,
              decoration: const InputDecoration(
                labelText: "Wake-up Time (Ex: 6:30 AM)",
                prefixIcon: Icon(Icons.wb_sunny),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 18),

            DropdownButtonFormField<String>(
              initialValue: quality,
              decoration: const InputDecoration(
                labelText: "Sleep Quality",
                prefixIcon: Icon(Icons.star),
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: "Excellent", child: Text("Excellent")),
                DropdownMenuItem(value: "Good", child: Text("Good")),
                DropdownMenuItem(value: "Average", child: Text("Average")),
                DropdownMenuItem(value: "Poor", child: Text("Poor")),
              ],
              onChanged: (value) {
                setState(() {
                  quality = value!;
                });
              },
            ),

            const SizedBox(height: 35),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: saveSleep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  "SAVE SLEEP DATA",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                  "MedOC AI will analyze your sleep pattern and provide health suggestions.",
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

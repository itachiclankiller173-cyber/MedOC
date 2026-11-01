import 'package:flutter/material.dart';

import '../services/firestore_service.dart';
import '../services/patient_service.dart';

class VitalSignsScreen extends StatefulWidget {
  const VitalSignsScreen({super.key});

  @override
  State<VitalSignsScreen> createState() => _VitalSignsScreenState();
}

class _VitalSignsScreenState extends State<VitalSignsScreen> {
  final FirestoreService firestore = FirestoreService();

  final heartController = TextEditingController();
  final bpController = TextEditingController();
  final oxygenController = TextEditingController();
  final temperatureController = TextEditingController();

  String patientId = "";

  bool loading = true;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  void dispose() {
    heartController.dispose();
    bpController.dispose();
    oxygenController.dispose();
    temperatureController.dispose();
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

    await loadVitals();
  }

  Future<void> loadVitals() async {
    try {
      final doc = await firestore.getVitalSigns(patientId);

      if (doc.exists) {
        final data = doc.data()!;

        heartController.text = data["heartRate"] ?? "";
        bpController.text = data["bloodPressure"] ?? "";
        oxygenController.text = data["oxygen"] ?? "";
        temperatureController.text = data["temperature"] ?? "";
      }
    } catch (_) {}

    setState(() {
      loading = false;
    });
  }

 Future<void> saveVitals() async {
  if (patientId.isEmpty) return;

  await firestore.saveVitalSigns(
    patientId: patientId,
    heartRate: heartController.text,
    bloodPressure: bpController.text,
    oxygen: oxygenController.text,
    temperature: temperatureController.text,
  );

  await firestore.saveVitalHistory(
    patientId: patientId,
    heartRate: heartController.text,
    bloodPressure: bpController.text,
    oxygen: oxygenController.text,
    temperature: temperatureController.text,
  );

  if (!mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("Vital Signs Saved and added to health history"),
    ),
  );
}
  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Vital Signs"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.monitor_heart, size: 90, color: Colors.teal),

            const SizedBox(height: 25),

            TextField(
              controller: heartController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Heart Rate (BPM)",
                prefixIcon: Icon(Icons.favorite),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 18),

            TextField(
              controller: bpController,
              decoration: const InputDecoration(
                labelText: "Blood Pressure (120/80)",
                prefixIcon: Icon(Icons.bloodtype),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 18),

            TextField(
              controller: oxygenController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "SpO₂ (%)",
                prefixIcon: Icon(Icons.air),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 18),

            TextField(
              controller: temperatureController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: "Temperature (°C)",
                prefixIcon: Icon(Icons.thermostat),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 35),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: saveVitals,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  "SAVE VITAL SIGNS",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Card(
              elevation: 4,
              child: ListTile(
                leading: const Icon(Icons.info, color: Colors.teal),
                title: const Text("Future ESP32 Integration"),
                subtitle: const Text(
                  "Later, these fields will be filled automatically from ESP32 sensors instead of manual entry.",
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

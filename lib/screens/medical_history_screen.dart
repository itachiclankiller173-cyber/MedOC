import 'package:flutter/material.dart';

import '../services/firestore_service.dart';
import '../services/patient_service.dart';

class MedicalHistoryScreen extends StatefulWidget {
  final String patientId;

  const MedicalHistoryScreen({super.key, required this.patientId});
  @override
  State<MedicalHistoryScreen> createState() => _MedicalHistoryScreenState();
}

class _MedicalHistoryScreenState extends State<MedicalHistoryScreen> {
  final FirestoreService firestore = FirestoreService();

  final diseaseController = TextEditingController();
  final allergyController = TextEditingController();
  final surgeryController = TextEditingController();
  final medicineController = TextEditingController();
  final familyController = TextEditingController();

  bool loading = true;
  String patientId = "";

  @override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  void dispose() {
    diseaseController.dispose();
    allergyController.dispose();
    surgeryController.dispose();
    medicineController.dispose();
    familyController.dispose();
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

    await loadHistory();
  }

  Future<void> loadHistory() async {
    try {
      final doc = await firestore.getMedicalHistory(patientId);

      if (doc.exists) {
        final data = doc.data()!;

        diseaseController.text = data["diseases"] ?? "";
        allergyController.text = data["allergies"] ?? "";
        surgeryController.text = data["surgeries"] ?? "";
        medicineController.text = data["medications"] ?? "";
        familyController.text = data["familyHistory"] ?? "";
      }
    } catch (_) {}

    setState(() {
      loading = false;
    });
  }

  Future<void> saveHistory() async {
    if (patientId.isEmpty) return;

    await firestore.saveMedicalHistory(
      patientId: patientId,
      diseases: diseaseController.text,
      allergies: allergyController.text,
      surgeries: surgeryController.text,
      medications: medicineController.text,
      familyHistory: familyController.text,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Medical History Saved")));
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (patientId.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Medical History"),
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: Text("Please select a patient first.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Medical History"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: diseaseController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: "Previous Diseases",
                prefixIcon: Icon(Icons.healing),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: allergyController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: "Allergies",
                prefixIcon: Icon(Icons.warning_amber),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: surgeryController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: "Previous Surgeries",
                prefixIcon: Icon(Icons.local_hospital),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: medicineController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: "Current Medicines",
                prefixIcon: Icon(Icons.medication),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: familyController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: "Family Medical History",
                prefixIcon: Icon(Icons.family_restroom),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: saveHistory,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  "SAVE MEDICAL HISTORY",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

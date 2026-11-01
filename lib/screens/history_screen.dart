import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/patient.dart';
import '../services/patient_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final illnessController = TextEditingController();
  final medicineController = TextEditingController();
  final allergyController = TextEditingController();
  final reportController = TextEditingController();

  final heartController = TextEditingController();
  final spo2Controller = TextEditingController();
  final tempController = TextEditingController();
  final bpController = TextEditingController();

  Patient? selectedPatient;

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadPatientAndHistory();
  }

  @override
  void dispose() {
    illnessController.dispose();
    medicineController.dispose();
    allergyController.dispose();
    reportController.dispose();
    heartController.dispose();
    spo2Controller.dispose();
    tempController.dispose();
    bpController.dispose();
    super.dispose();
  }

  // =====================================================
  // LOAD SELECTED PATIENT + HISTORY
  // =====================================================

  Future<void> loadPatientAndHistory() async {
    selectedPatient = await PatientService().getSelectedPatient();

    if (selectedPatient != null) {
      await loadHistory();
    }

    if (!mounted) return;

    setState(() {
      loading = false;
    });
  }

  // =====================================================
  // CREATE UNIQUE KEY FOR EACH PATIENT
  // =====================================================

  String _key(String field) {
    return "${field}_${selectedPatient!.id}";
  }

  // =====================================================
  // SAVE HISTORY
  // =====================================================

  Future<void> saveHistory() async {
    if (selectedPatient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a patient first")),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_key("illness"), illnessController.text.trim());

    await prefs.setString(_key("medicine"), medicineController.text.trim());

    await prefs.setString(_key("allergy"), allergyController.text.trim());

    await prefs.setString(_key("report"), reportController.text.trim());

    await prefs.setString(_key("heart"), heartController.text.trim());

    await prefs.setString(_key("oxygen"), spo2Controller.text.trim());

    await prefs.setString(_key("temperature"), tempController.text.trim());

    await prefs.setString(_key("bloodPressure"), bpController.text.trim());

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Medical history saved for ${selectedPatient!.name}"),
      ),
    );
  }

  // =====================================================
  // LOAD HISTORY FOR SELECTED PATIENT
  // =====================================================

  Future<void> loadHistory() async {
    if (selectedPatient == null) return;

    final prefs = await SharedPreferences.getInstance();

    illnessController.text = prefs.getString(_key("illness")) ?? "";

    medicineController.text = prefs.getString(_key("medicine")) ?? "";

    allergyController.text = prefs.getString(_key("allergy")) ?? "";

    reportController.text = prefs.getString(_key("report")) ?? "";

    heartController.text = prefs.getString(_key("heart")) ?? "";

    spo2Controller.text = prefs.getString(_key("oxygen")) ?? "";

    tempController.text = prefs.getString(_key("temperature")) ?? "";

    bpController.text = prefs.getString(_key("bloodPressure")) ?? "";
  }

  // =====================================================
  // INPUT BOX
  // =====================================================

  Widget inputBox(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return TextField(
      controller: controller,
      maxLines: 2,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  // =====================================================
  // UI
  // =====================================================

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (selectedPatient == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Medical History"),
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text(
            "No patient selected.\nPlease select a patient first.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Medical History"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            // SELECTED PATIENT
            Card(
              color: Colors.teal.shade50,
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  child: Icon(Icons.person),
                ),
                title: Text(
                  selectedPatient!.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text("Selected Patient"),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Medical Records",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            inputBox(
              "Previous Illness",
              illnessController,
              Icons.health_and_safety,
            ),

            const SizedBox(height: 15),

            inputBox("Medicines", medicineController, Icons.medication),

            const SizedBox(height: 15),

            inputBox("Allergies", allergyController, Icons.warning),

            const SizedBox(height: 15),

            inputBox("Reports / Notes", reportController, Icons.description),

            const SizedBox(height: 25),

            const Text(
              "Vital History",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            inputBox("Heart Rate", heartController, Icons.favorite),

            const SizedBox(height: 15),

            inputBox("SpO₂", spo2Controller, Icons.monitor_heart),

            const SizedBox(height: 15),

            inputBox("Temperature", tempController, Icons.thermostat),

            const SizedBox(height: 15),

            inputBox("Blood Pressure", bpController, Icons.bloodtype),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: saveHistory,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
                child: const Text("SAVE HISTORY"),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

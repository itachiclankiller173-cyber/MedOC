import 'package:flutter/material.dart';

import '../models/patient.dart';
import '../services/firestore_service.dart';
import '../services/patient_service.dart';
import 'patient_profile_screen.dart';

class PatientSelectionScreen extends StatefulWidget {
  const PatientSelectionScreen({super.key});

  @override
  State<PatientSelectionScreen> createState() => _PatientSelectionScreenState();
}

class _PatientSelectionScreenState extends State<PatientSelectionScreen> {
  final FirestoreService firestore = FirestoreService();
  final PatientService patientService = PatientService();

  String? selectedPatientId;

  @override
  void initState() {
    super.initState();
    _loadSelectedPatient();
  }

  Future<void> _loadSelectedPatient() async {
    final patient = await patientService.getSelectedPatient();

    if (!mounted) return;

    setState(() {
      selectedPatientId = patient?.id;
    });
  }

  Future<void> _selectPatient(Patient patient) async {
    try {
      final patients = await patientService.loadPatients();

      final exists = patients.any((p) => p.id == patient.id);

      if (exists) {
        await patientService.updatePatient(patient);
      } else {
        await patientService.addPatient(patient);
      }

      // IMPORTANT: Set the active patient
      await patientService.setSelectedPatient(patient.id);

      // Verify that the patient was saved
      final selectedPatient = await patientService.getSelectedPatient();

      debugPrint("SELECTED PATIENT: ${selectedPatient?.name}");

      debugPrint("SELECTED PATIENT ID: ${selectedPatient?.id}");

      if (selectedPatient == null) {
        throw Exception("Failed to select patient");
      }

      if (!mounted) return;

      setState(() {
        selectedPatientId = patient.id;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${patient.name} selected successfully")),
      );

      // Small delay so the selected patient is definitely saved
      await Future.delayed(const Duration(milliseconds: 300));

      if (!mounted) return;

      Navigator.pop(context, patient);
    } catch (e) {
      debugPrint("PATIENT SELECTION ERROR: $e");

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error selecting patient: $e")));
    }
  }

  Future<void> _addNewPatient() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PatientProfileScreen(addNew: true),
      ),
    );

    // If a newly created patient is returned,
    // automatically select it.
    if (result is Patient) {
      await _selectPatient(result);
      return;
    }

    // Refresh patient list
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Patients"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add),
        label: const Text("Add New Patient"),
        onPressed: _addNewPatient,
      ),

      body: StreamBuilder(
        stream: firestore.getPatients(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final patients = snapshot.data!.docs;

          if (patients.isEmpty) {
            return Center(
              child: ElevatedButton.icon(
                onPressed: _addNewPatient,
                icon: const Icon(Icons.person_add),
                label: const Text("Add First Patient"),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              // CURRENT PATIENT
              if (selectedPatientId != null)
                Card(
                  color: Colors.teal.shade50,
                  child: const ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      child: Icon(Icons.check),
                    ),
                    title: Text(
                      "Active patient selected",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "Reports, history and health data will use this patient",
                    ),
                  ),
                ),

              const SizedBox(height: 10),

              // ADD NEW PATIENT
              Card(
                color: Colors.teal.shade50,
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    child: Icon(Icons.person_add),
                  ),
                  title: const Text(
                    "Add New Patient",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text("Add another patient to your account"),
                  trailing: const Icon(Icons.add),
                  onTap: _addNewPatient,
                ),
              ),

              const SizedBox(height: 10),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Text(
                  "Your Patients",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),

              ...patients.map((doc) {
                final data = doc.data();

                final patient = Patient(
                  id: doc.id,
                  name: data["name"] ?? "",
                  age: data["age"] ?? "",
                  gender: data["gender"] ?? "Male",
                  phone: data["phone"] ?? "",
                  bloodGroup: data["blood"] ?? data["bloodGroup"] ?? "",
                  relationship: data["relationship"] ?? "",
                );

                final isSelected = patient.id == selectedPatientId;

                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isSelected
                          ? Colors.teal
                          : Colors.teal.shade100,
                      child: Icon(
                        isSelected ? Icons.check : Icons.person,
                        color: isSelected ? Colors.white : Colors.teal,
                      ),
                    ),

                    title: Text(
                      patient.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),

                    subtitle: Text(
                      "Age: ${patient.age} • ${patient.relationship}",
                    ),

                    trailing: isSelected
                        ? const Chip(label: Text("Active"))
                        : const Icon(Icons.arrow_forward_ios),

                    onTap: () => _selectPatient(patient),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../models/patient.dart';
import '../services/patient_service.dart';
import 'add_patient_screen.dart';
import 'patient_profile_screen.dart';

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  final PatientService patientService = PatientService();

  List<Patient> patients = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadPatients();
  }

  Future<void> loadPatients() async {
    patients = await patientService.loadPatients();

    setState(() {
      loading = false;
    });
  }

  Future<void> addPatient() async {
    final Patient? patient = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddPatientScreen()),
    );

    if (patient != null) {
      await patientService.addPatient(patient);
      loadPatients();
    }
  }

  Future<void> deletePatient(Patient patient) async {
    await patientService.deletePatient(patient.id);

    loadPatients();

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("${patient.name} deleted")));
  }

  Future<void> selectPatient(Patient patient) async {
    await patientService.setSelectedPatient(patient.id);

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PatientProfileScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Patients"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: addPatient,
        child: const Icon(Icons.add),
      ),

      body: patients.isEmpty
          ? const Center(
              child: Text(
                "No Patients Added",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            )
          : ListView.builder(
              itemCount: patients.length,
              itemBuilder: (context, index) {
                final patient = patients[index];

                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.teal,
                      radius: 28,
                      child: Text(
                        patient.name.isNotEmpty
                            ? patient.name[0].toUpperCase()
                            : "?",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    ),

                    title: Text(
                      patient.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),

                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Age : ${patient.age}"),
                        Text("Gender : ${patient.gender}"),
                        Text("Blood Group : ${patient.bloodGroup}"),
                        Text("Relationship : ${patient.relationship}"),
                      ],
                    ),

                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == "delete") {
                          deletePatient(patient);
                        } else {
                          selectPatient(patient);
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: "open", child: Text("Open")),
                        PopupMenuItem(value: "delete", child: Text("Delete")),
                      ],
                    ),

                    onTap: () => selectPatient(patient),
                  ),
                );
              },
            ),
    );
  }
}

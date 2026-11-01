import 'package:flutter/material.dart';

import '../models/patient.dart';
import '../services/firestore_service.dart';
import '../services/patient_service.dart';

class PatientProfileScreen extends StatefulWidget {
  final bool addNew;

  const PatientProfileScreen({super.key, this.addNew = false});

  @override
  State<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {
  final FirestoreService firestore = FirestoreService();

  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final phoneController = TextEditingController();
  final bloodController = TextEditingController();
  final relationshipController = TextEditingController();

  String gender = "Male";

  bool loading = true;
  bool saving = false;

  Patient? selectedPatient;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    phoneController.dispose();
    bloodController.dispose();
    relationshipController.dispose();
    super.dispose();
  }

  // =====================================================
  // LOAD PATIENT PROFILE
  // =====================================================

  Future<void> loadProfile() async {
    // ADD NEW PATIENT
    // Do not load currently selected patient
    if (widget.addNew) {
      setState(() {
        loading = false;
      });
      return;
    }

    // LOAD SELECTED PATIENT
    selectedPatient = await PatientService().getSelectedPatient();

    if (selectedPatient != null) {
      final doc = await firestore.getProfile(selectedPatient!.id);

      if (doc.exists) {
        final data = doc.data()!;

        nameController.text = data["name"] ?? "";
        ageController.text = data["age"] ?? "";
        phoneController.text = data["phone"] ?? "";
        bloodController.text = data["blood"] ?? data["bloodGroup"] ?? "";
        relationshipController.text = data["relationship"] ?? "";

        gender = data["gender"] ?? "Male";
      }
    }

    if (!mounted) return;

    setState(() {
      loading = false;
    });
  }

  // =====================================================
  // ADD OR UPDATE PATIENT
  // =====================================================

  Future<void> saveProfile() async {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter patient name")),
      );
      return;
    }

    setState(() {
      saving = true;
    });

    try {
      // =================================================
      // ADD NEW PATIENT
      // =================================================

      if (widget.addNew || selectedPatient == null) {
        final patientId = await firestore.addPatient(
          name: nameController.text.trim(),
          age: ageController.text.trim(),
          gender: gender,
          phone: phoneController.text.trim(),
          blood: bloodController.text.trim(),
          relationship: relationshipController.text.trim(),
        );

        final newPatient = Patient(
          id: patientId,
          name: nameController.text.trim(),
          age: ageController.text.trim(),
          gender: gender,
          phone: phoneController.text.trim(),
          bloodGroup: bloodController.text.trim(),
          relationship: relationshipController.text.trim(),
        );

        // Save locally
        await PatientService().addPatient(newPatient);

        // Select the newly created patient
        await PatientService().setSelectedPatient(patientId);

        selectedPatient = newPatient;

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${newPatient.name} added successfully")),
        );

        // Return to patient list
        Navigator.pop(context, true);
      }
      // =================================================
      // UPDATE EXISTING PATIENT
      // =================================================
      else {
        await firestore.updatePatient(
          patientId: selectedPatient!.id,
          name: nameController.text.trim(),
          age: ageController.text.trim(),
          gender: gender,
          phone: phoneController.text.trim(),
          blood: bloodController.text.trim(),
          relationship: relationshipController.text.trim(),
        );

        final updatedPatient = Patient(
          id: selectedPatient!.id,
          name: nameController.text.trim(),
          age: ageController.text.trim(),
          gender: gender,
          phone: phoneController.text.trim(),
          bloodGroup: bloodController.text.trim(),
          relationship: relationshipController.text.trim(),
        );

        await PatientService().updatePatient(updatedPatient);

        selectedPatient = updatedPatient;

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Patient profile updated")),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }

    if (!mounted) return;

    setState(() {
      saving = false;
    });
  }

  // =====================================================
  // UI
  // =====================================================

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isNewPatient = widget.addNew || selectedPatient == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isNewPatient ? "Add New Patient" : "Patient Profile"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.teal.shade100,
              child: const Icon(Icons.person, size: 55, color: Colors.teal),
            ),

            const SizedBox(height: 30),

            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Full Name",
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 18),

            TextField(
              controller: ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Age",
                prefixIcon: Icon(Icons.cake),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 18),

            DropdownButtonFormField<String>(
              initialValue: gender,
              decoration: const InputDecoration(
                labelText: "Gender",
                prefixIcon: Icon(Icons.people),
                border: OutlineInputBorder(),
              ),

              items: const [
                DropdownMenuItem(value: "Male", child: Text("Male")),

                DropdownMenuItem(value: "Female", child: Text("Female")),

                DropdownMenuItem(value: "Other", child: Text("Other")),
              ],

              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  gender = value;
                });
              },
            ),

            const SizedBox(height: 18),

            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Phone Number",
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 18),

            TextField(
              controller: bloodController,
              decoration: const InputDecoration(
                labelText: "Blood Group",
                prefixIcon: Icon(Icons.bloodtype),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 18),

            TextField(
              controller: relationshipController,
              decoration: const InputDecoration(
                labelText: "Relationship",
                prefixIcon: Icon(Icons.family_restroom),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 35),

            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton(
                onPressed: saving ? null : saveProfile,

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),

                child: saving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        isNewPatient ? "ADD PATIENT" : "UPDATE PROFILE",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
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

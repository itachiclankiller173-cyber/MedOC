import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/patient.dart';

class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({super.key});

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final phoneController = TextEditingController();
  final bloodController = TextEditingController();

  String gender = "Male";
  String relationship = "Self";

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    phoneController.dispose();
    bloodController.dispose();
    super.dispose();
  }

  void savePatient() {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter patient name")),
      );
      return;
    }

    final patient = Patient(
      id: const Uuid().v4(),
      name: nameController.text.trim(),
      age: ageController.text.trim(),
      gender: gender,
      phone: phoneController.text.trim(),
      bloodGroup: bloodController.text.trim(),
      relationship: relationship,
    );

    Navigator.pop(context, patient);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Patient"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 45,
              backgroundColor: Colors.teal,
              child: Icon(Icons.person_add, color: Colors.white, size: 45),
            ),

            const SizedBox(height: 25),

            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Full Name",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Age",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.cake),
              ),
            ),

            const SizedBox(height: 15),

            DropdownButtonFormField<String>(
              initialValue: gender,
              decoration: const InputDecoration(
                labelText: "Gender",
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: "Male", child: Text("Male")),
                DropdownMenuItem(value: "Female", child: Text("Female")),
                DropdownMenuItem(value: "Other", child: Text("Other")),
              ],
              onChanged: (value) {
                setState(() {
                  gender = value!;
                });
              },
            ),

            const SizedBox(height: 15),

            DropdownButtonFormField<String>(
              initialValue: relationship,
              decoration: const InputDecoration(
                labelText: "Relationship",
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: "Self", child: Text("Self")),
                DropdownMenuItem(value: "Father", child: Text("Father")),
                DropdownMenuItem(value: "Mother", child: Text("Mother")),
                DropdownMenuItem(value: "Son", child: Text("Son")),
                DropdownMenuItem(value: "Daughter", child: Text("Daughter")),
                DropdownMenuItem(value: "Spouse", child: Text("Spouse")),
                DropdownMenuItem(value: "Other", child: Text("Other")),
              ],
              onChanged: (value) {
                setState(() {
                  relationship = value!;
                });
              },
            ),

            const SizedBox(height: 15),

            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Phone Number",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: bloodController,
              decoration: const InputDecoration(
                labelText: "Blood Group",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.bloodtype),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: savePatient,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  "SAVE PATIENT",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

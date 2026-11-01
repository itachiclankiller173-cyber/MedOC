import 'package:flutter/material.dart';

class PatientScreen extends StatelessWidget {
  const PatientScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Patient Details"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: "Patient Name",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),

            SizedBox(height: 20),

            TextField(
              decoration: InputDecoration(
                labelText: "Age",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.cake),
              ),
              keyboardType: TextInputType.number,
            ),

            SizedBox(height: 20),

            TextField(
              decoration: InputDecoration(
                labelText: "Gender",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.people),
              ),
            ),

            SizedBox(height: 20),

            TextField(
              decoration: InputDecoration(
                labelText: "Phone Number",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),

            SizedBox(height: 20),

            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Medical History",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.medical_information),
              ),
            ),

            SizedBox(height: 30),

            SizedBox(
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {},
                child: const Text("SAVE", style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class MedicineScreen extends StatefulWidget {
  const MedicineScreen({super.key});

  @override
  State<MedicineScreen> createState() => _MedicineScreenState();
}

class _MedicineScreenState extends State<MedicineScreen> {
  final List<Map<String, dynamic>> medicines = [
    {"name": "Paracetamol", "time": "08:00 AM", "taken": false},
    {"name": "Vitamin D", "time": "08:00 PM", "taken": true},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Medicine Reminder"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
        onPressed: () {},
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: medicines.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: CheckboxListTile(
              value: medicines[index]["taken"],
              activeColor: Colors.teal,
              onChanged: (value) {
                setState(() {
                  medicines[index]["taken"] = value!;
                });
              },
              title: Text(
                medicines[index]["name"],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text("Time: ${medicines[index]["time"]}"),
              secondary: const Icon(Icons.medication, color: Colors.teal),
            ),
          );
        },
      ),
    );
  }
}

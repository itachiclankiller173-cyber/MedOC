import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/notification_service.dart';

import '../services/firestore_service.dart';
import '../services/patient_service.dart';
import 'medicine_reminder_screen.dart';

class MedicineListScreen extends StatefulWidget {
  const MedicineListScreen({super.key});

  @override
  State<MedicineListScreen> createState() => _MedicineListScreenState();
}

class _MedicineListScreenState extends State<MedicineListScreen> {
  final FirestoreService firestore = FirestoreService();

  String patientId = "";
  bool loading = true;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    final patient = await PatientService().getSelectedPatient();

    if (patient != null) {
      patientId = patient.id;
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (patientId.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Medicine List"),
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: Text("Please select a patient.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Medicine List"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MedicineReminderScreen(patientId: patientId),
            ),
          );
        },
      ),

      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: firestore.medicineStream(patientId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No Medicines Added", style: TextStyle(fontSize: 18)),
            );
          }

          final medicines = snapshot.data!.docs;

          return ListView.builder(
            itemCount: medicines.length,
            itemBuilder: (context, index) {
              final doc = medicines[index];
              final medicine = doc.data();

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.teal,
                    child: Icon(Icons.medication, color: Colors.white),
                  ),

                  title: Text(
                    medicine["medicine"] ?? "",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),

                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Dosage : ${medicine["dosage"]}"),
                      Text("Time : ${medicine["timing"]}"),
                      Text("Food : ${medicine["food"]}"),
                    ],
                  ),

                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == "delete") {
                        try {
                          // Cancel the medicine notification
                          await NotificationService.cancelMedicineReminder(
                            doc.id.hashCode,
                          );

                          // Delete the medicine from Firestore
                          await firestore.deleteMedicine(
                            patientId: patientId,
                            medicineId: doc.id,
                          );

                          if (!mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Medicine and reminder deleted"),
                            ),
                          );
                        } catch (e) {
                          if (!mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Delete failed: $e")),
                          );
                        }
                      }

                      if (value == "edit") {
                        if (!mounted) return;

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MedicineReminderScreen(
                              patientId: patientId,
                              medicineId: doc.id,
                              oldMedicine: medicine,
                            ),
                          ),
                        );
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: "edit", child: Text("Edit")),
                      PopupMenuItem(value: "delete", child: Text("Delete")),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

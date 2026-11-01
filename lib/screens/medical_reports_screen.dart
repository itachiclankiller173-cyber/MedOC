import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/firestore_service.dart';

class MedicalReportsScreen extends StatefulWidget {
  final String patientId;

  const MedicalReportsScreen({super.key, required this.patientId});

  @override
  State<MedicalReportsScreen> createState() => _MedicalReportsScreenState();
}

class _MedicalReportsScreenState extends State<MedicalReportsScreen> {
  final FirestoreService firestore = FirestoreService();

  void addReport() {
    final TextEditingController nameController = TextEditingController();

    String reportType = "Blood Test";
    bool saving = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text("Add Medical Report"),

              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: "Report Name",
                      prefixIcon: Icon(Icons.description),
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 15),

                  DropdownButtonFormField<String>(
                    initialValue: reportType,
                    decoration: const InputDecoration(
                      labelText: "Report Type",
                      border: OutlineInputBorder(),
                    ),

                    items: const [
                      DropdownMenuItem(
                        value: "Blood Test",
                        child: Text("Blood Test"),
                      ),
                      DropdownMenuItem(
                        value: "Urine Test",
                        child: Text("Urine Test"),
                      ),
                      DropdownMenuItem(value: "X-Ray", child: Text("X-Ray")),
                      DropdownMenuItem(value: "ECG", child: Text("ECG")),
                      DropdownMenuItem(value: "Other", child: Text("Other")),
                    ],

                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() {
                          reportType = value;
                        });
                      }
                    },
                  ),
                ],
              ),

              actions: [
                TextButton(
                  onPressed: saving
                      ? null
                      : () {
                          Navigator.pop(dialogContext);
                        },
                  child: const Text("Cancel"),
                ),

                ElevatedButton(
                  onPressed: saving
                      ? null
                      : () async {
                          final name = nameController.text.trim();

                          if (name.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Enter report name"),
                              ),
                            );
                            return;
                          }

                          setDialogState(() {
                            saving = true;
                          });

                          try {
                            await firestore.saveReport(
                              patientId: widget.patientId,
                              fileName: name,
                              aiResult: "",
                              reportType: reportType,
                            );

                            if (!dialogContext.mounted) return;

                            Navigator.pop(dialogContext);

                            if (!mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Report added successfully"),
                              ),
                            );
                          } catch (e) {
                            setDialogState(() {
                              saving = false;
                            });

                            if (!dialogContext.mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Error: $e")),
                            );
                          }
                        },

                  child: saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("Add"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> deleteReport(String reportId) async {
    try {
      await firestore.deleteReport(
        patientId: widget.patientId,
        reportId: reportId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Report deleted")));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  void confirmDelete(String reportId, String reportName) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Delete Report"),

          content: Text("Delete \"$reportName\"?"),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text("Cancel"),
            ),

            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                await deleteReport(reportId);
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Medical Reports"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        onPressed: addReport,
        child: const Icon(Icons.add),
      ),

      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: firestore.reportsStream(widget.patientId),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error loading reports:\n${snapshot.error}",
                textAlign: TextAlign.center,
              ),
            );
          }

          final reports = snapshot.data?.docs ?? [];

          if (reports.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_open, size: 80, color: Colors.grey),

                  SizedBox(height: 15),

                  Text("No medical reports", style: TextStyle(fontSize: 18)),

                  SizedBox(height: 8),

                  Text(
                    "Tap + to add a report",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: reports.length,

            itemBuilder: (context, index) {
              final doc = reports[index];
              final report = doc.data();

              final fileName = report["fileName"]?.toString() ?? "";

              final reportType = report["reportType"]?.toString() ?? "Other";

              return Card(
                elevation: 3,

                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.teal,
                    child: Icon(Icons.description, color: Colors.white),
                  ),

                  title: Text(
                    fileName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),

                  subtitle: Text(reportType),

                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == "delete") {
                        confirmDelete(doc.id, fileName);
                      }
                    },

                    itemBuilder: (context) => const [
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

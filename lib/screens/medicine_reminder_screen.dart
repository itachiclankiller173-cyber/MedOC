import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../services/firestore_service.dart';

class MedicineReminderScreen extends StatefulWidget {
  final String patientId;
  final String? medicineId;
  final Map<String, dynamic>? oldMedicine;

  const MedicineReminderScreen({
    super.key,
    required this.patientId,
    this.medicineId,
    this.oldMedicine,
  });
  @override
  State<MedicineReminderScreen> createState() => _MedicineReminderScreenState();
}

class _MedicineReminderScreenState extends State<MedicineReminderScreen> {
  final FirestoreService firestore = FirestoreService();

  final _formKey = GlobalKey<FormState>();

  final TextEditingController medicineController = TextEditingController();

  final TextEditingController dosageController = TextEditingController();

  final TextEditingController startDateController = TextEditingController();

  final TextEditingController endDateController = TextEditingController();

  final TextEditingController notesController = TextEditingController();

  TimeOfDay reminderTime = TimeOfDay.now();

  String timing = "Morning";

  String food = "After Food";

  bool loading = false;

  @override
  void initState() {
    super.initState();

    if (widget.oldMedicine != null) {
      medicineController.text = widget.oldMedicine!["medicine"] ?? "";

      dosageController.text = widget.oldMedicine!["dosage"] ?? "";

      timing = widget.oldMedicine!["timing"] ?? "Morning";

      food = widget.oldMedicine!["food"] ?? "After Food";

      startDateController.text = widget.oldMedicine!["startDate"] ?? "";

      endDateController.text = widget.oldMedicine!["endDate"] ?? "";

      notesController.text = widget.oldMedicine!["notes"] ?? "";
    }
  }

  Future<void> pickStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        startDateController.text =
            "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Future<void> pickEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        endDateController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Future<void> pickReminderTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: reminderTime,
    );

    if (picked != null) {
      setState(() {
        reminderTime = picked;
      });
    }
  }

  DateTime getNextReminderTime() {
    final now = DateTime.now();

    DateTime reminder = DateTime(
      now.year,
      now.month,
      now.day,
      reminderTime.hour,
      reminderTime.minute,
    );

    // If today's time has already passed,
    // schedule it for tomorrow.
    if (reminder.isBefore(now)) {
      reminder = reminder.add(const Duration(days: 1));
    }

    return reminder;
  }

  Future<void> saveMedicine() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      loading = true;
    });

    try {
      String notificationMedicineId;

      if (widget.medicineId == null) {
        // Add medicine and get Firestore document ID
        final medicineId = await firestore.saveMedicine(
          patientId: widget.patientId,
          medicine: medicineController.text.trim(),
          dosage: dosageController.text.trim(),
          timing: timing,
          food: food,
          startDate: startDateController.text,
          endDate: endDateController.text,
          
        );
        notificationMedicineId = medicineId;
      } else {
        // Update existing medicine
        await firestore.updateMedicine(
          patientId: widget.patientId,
          medicineId: widget.medicineId!,
          medicine: medicineController.text.trim(),
          dosage: dosageController.text.trim(),
          timing: timing,
          food: food,
          startDate: startDateController.text,
          endDate: endDateController.text,
        );

        notificationMedicineId = widget.medicineId!;
      }

      // Convert Firestore medicine ID into notification ID
      final int notificationId = notificationMedicineId.hashCode;

      // Get the next reminder time
      final DateTime reminderDateTime = getNextReminderTime();

      // Schedule medicine reminder
      await NotificationService.scheduleMedicineReminder(
        notificationId,
        medicineController.text.trim(),
        dosageController.text.trim(),
        reminderDateTime,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.medicineId == null
                ? "Medicine Added & Reminder Scheduled"
                : "Medicine Updated & Reminder Scheduled",
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    medicineController.dispose();
    dosageController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.medicineId == null ? "Add Medicine" : "Edit Medicine",
        ),
      ),

      body: Form(
        key: _formKey,

        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              const Center(
                child: Icon(Icons.medication, color: Colors.teal, size: 90),
              ),

              const SizedBox(height: 30),

              TextFormField(
                controller: medicineController,

                decoration: const InputDecoration(
                  labelText: "Medicine Name",
                  prefixIcon: Icon(Icons.medication),
                  border: OutlineInputBorder(),
                ),

                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter medicine name";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: dosageController,

                decoration: const InputDecoration(
                  labelText: "Dosage",
                  prefixIcon: Icon(Icons.local_hospital),
                  border: OutlineInputBorder(),
                ),

                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter dosage";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                initialValue: timing,

                decoration: const InputDecoration(
                  labelText: "Medicine Time",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.schedule),
                ),

                items: const [
                  DropdownMenuItem(value: "Morning", child: Text("Morning")),

                  DropdownMenuItem(
                    value: "Afternoon",
                    child: Text("Afternoon"),
                  ),

                  DropdownMenuItem(value: "Evening", child: Text("Evening")),

                  DropdownMenuItem(value: "Night", child: Text("Night")),
                ],

                onChanged: (value) {
                  setState(() {
                    timing = value!;
                  });
                },
              ),

              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                initialValue: food,

                decoration: const InputDecoration(
                  labelText: "Food Preference",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.restaurant),
                ),

                items: const [
                  DropdownMenuItem(
                    value: "Before Food",
                    child: Text("Before Food"),
                  ),

                  DropdownMenuItem(
                    value: "After Food",
                    child: Text("After Food"),
                  ),
                ],

                onChanged: (value) {
                  setState(() {
                    food = value!;
                  });
                },
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: startDateController,
                readOnly: true,

                onTap: pickStartDate,

                decoration: const InputDecoration(
                  labelText: "Start Date",
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: endDateController,
                readOnly: true,

                onTap: pickEndDate,

                decoration: const InputDecoration(
                  labelText: "End Date",
                  prefixIcon: Icon(Icons.event),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.alarm, color: Colors.teal),

                  title: const Text("Reminder Time"),

                  subtitle: Text(reminderTime.format(context)),

                  trailing: IconButton(
                    icon: const Icon(Icons.edit),

                    onPressed: pickReminderTime,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: notesController,

                maxLines: 3,

                decoration: const InputDecoration(
                  labelText: "Notes (Optional)",
                  prefixIcon: Icon(Icons.note),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 30),
              if (loading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: saveMedicine,
                    icon: Icon(
                      widget.medicineId == null ? Icons.save : Icons.edit,
                    ),
                    label: Text(
                      widget.medicineId == null
                          ? "SAVE MEDICINE"
                          : "UPDATE MEDICINE",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 25),

              const Card(
                elevation: 4,
                child: ListTile(
                  leading: Icon(
                    Icons.notifications_active,
                    color: Colors.orange,
                  ),
                  title: Text("Reminder"),
                  subtitle: Text(
                    "Medicine reminders will automatically appear here after notification integration.",
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

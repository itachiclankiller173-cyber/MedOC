import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'first_aid_screen.dart';
import 'hospital_locator_screen.dart';

class SOSScreen extends StatefulWidget {
  const SOSScreen({super.key});

  @override
  State<SOSScreen> createState() => _SOSScreenState();
}

class _SOSScreenState extends State<SOSScreen> {
  String contactName = "";
  String contactPhone = "";

  @override
  void initState() {
    super.initState();
    _loadEmergencyContact();
  }

  // =========================
  // LOAD CONTACT
  // =========================

  Future<void> _loadEmergencyContact() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      contactName = prefs.getString("emergency_contact_name") ?? "";
      contactPhone = prefs.getString("emergency_contact_phone") ?? "";
    });
  }

  // =========================
  // SAVE CONTACT
  // =========================

  Future<void> _saveEmergencyContact(String name, String phone) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString("emergency_contact_name", name);
    await prefs.setString("emergency_contact_phone", phone);

    setState(() {
      contactName = name;
      contactPhone = phone;
    });
  }

  // =========================
  // DELETE CONTACT
  // =========================

  Future<void> _deleteEmergencyContact() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove("emergency_contact_name");
    await prefs.remove("emergency_contact_phone");

    setState(() {
      contactName = "";
      contactPhone = "";
    });
  }

  // =========================
  // ADD CONTACT DIALOG
  // =========================

  void _showAddContactDialog() {
    final nameController = TextEditingController(text: contactName);

    final phoneController = TextEditingController(text: contactPhone);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Emergency Contact"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Name",
                  hintText: "Parent / Guardian / Family",
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "Phone Number",
                  hintText: "Enter phone number",
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text("CANCEL"),
            ),

            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final phone = phoneController.text.trim();

                if (name.isEmpty || phone.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please enter both name and phone number."),
                    ),
                  );
                  return;
                }

                await _saveEmergencyContact(name, phone);

                if (!dialogContext.mounted) return;

                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Emergency contact saved.")),
                );
              },
              child: const Text("SAVE"),
            ),
          ],
        );
      },
    );
  }

  // =========================
  // CALL CONTACT
  // =========================

  Future<void> _callContact() async {
    if (contactPhone.isEmpty) return;

    final Uri phoneUri = Uri(scheme: "tel", path: contactPhone);

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unable to open the phone dialer.")),
      );
    }
  }

  // =========================
  // CALL 112
  // =========================

  Future<void> _callEmergency() async {
    final Uri phoneUri = Uri(scheme: "tel", path: "112");

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unable to open the phone dialer.")),
      );
    }
  }

  // =========================
  // CONFIRM EMERGENCY CALL
  // =========================

  void _confirmEmergencyCall() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.red),
              SizedBox(width: 8),
              Text("Emergency Call"),
            ],
          ),
          content: const Text(
            "This will open the phone dialer for emergency number 112.\n\n"
            "Use emergency services only for genuine emergencies.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text("CANCEL"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _callEmergency();
              },
              child: const Text("CALL 112"),
            ),
          ],
        );
      },
    );
  }

  // =========================
  // BUILD
  // =========================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SOS Emergency"),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            const SizedBox(height: 10),

            const Icon(Icons.emergency, color: Colors.red, size: 65),

            const SizedBox(height: 10),

            const Text(
              "Emergency Assistance",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            const Text(
              "Get quick access to emergency assistance, "
              "first aid and your emergency contact.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 15),
            ),

            const SizedBox(height: 30),

            // =========================
            // SOS BUTTON
            // =========================
            GestureDetector(
              onTap: _confirmEmergencyCall,

              child: Container(
                width: 190,
                height: 190,

                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red,

                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withValues(alpha: 0.35),
                      blurRadius: 25,
                      spreadRadius: 8,
                    ),
                  ],
                ),

                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [
                    Icon(Icons.warning_rounded, color: Colors.white, size: 55),

                    SizedBox(height: 8),

                    Text(
                      "SOS",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Text(
                      "CALL 112",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // =========================
            // EMERGENCY CONTACT
            // =========================
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Emergency Contact",
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 12),

            if (contactName.isEmpty)
              Card(
                elevation: 3,
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.orange,
                    child: Icon(Icons.person_add, color: Colors.white),
                  ),

                  title: const Text(
                    "No emergency contact added",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  subtitle: const Text(
                    "Add a parent, guardian or family member",
                  ),

                  trailing: const Icon(Icons.add),

                  onTap: _showAddContactDialog,
                ),
              )
            else
              Card(
                elevation: 3,

                child: Padding(
                  padding: const EdgeInsets.all(12),

                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.teal,
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Text(
                              contactName,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              contactPhone,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),

                      IconButton(
                        tooltip: "Call",
                        icon: const Icon(Icons.phone, color: Colors.green),
                        onPressed: _callContact,
                      ),

                      IconButton(
                        tooltip: "Edit",
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: _showAddContactDialog,
                      ),

                      IconButton(
                        tooltip: "Delete",
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _deleteEmergencyContact();
                        },
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 25),

            // =========================
            // FIRST AID
            // =========================
            Card(
              elevation: 3,

              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.teal,
                  child: Icon(Icons.medical_services, color: Colors.white),
                ),

                title: const Text(
                  "First-Aid Guide",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                subtitle: const Text("Help for injuries and accidents"),

                trailing: const Icon(Icons.arrow_forward_ios),

                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FirstAidScreen()),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // =========================
            // HOSPITAL
            // =========================
            Card(
              elevation: 3,

              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.local_hospital, color: Colors.white),
                ),

                title: const Text(
                  "Find Nearby Hospitals",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                subtitle: const Text("Locate medical facilities"),

                trailing: const Icon(Icons.arrow_forward_ios),

                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const HospitalLocatorScreen(),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 25),

            // =========================
            // WARNING
            // =========================
            Card(
              color: Colors.red.shade50,

              child: const Padding(
                padding: EdgeInsets.all(16),

                child: Column(
                  children: [
                    Icon(Icons.info_outline, color: Colors.red, size: 32),

                    SizedBox(height: 8),

                    Text(
                      "Important",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 8),

                    Text(
                      "MedOC provides general health information "
                      "and does not replace emergency medical "
                      "services or professional medical care.",
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

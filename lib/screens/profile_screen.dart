import 'package:flutter/material.dart';
import '../services/language_service.dart';
import '../services/voice_service.dart';
import 'patient_selection_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String selectedLanguage = "English";

  final VoiceService voiceService = VoiceService();

  final Map<String, String> languageCodes = {
    "English": "en-IN",
    "Malayalam": "ml-IN",
    "Hindi": "hi-IN",
  };

  @override
  void initState() {
    super.initState();
    loadSelectedLanguage();
  }

  Future<void> loadSelectedLanguage() async {
    final savedCode = await LanguageService.getLanguage();

    final language = languageCodes.entries
        .firstWhere(
          (entry) => entry.value == savedCode,
          orElse: () => const MapEntry("English", "en-IN"),
        )
        .key;

    if (!mounted) return;

    setState(() {
      selectedLanguage = language;
    });
  }

  Future<void> changeLanguage(String language) async {
    final languageCode = languageCodes[language]!;

    await voiceService.changeLanguage(languageCode);

    if (!mounted) return;

    setState(() {
      selectedLanguage = language;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Language changed to $language")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 30),
            color: Colors.teal,
            child: const Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 60, color: Colors.teal),
                ),
                SizedBox(height: 15),
                Text(
                  "Patient Profile",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  "Manage your patient information",
                  style: TextStyle(color: Colors.white70, fontSize: 15),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // CREATE / EDIT PATIENT
          // PATIENTS
          ListTile(
            leading: const Icon(Icons.people, color: Colors.teal),

            title: const Text(
              "Patients",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            subtitle: const Text("Add, select or switch patient"),

            trailing: const Icon(Icons.arrow_forward_ios),

            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PatientSelectionScreen(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.people, color: Colors.teal),
            title: const Text(
              "Patients",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text("Add, select or switch patient"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PatientSelectionScreen(),
                ),
              );
            },
          ),

          const Divider(),

          // NOTIFICATIONS
          ListTile(
            leading: const Icon(Icons.notifications, color: Colors.teal),
            title: const Text("Notifications"),
            subtitle: const Text("Medicine reminder notifications"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Medicine notifications are enabled."),
                ),
              );
            },
          ),

          // PRIVACY
          ListTile(
            leading: const Icon(Icons.lock, color: Colors.teal),
            title: const Text("Privacy"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Privacy settings coming next.")),
              );
            },
          ),

          // LANGUAGE
          ListTile(
            leading: const Icon(Icons.language, color: Colors.teal),
            title: const Text("Language"),
            subtitle: Text(selectedLanguage),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: (sheetContext) {
                  return SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: languageCodes.keys.map((language) {
                        return ListTile(
                          leading: Icon(
                            Icons.language,
                            color: language == selectedLanguage
                                ? Colors.teal
                                : Colors.grey,
                          ),
                          title: Text(language),
                          trailing: language == selectedLanguage
                              ? const Icon(Icons.check, color: Colors.teal)
                              : null,
                          onTap: () async {
                            Navigator.pop(sheetContext);
                            await changeLanguage(language);
                          },
                        );
                      }).toList(),
                    ),
                  );
                },
              );
            },
          ),

          // DARK MODE
          ListTile(
            leading: const Icon(Icons.dark_mode, color: Colors.teal),
            title: const Text("Dark Mode"),
            trailing: Switch(
              value: false,
              onChanged: (value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Dark mode coming next.")),
                );
              },
            ),
          ),

          // ABOUT
          ListTile(
            leading: const Icon(Icons.info, color: Colors.teal),
            title: const Text("About MedOC"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: "MedOC",
                applicationVersion: "1.0.0",
                applicationIcon: const Icon(
                  Icons.health_and_safety,
                  color: Colors.teal,
                  size: 40,
                ),
                children: const [
                  Text(
                    "MedOC is an AI-powered healthcare companion "
                    "for managing patient health information.",
                  ),
                ],
              );
            },
          ),

          const Divider(),

          // LOGOUT
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              "Logout",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Logout coming next.")),
              );
            },
          ),
        ],
      ),
    );
  }
}

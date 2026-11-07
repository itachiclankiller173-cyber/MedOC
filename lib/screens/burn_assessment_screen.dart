import 'dart:convert';

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BurnAssessmentScreen extends StatefulWidget {
  const BurnAssessmentScreen({super.key});

  @override
  State<BurnAssessmentScreen> createState() => _BurnAssessmentScreenState();
}

class _BurnAssessmentScreenState extends State<BurnAssessmentScreen> {
  final ImagePicker _picker = ImagePicker();


  XFile? selectedImage;

  String cause = "Heat / Flame";
  String location = "Arm";
  int painLevel = 0;

  bool redness = false;
  bool swelling = false;
  bool blistering = false;
  bool openSkin = false;
  bool severePain = false;
  bool largeArea = false;
  bool faceOrEye = false;
  bool electrical = false;
  bool chemical = false;
  bool breathingDifficulty = false;

  final TextEditingController notesController = TextEditingController();

  List<Map<String, dynamic>> history = [];

  bool assessing = false;
  String assessmentTitle = "";
  String assessmentMessage = "";
  Color assessmentColor = Colors.teal;

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  // ============================================================
  // PHOTO
  // ============================================================

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image == null) return;

    setState(() {
      selectedImage = XFile(image.path);
    });
  }

  Future<void> takePhoto() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (image == null) return;

    setState(() {
      selectedImage =XFile(image.path);
    });
  }

  // ============================================================
  // LOCAL HISTORY
  // ============================================================

  Future<void> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();

    final saved = prefs.getStringList("burn_assessment_history");

    if (saved == null) return;

    setState(() {
      history = saved
          .map((item) => Map<String, dynamic>.from(jsonDecode(item)))
          .toList();
    });
  }

  Future<void> saveHistory() async {
    final prefs = await SharedPreferences.getInstance();

    final saved = history.map((item) => jsonEncode(item)).toList();

    await prefs.setStringList("burn_assessment_history", saved);
  }

  // ============================================================
  // ASSESSMENT
  // ============================================================

  void performAssessment() {
    setState(() {
      assessing = true;
    });

    String title;
    String message;
    Color color;

    final urgent =
        breathingDifficulty ||
        electrical ||
        chemical ||
        faceOrEye ||
        largeArea ||
        severePain;

    final medicalAttention =
        blistering || openSkin || swelling || painLevel >= 7;

    if (urgent) {
      title = "🚨 Urgent Medical Attention";
      color = Colors.red;

      message =
          "The information entered includes warning signs that may "
          "require urgent professional medical assessment. "
          "Do not rely on this app to determine burn severity. "
          "Contact your local emergency service or seek urgent medical care.";
    } else if (medicalAttention) {
      title = "⚠️ Medical Assessment Recommended";
      color = Colors.orange;

      message =
          "The information entered suggests that professional "
          "medical assessment may be appropriate, particularly if "
          "symptoms are worsening or the affected area is significant. "
          "This app cannot diagnose the burn.";
    } else {
      title = "🟢 Basic First-Aid Guidance";
      color = Colors.green;

      message =
          "The information entered does not show the major warning "
          "signs included in this prototype. Continue basic first aid "
          "and monitor the area. Seek medical care if symptoms worsen.";
    }

    setState(() {
      assessmentTitle = title;
      assessmentMessage = message;
      assessmentColor = color;
      assessing = false;
    });

    saveAssessment();
  }

  Future<void> saveAssessment() async {
    final now = DateTime.now();

    final result = {
      "date":
          "${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute.toString().padLeft(2, '0')}",
      "cause": cause,
      "location": location,
      "pain": painLevel,
      "result": assessmentTitle,
      "notes": notesController.text.trim(),
    };

    history.insert(0, result);

    if (history.length > 20) {
      history.removeLast();
    }

    await saveHistory();

    if (mounted) {
      setState(() {});
    }
  }

  // ============================================================
  // RESET
  // ============================================================

  void resetAssessment() {
    setState(() {
      selectedImage = null;

      cause = "Heat / Flame";
      location = "Arm";
      painLevel = 0;

      redness = false;
      swelling = false;
      blistering = false;
      openSkin = false;
      severePain = false;
      largeArea = false;
      faceOrEye = false;
      electrical = false;
      chemical = false;
      breathingDifficulty = false;

      notesController.clear();

      assessmentTitle = "";
      assessmentMessage = "";
    });
  }

  // ============================================================
  // HISTORY DELETE
  // ============================================================

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove("burn_assessment_history");

    setState(() {
      history.clear();
    });
  }

  // ============================================================
  // UI HELPERS
  // ============================================================

  Widget sectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.teal),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget checklistTile(
    String title,
    bool value,
    ValueChanged<bool?> onChanged,
  ) {
    return Card(
      child: CheckboxListTile(
        value: value,
        onChanged: onChanged,
        title: Text(title),
        activeColor: Colors.teal,
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Burn Assessment"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // ====================================================
            // INFORMATION CARD
            // ====================================================
            Card(
              color: Colors.orange.shade50,
              child: const Padding(
                padding: EdgeInsets.all(18),

                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Icon(
                      Icons.local_fire_department,
                      color: Colors.orange,
                      size: 38,
                    ),

                    SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        "This is a first-aid support tool, not a "
                        "medical diagnostic system. For serious "
                        "burns, electrical or chemical burns, "
                        "breathing problems, or burns involving "
                        "important areas of the body, seek "
                        "professional medical help immediately.",
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ====================================================
            // PHOTO
            // ====================================================
            sectionTitle("Burn Photo", Icons.camera_alt),

            if (selectedImage != null)
  FutureBuilder<Uint8List>(
    future: selectedImage!.readAsBytes(),
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Image.memory(
            snapshot.data!,
            width: double.infinity,
            height: 250,
            fit: BoxFit.cover,
          ),
        );
      }

      return const SizedBox(
        height: 250,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    },
  )
else
  Container(
    width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image, size: 60, color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      "No photo selected",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                )
    // Keep the rest of your existing Container code here.
  ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: pickImage,
                    icon: const Icon(Icons.photo),
                    label: const Text("Gallery"),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: takePhoto,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Camera"),
                  ),
                ),
              ],
            ),

            // ====================================================
            // CAUSE
            // ====================================================
            sectionTitle("Cause of Burn", Icons.whatshot),

            DropdownButtonFormField<String>(
              initialValue: cause,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "What caused the burn?",
              ),

              items: const [
                DropdownMenuItem(
                  value: "Heat / Flame",
                  child: Text("Heat / Flame"),
                ),
                DropdownMenuItem(
                  value: "Hot Liquid",
                  child: Text("Hot Liquid"),
                ),
                DropdownMenuItem(value: "Steam", child: Text("Steam")),
                DropdownMenuItem(value: "Chemical", child: Text("Chemical")),
                DropdownMenuItem(
                  value: "Electrical",
                  child: Text("Electrical"),
                ),
                DropdownMenuItem(value: "Other", child: Text("Other")),
              ],

              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  cause = value;

                  chemical = value == "Chemical";
                  electrical = value == "Electrical";
                });
              },
            ),

            // ====================================================
            // LOCATION
            // ====================================================
            sectionTitle("Body Location", Icons.accessibility),

            DropdownButtonFormField<String>(
              initialValue: location,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Where is the burn?",
              ),

              items: const [
                DropdownMenuItem(value: "Arm", child: Text("Arm")),
                DropdownMenuItem(value: "Hand", child: Text("Hand")),
                DropdownMenuItem(value: "Leg", child: Text("Leg")),
                DropdownMenuItem(value: "Foot", child: Text("Foot")),
                DropdownMenuItem(value: "Chest", child: Text("Chest")),
                DropdownMenuItem(value: "Back", child: Text("Back")),
                DropdownMenuItem(
                  value: "Face / Eye",
                  child: Text("Face / Eye"),
                ),
                DropdownMenuItem(value: "Other", child: Text("Other")),
              ],

              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  location = value;
                  faceOrEye = value == "Face / Eye";
                });
              },
            ),

            // ====================================================
            // APPEARANCE
            // ====================================================
            sectionTitle("What Do You Notice?", Icons.visibility),

            checklistTile("Redness", redness, (value) {
              setState(() {
                redness = value ?? false;
              });
            }),

            checklistTile("Swelling", swelling, (value) {
              setState(() {
                swelling = value ?? false;
              });
            }),

            checklistTile("Blisters", blistering, (value) {
              setState(() {
                blistering = value ?? false;
              });
            }),

            checklistTile("Skin is broken / open", openSkin, (value) {
              setState(() {
                openSkin = value ?? false;
              });
            }),

            checklistTile("Burn covers a large area", largeArea, (value) {
              setState(() {
                largeArea = value ?? false;
              });
            }),

            // ====================================================
            // PAIN
            // ====================================================
            sectionTitle("Pain Level", Icons.sentiment_dissatisfied),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),

                child: Column(
                  children: [
                    Text(
                      "$painLevel / 10",
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Slider(
                      value: painLevel.toDouble(),
                      min: 0,
                      max: 10,
                      divisions: 10,
                      label: "$painLevel",
                      activeColor: Colors.teal,

                      onChanged: (value) {
                        setState(() {
                          painLevel = value.round();
                          severePain = painLevel >= 7;
                        });
                      },
                    ),

                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Text("No pain"), Text("Severe pain")],
                    ),
                  ],
                ),
              ),
            ),

            // ====================================================
            // WARNING SIGNS
            // ====================================================
            sectionTitle("Warning Signs", Icons.warning_amber),

            checklistTile("Severe or worsening pain", severePain, (value) {
              setState(() {
                severePain = value ?? false;
              });
            }),

            checklistTile("Burn involves face or eyes", faceOrEye, (value) {
              setState(() {
                faceOrEye = value ?? false;
              });
            }),

            checklistTile("Chemical exposure", chemical, (value) {
              setState(() {
                chemical = value ?? false;
              });
            }),

            checklistTile("Electrical injury", electrical, (value) {
              setState(() {
                electrical = value ?? false;
              });
            }),

            checklistTile("Difficulty breathing", breathingDifficulty, (value) {
              setState(() {
                breathingDifficulty = value ?? false;
              });
            }),

            // ====================================================
            // NOTES
            // ====================================================
            sectionTitle("Additional Notes", Icons.note),

            TextField(
              controller: notesController,
              maxLines: 4,

              decoration: const InputDecoration(
                hintText:
                    "Describe what happened or anything else you noticed...",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 25),

            // ====================================================
            // ASSESS BUTTON
            // ====================================================
            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton.icon(
                onPressed: assessing ? null : performAssessment,

                icon: assessing
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.health_and_safety),

                label: Text(
                  assessing ? "ASSESSING..." : "PERFORM BURN ASSESSMENT",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
              ),
            ),

            // ====================================================
            // RESULT
            // ====================================================
            if (assessmentTitle.isNotEmpty) ...[
              const SizedBox(height: 25),

              Card(
                color: assessmentColor.withAlpha(25),

                child: Padding(
                  padding: const EdgeInsets.all(20),

                  child: Column(
                    children: [
                      Icon(
                        assessmentTitle.startsWith("🚨")
                            ? Icons.emergency
                            : Icons.health_and_safety,
                        color: assessmentColor,
                        size: 45,
                      ),

                      const SizedBox(height: 10),

                      Text(
                        assessmentTitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          color: assessmentColor,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        assessmentMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ),

              // ==================================================
              // FIRST AID
              // ==================================================
              const SizedBox(height: 20),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      const Text(
                        "Basic First Aid",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      const Text(
                        "1. Move away from the heat or other source of injury.",
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        "2. Cool a thermal burn with cool running water for about 20 minutes when appropriate.",
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        "3. Remove nearby jewellery or tight items if they are not stuck to the skin.",
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        "4. Cover the area loosely with a clean, non-fluffy dressing.",
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        "5. Do not apply ice, butter, toothpaste, or household substances to a fresh burn.",
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        "6. Get professional medical help when the burn is serious or you are unsure what to do.",
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              OutlinedButton.icon(
                onPressed: resetAssessment,
                icon: const Icon(Icons.refresh),
                label: const Text("NEW ASSESSMENT"),
              ),
            ],

            // ====================================================
            // HISTORY
            // ====================================================
            sectionTitle("Assessment History", Icons.history),

            if (history.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: Text("No previous assessments.")),
                ),
              )
            else ...[
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: clearHistory,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text("Clear History"),
                ),
              ),

              ...history.map(
                (item) => Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.local_fire_department),
                    ),

                    title: Text(item["result"] ?? ""),

                    subtitle: Text(
                      "${item["date"]}\n"
                      "Cause: ${item["cause"]}\n"
                      "Location: ${item["location"]}\n"
                      "Pain: ${item["pain"]}/10",
                    ),

                    isThreeLine: true,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 30),

            // ====================================================
            // FINAL DISCLAIMER
            // ====================================================
            const Card(
              color: Colors.redAccent,
              child: Padding(
                padding: EdgeInsets.all(16),

                child: Text(
                  "IMPORTANT: MedOC Burn Assessment is a prototype "
                  "first-aid support feature. It cannot diagnose "
                  "burn depth, infection, or severity from a photo "
                  "or checklist. If the injury is serious, worsening, "
                  "or you are unsure what to do, seek professional "
                  "medical care.",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }
}

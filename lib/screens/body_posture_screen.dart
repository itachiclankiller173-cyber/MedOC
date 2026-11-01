import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BodyPostureScreen extends StatefulWidget {
  const BodyPostureScreen({super.key});

  @override
  State<BodyPostureScreen> createState() => _BodyPostureScreenState();
}

class _BodyPostureScreenState extends State<BodyPostureScreen> {
  final ImagePicker _picker = ImagePicker();

  File? selectedImage;

  bool headForward = false;
  bool shouldersUneven = false;
  bool roundedShoulders = false;
  bool backCurved = false;
  bool hipsUneven = false;
  bool kneesMisaligned = false;

  final TextEditingController notesController = TextEditingController();

  List<String> history = [];

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (image == null) return;

      setState(() {
        selectedImage = File(image.path);
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Could not select image: $e")));
    }
  }

  int getIssueCount() {
    int count = 0;

    if (headForward) count++;
    if (shouldersUneven) count++;
    if (roundedShoulders) count++;
    if (backCurved) count++;
    if (hipsUneven) count++;
    if (kneesMisaligned) count++;

    return count;
  }

  int getPostureScore() {
    final issues = getIssueCount();

    return (100 - issues * 15).clamp(10, 100);
  }

  String getPostureStatus() {
    final score = getPostureScore();

    if (score >= 85) {
      return "Good Posture";
    } else if (score >= 65) {
      return "Needs Improvement";
    } else {
      return "Needs Attention";
    }
  }

  String getRecommendation() {
    final score = getPostureScore();

    if (score >= 85) {
      return "Your checklist shows generally good posture. "
          "Continue taking regular movement breaks and maintain "
          "comfortable sitting and standing positions.";
    }

    if (score >= 65) {
      return "Some posture concerns were selected. Try taking "
          "regular movement breaks, adjusting your sitting position, "
          "and avoiding staying in one position for long periods.";
    }

    return "Several posture concerns were selected. Consider "
        "discussing persistent pain, weakness, numbness, or major "
        "posture changes with a qualified healthcare professional.";
  }

  Future<void> saveAssessment() async {
    final prefs = await SharedPreferences.getInstance();

    final date = DateTime.now();

    final record =
        "${date.day}/${date.month}/${date.year} • "
        "${getPostureScore()}/100 • "
        "${getPostureStatus()}";

    history.insert(0, record);

    if (history.length > 10) {
      history = history.take(10).toList();
    }

    await prefs.setStringList("posture_history", history);

    if (!mounted) return;

    setState(() {});

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Posture assessment saved")));
  }

  Future<void> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();

    final savedHistory = prefs.getStringList("posture_history") ?? [];

    if (!mounted) return;

    setState(() {
      history = savedHistory;
    });
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove("posture_history");

    if (!mounted) return;

    setState(() {
      history.clear();
    });
  }

  Widget buildCheckItem({
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: CheckboxListTile(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.teal,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final score = getPostureScore();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Body Posture Analyzer"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // INTRODUCTION
            Card(
              color: Colors.teal.shade50,
              child: const Padding(
                padding: EdgeInsets.all(18),

                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Icon(Icons.accessibility_new, color: Colors.teal, size: 40),

                    SizedBox(width: 14),

                    Expanded(
                      child: Text(
                        "Use this tool to record a simple posture "
                        "self-check. You can add a photo and mark "
                        "observations about your head, shoulders, "
                        "back, hips, and legs.",
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // PHOTO
            const Text(
              "1. Posture Photo",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),

                child: Column(
                  children: [
                    if (selectedImage != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),

                        child: Image.file(
                          selectedImage!,
                          height: 280,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      Container(
                        height: 220,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person, size: 80, color: Colors.grey),
                            SizedBox(height: 10),
                            Text(
                              "No posture photo selected",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 15),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              pickImage(ImageSource.camera);
                            },
                            icon: const Icon(Icons.camera_alt),
                            label: const Text("Camera"),
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              pickImage(ImageSource.gallery);
                            },
                            icon: const Icon(Icons.photo),
                            label: const Text("Gallery"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            // INSTRUCTIONS
            const Text(
              "Photo Tips",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            const Text(
              "For a useful comparison, take the photo while standing "
              "comfortably. Keep the whole body visible and avoid "
              "extreme poses. If possible, use similar lighting and "
              "distance each time.",
            ),

            const SizedBox(height: 25),

            // CHECKLIST
            const Text(
              "2. Posture Checklist",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            const Text(
              "Tick an item if you notice that feature. This is a "
              "self-observation tool and does not diagnose a medical condition.",
            ),

            const SizedBox(height: 12),

            buildCheckItem(
              title: "Head positioned forward",
              description:
                  "The head appears noticeably in front of the shoulders.",
              value: headForward,
              onChanged: (value) {
                setState(() {
                  headForward = value ?? false;
                });
              },
            ),

            buildCheckItem(
              title: "Uneven shoulders",
              description: "One shoulder appears noticeably higher or lower.",
              value: shouldersUneven,
              onChanged: (value) {
                setState(() {
                  shouldersUneven = value ?? false;
                });
              },
            ),

            buildCheckItem(
              title: "Rounded shoulders",
              description: "The shoulders appear noticeably rolled forward.",
              value: roundedShoulders,
              onChanged: (value) {
                setState(() {
                  roundedShoulders = value ?? false;
                });
              },
            ),

            buildCheckItem(
              title: "Back appears excessively curved",
              description:
                  "The back appears noticeably more curved than usual.",
              value: backCurved,
              onChanged: (value) {
                setState(() {
                  backCurved = value ?? false;
                });
              },
            ),

            buildCheckItem(
              title: "Uneven hips",
              description:
                  "One side of the pelvis appears higher than the other.",
              value: hipsUneven,
              onChanged: (value) {
                setState(() {
                  hipsUneven = value ?? false;
                });
              },
            ),

            buildCheckItem(
              title: "Leg or knee alignment concern",
              description: "The knees or legs appear noticeably misaligned.",
              value: kneesMisaligned,
              onChanged: (value) {
                setState(() {
                  kneesMisaligned = value ?? false;
                });
              },
            ),

            const SizedBox(height: 25),

            // SCORE
            const Text(
              "3. Posture Score",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),

                child: Column(
                  children: [
                    SizedBox(
                      width: 150,
                      height: 150,

                      child: Stack(
                        alignment: Alignment.center,

                        children: [
                          SizedBox(
                            width: 150,
                            height: 150,

                            child: CircularProgressIndicator(
                              value: score / 100,
                              strokeWidth: 12,
                              color: Colors.teal,
                              backgroundColor: Colors.grey.shade300,
                            ),
                          ),

                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,

                            children: [
                              Text(
                                "$score",
                                style: const TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text("/100"),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 15),

                    Text(
                      getPostureStatus(),
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(getRecommendation(), textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            // NOTES
            const Text(
              "4. Notes",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: notesController,
              maxLines: 4,

              decoration: const InputDecoration(
                hintText: "Example: Shoulder discomfort after studying...",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
              ),
            ),

            const SizedBox(height: 20),

            // SAVE
            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton.icon(
                onPressed: saveAssessment,

                icon: const Icon(Icons.save),

                label: const Text(
                  "SAVE ASSESSMENT",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
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

            const SizedBox(height: 30),

            // HISTORY
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                const Text(
                  "Posture History",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                if (history.isNotEmpty)
                  TextButton(
                    onPressed: clearHistory,
                    child: const Text(
                      "Clear",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 10),

            if (history.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(18),
                  child: Center(child: Text("No posture assessments yet.")),
                ),
              )
            else
              ...history.map(
                (record) => Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.teal,
                      child: Icon(Icons.accessibility_new, color: Colors.white),
                    ),
                    title: Text(record),
                    subtitle: const Text("Self-assessment record"),
                  ),
                ),
              ),

            const SizedBox(height: 25),

            // DISCLAIMER
            Card(
              color: Colors.orange.shade50,

              child: const Padding(
                padding: EdgeInsets.all(16),

                child: Text(
                  "⚠️ Important: This posture analyzer provides a "
                  "basic self-check and is not a medical diagnosis. "
                  "A photo or checklist cannot reliably diagnose "
                  "spinal, joint, or muscle conditions. If you have "
                  "persistent pain, weakness, numbness, difficulty "
                  "walking, or another concerning symptom, seek "
                  "professional medical advice.",
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

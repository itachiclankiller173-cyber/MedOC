import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GaitAnalysisScreen extends StatefulWidget {
  const GaitAnalysisScreen({super.key});

  @override
  State<GaitAnalysisScreen> createState() => _GaitAnalysisScreenState();
}

class _GaitAnalysisScreenState extends State<GaitAnalysisScreen> {
  static const String historyKey = "gait_analysis_history";

  final ImagePicker _picker = ImagePicker();

  final TextEditingController notesController = TextEditingController();

  XFile? walkingVideo;

  bool loading = false;

  // Gait observations
  bool stableWalking = true;
  bool normalStepLength = true;
  bool symmetricalSteps = true;
  bool normalFootPlacement = true;
  bool normalArmSwing = true;
  bool noDraggingFeet = true;
  bool noLimping = true;
  bool normalTurning = true;

  // Balance
  String balance = "Good";

  // Symptoms
  bool pain = false;
  bool dizziness = false;
  bool weakness = false;
  bool numbness = false;
  
  bool aiLoading = false;

  String aiGaitResult = "";
  List<Map<String, dynamic>> history = [];

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

  // ----------------------------------------------------------
  // PICK WALKING VIDEO
  // ----------------------------------------------------------

  Future<void> pickWalkingVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);

      if (video != null) {
        setState(() {
          walkingVideo = video;
        });
      }
    } catch (e) {
      showMessage("Could not select video: $e");
    }
  }

  Future<void> recordWalkingVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(seconds: 30),
      );

      if (video != null) {
        setState(() {
          walkingVideo = video;
        });
      }
    } catch (e) {
      showMessage("Could not record video: $e");
    }
  }

  // ----------------------------------------------------------
  // GAIT SCORE
  // ----------------------------------------------------------

  int calculateScore() {
    int score = 100;

    if (!stableWalking) score -= 10;
    if (!normalStepLength) score -= 10;
    if (!symmetricalSteps) score -= 10;
    if (!normalFootPlacement) score -= 10;
    if (!normalArmSwing) score -= 5;
    if (!noDraggingFeet) score -= 10;
    if (!noLimping) score -= 10;
    if (!normalTurning) score -= 10;

    if (balance == "Fair") {
      score -= 10;
    } else if (balance == "Poor") {
      score -= 20;
    }

    if (pain) score -= 5;
    if (dizziness) score -= 5;
    if (weakness) score -= 5;
    if (numbness) score -= 5;

    if (score < 0) score = 0;

    return score;
  }

  String getScoreLabel(int score) {
    if (score >= 85) {
      return "Good";
    } else if (score >= 65) {
      return "Needs Observation";
    } else {
      return "Needs Medical Review";
    }
  }

  Color getScoreColor(int score) {
    if (score >= 85) {
      return Colors.green;
    } else if (score >= 65) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  // ----------------------------------------------------------
  // SAVE HISTORY
  // ----------------------------------------------------------

  Future<void> saveAssessment() async {
    final score = calculateScore();

    final prefs = await SharedPreferences.getInstance();

    final assessment = {
      "date": DateTime.now().toIso8601String(),
      "score": score,
      "result": getScoreLabel(score),
      "videoSelected": walkingVideo != null,
      "balance": balance,
      "stableWalking": stableWalking,
      "normalStepLength": normalStepLength,
      "symmetricalSteps": symmetricalSteps,
      "normalFootPlacement": normalFootPlacement,
      "normalArmSwing": normalArmSwing,
      "noDraggingFeet": noDraggingFeet,
      "noLimping": noLimping,
      "normalTurning": normalTurning,
      "pain": pain,
      "dizziness": dizziness,
      "weakness": weakness,
      "numbness": numbness,
      "notes": notesController.text.trim(),
    };

    history.insert(0, assessment);

    // Keep only the latest 20 assessments.
    if (history.length > 20) {
      history = history.sublist(0, 20);
    }

    await prefs.setString(historyKey, jsonEncode(history));

    if (mounted) {
      setState(() {});
      showMessage("Gait assessment saved");
    }
  }

 Future<void> runAIGaitAnalysis() async {
  if (walkingVideo == null) {
    showMessage("Please record or select a walking video first.");
    return;
  }

  setState(() {
    aiLoading = true;
    aiGaitResult = "";
  });

  try {
    // IMPORTANT:
    // For a physical Android phone, replace this with your PC's IPv4 address.
    const String backendUrl =
        "http://192.168.1.6:8000/analyze-gait";

    final request = http.MultipartRequest(
      "POST",
      Uri.parse(backendUrl),
    );

    request.files.add(
      await http.MultipartFile.fromPath(
        "video",
        walkingVideo!.path,
        filename: walkingVideo!.name,
      ),
    );

    final streamedResponse = await request.send();

    final response = await http.Response.fromStream(
      streamedResponse,
    );

    if (!mounted) return;

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      if (data["success"] == true) {
       final Map<String, dynamic> gait =
    Map<String, dynamic>.from(data["gait_analysis"] ?? {});

final Map<String, dynamic> video =
    Map<String, dynamic>.from(data["video"] ?? {});
        setState(() {
          aiGaitResult = """
🧠 MEDOC AI GAIT ANALYSIS

Video Duration: ${video["duration_seconds"] ?? data["duration_seconds"] ?? "N/A"} seconds

Frames Analyzed: ${video["frames_analyzed"] ?? data["frames_analyzed"] ?? "N/A"}
Knee Analysis
• Left Knee: ${gait["left_knee_average_angle"] ?? "N/A"}°
• Right Knee: ${gait["right_knee_average_angle"] ?? "N/A"}°
• Knee Difference: ${gait["knee_difference"] ?? "N/A"}°
• Knee Symmetry: ${gait["knee_symmetry"] ?? "N/A"}

Hip Analysis
• Left Hip: ${gait["left_hip_average_angle"] ?? "N/A"}°
• Right Hip: ${gait["right_hip_average_angle"] ?? "N/A"}°
• Hip Difference: ${gait["hip_difference"] ?? "N/A"}°
• Hip Symmetry: ${gait["hip_symmetry"] ?? "N/A"}

Movement Analysis
• Gait Pattern: ${gait["gait_pattern"] ?? "N/A"}
• Risk Level: ${gait["risk_level"] ?? "N/A"}

⚠ ${data["disclaimer"] ?? "AI screening only. This is not a medical diagnosis."}
""";

          aiLoading = false;
        });
      } else {
        setState(() {
          aiGaitResult =
              "Analysis failed: ${data["message"] ?? "Unknown error"}";
          aiLoading = false;
        });
      }
    } else {
      setState(() {
        aiGaitResult =
            "Backend error (${response.statusCode}):\n${response.body}";
        aiLoading = false;
      });
    }
  } catch (e) {
    if (!mounted) return;

    setState(() {
      aiGaitResult =
          "Could not connect to MEDOC AI backend.\n\n$e";
      aiLoading = false;
    });
  }
}
  Future<void> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();

    final saved = prefs.getString(historyKey);

    if (saved == null) return;

    try {
      final List<dynamic> decoded = jsonDecode(saved);

      setState(() {
        history = decoded
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      });
    } catch (_) {
      // Ignore corrupted local history.
    }
  }

  Future<void> deleteHistoryItem(int index) async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      history.removeAt(index);
    });

    await prefs.setString(historyKey, jsonEncode(history));
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(historyKey);

    setState(() {
      history.clear();
    });
  }

  // ----------------------------------------------------------
  // RESET
  // ----------------------------------------------------------

  void resetAssessment() {
    setState(() {
      walkingVideo = null;

      stableWalking = true;
      normalStepLength = true;
      symmetricalSteps = true;
      normalFootPlacement = true;
      normalArmSwing = true;
      noDraggingFeet = true;
      noLimping = true;
      normalTurning = true;

      balance = "Good";

      pain = false;
      dizziness = false;
      weakness = false;
      numbness = false;

      notesController.clear();
    });
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // ----------------------------------------------------------
  // UI
  // ----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final score = calculateScore();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Gait Analysis"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: "Reset",
            onPressed: resetAssessment,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ------------------------------------------------
            // INTRO
            // ------------------------------------------------
            Card(
              color: Colors.teal.shade50,
              child: const Padding(
                padding: EdgeInsets.all(18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.directions_walk, color: Colors.teal, size: 38),
                    SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        "Gait analysis helps you record simple observations "
                        "about walking pattern, balance, step symmetry and "
                        "movement. It is a screening tool and does not "
                        "diagnose a medical condition.",
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              "AI Gait Analysis",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Card(
              color: Colors.teal.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(Icons.smart_toy, color: Colors.teal, size: 45),

                    const SizedBox(height: 10),

                    const Text(
                      "Get an AI-assisted interpretation "
                      "of the selected gait observations.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15),
                    ),

                    const SizedBox(height: 15),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: aiLoading ? null : runAIGaitAnalysis,
                        icon: aiLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.auto_awesome),
                        label: Text(
                          aiLoading ? "ANALYZING..." : "ANALYZE WITH AI",
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (aiGaitResult.isNotEmpty) ...[
              const SizedBox(height: 15),

              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.smart_toy, color: Colors.teal),
                          SizedBox(width: 10),
                          Text(
                            "MedOC AI Result",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const Divider(height: 25),

                      Text(
                        aiGaitResult,
                        style: const TextStyle(fontSize: 15, height: 1.5),
                      ),

                      const SizedBox(height: 15),

                      const Text(
                        "⚠️ AI screening only — this result is not a medical diagnosis.",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 20),

            // ------------------------------------------------
            // VIDEO
            // ------------------------------------------------
            const Text(
              "Walking Video",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            const Text(
              "For a better assessment, record a short video of the person "
              "walking normally in a safe, well-lit area.",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 12),

            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      walkingVideo == null
                          ? Icons.video_camera_back
                          : Icons.video_file,
                      size: 55,
                      color: Colors.teal,
                    ),

                    const SizedBox(height: 10),

                    Text(
                      walkingVideo == null
                          ? "No walking video selected"
                          : "Video selected",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    if (walkingVideo != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        walkingVideo!.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],

                    const SizedBox(height: 15),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: recordWalkingVideo,
                            icon: const Icon(Icons.videocam),
                            label: const Text("Record"),
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: pickWalkingVideo,
                            icon: const Icon(Icons.video_library),
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

            // ------------------------------------------------
            // GAIT OBSERVATIONS
            // ------------------------------------------------
            const Text(
              "Walking Pattern",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            const Text(
              "Select the observations that describe the person's walking.",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 12),

            _checkItem(
              title: "Walking appears stable",
              subtitle: "No obvious loss of balance while walking.",
              value: stableWalking,
              onChanged: (value) {
                setState(() {
                  stableWalking = value;
                });
              },
            ),

            _checkItem(
              title: "Step length appears normal",
              subtitle: "Steps do not appear unusually short or uneven.",
              value: normalStepLength,
              onChanged: (value) {
                setState(() {
                  normalStepLength = value;
                });
              },
            ),

            _checkItem(
              title: "Steps appear symmetrical",
              subtitle: "Both sides appear to move in a similar pattern.",
              value: symmetricalSteps,
              onChanged: (value) {
                setState(() {
                  symmetricalSteps = value;
                });
              },
            ),

            _checkItem(
              title: "Foot placement appears normal",
              subtitle: "Feet are placed normally without obvious instability.",
              value: normalFootPlacement,
              onChanged: (value) {
                setState(() {
                  normalFootPlacement = value;
                });
              },
            ),

            _checkItem(
              title: "Arm swing appears normal",
              subtitle: "Both arms appear to move naturally while walking.",
              value: normalArmSwing,
              onChanged: (value) {
                setState(() {
                  normalArmSwing = value;
                });
              },
            ),

            _checkItem(
              title: "No obvious foot dragging",
              subtitle: "Feet appear to clear the ground normally.",
              value: noDraggingFeet,
              onChanged: (value) {
                setState(() {
                  noDraggingFeet = value;
                });
              },
            ),

            _checkItem(
              title: "No obvious limping",
              subtitle: "Walking does not show an obvious limp.",
              value: noLimping,
              onChanged: (value) {
                setState(() {
                  noLimping = value;
                });
              },
            ),

            _checkItem(
              title: "Turning appears controlled",
              subtitle:
                  "The person can change direction without obvious instability.",
              value: normalTurning,
              onChanged: (value) {
                setState(() {
                  normalTurning = value;
                });
              },
            ),

            const SizedBox(height: 25),

            // ------------------------------------------------
            // BALANCE
            // ------------------------------------------------
            const Text(
              "Balance",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    RadioListTile<String>(
                      title: const Text("Good"),
                      subtitle: const Text("Walking appears steady."),
                      value: "Good",
                      groupValue: balance,
                      onChanged: (value) {
                        setState(() {
                          balance = value!;
                        });
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text("Fair"),
                      subtitle: const Text(
                        "Some instability or hesitation is noticed.",
                      ),
                      value: "Fair",
                      groupValue: balance,
                      onChanged: (value) {
                        setState(() {
                          balance = value!;
                        });
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text("Poor"),
                      subtitle: const Text(
                        "Significant difficulty maintaining balance.",
                      ),
                      value: "Poor",
                      groupValue: balance,
                      onChanged: (value) {
                        setState(() {
                          balance = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            // ------------------------------------------------
            // SYMPTOMS
            // ------------------------------------------------
            const Text(
              "Symptoms During Walking",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            _checkItem(
              title: "Pain",
              subtitle: "Pain occurs while walking or moving.",
              value: pain,
              valueColor: Colors.red,
              onChanged: (value) {
                setState(() {
                  pain = value;
                });
              },
            ),

            _checkItem(
              title: "Dizziness",
              subtitle: "Dizziness or light-headedness is noticed.",
              value: dizziness,
              valueColor: Colors.orange,
              onChanged: (value) {
                setState(() {
                  dizziness = value;
                });
              },
            ),

            _checkItem(
              title: "Weakness",
              subtitle: "A feeling of weakness affects walking.",
              value: weakness,
              valueColor: Colors.deepOrange,
              onChanged: (value) {
                setState(() {
                  weakness = value;
                });
              },
            ),

            _checkItem(
              title: "Numbness",
              subtitle: "Reduced sensation or numbness is noticed.",
              value: numbness,
              valueColor: Colors.purple,
              onChanged: (value) {
                setState(() {
                  numbness = value;
                });
              },
            ),

            const SizedBox(height: 25),

            // ------------------------------------------------
            // SCORE
            // ------------------------------------------------
            const Text(
              "Gait Screening Score",
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
                              color: getScoreColor(score),
                              backgroundColor: Colors.grey.shade300,
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "$score",
                                style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: getScoreColor(score),
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
                      getScoreLabel(score),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: getScoreColor(score),
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      "This score is a simple screening indicator based "
                      "on the selected observations. It is not a diagnosis.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ------------------------------------------------
            // WARNING
            // ------------------------------------------------
            if (score < 65 || balance == "Poor" || dizziness)
              Card(
                color: Colors.red.shade50,
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.warning_amber, color: Colors.red, size: 30),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Some observations may need attention. If walking "
                          "difficulty is sudden, severe, worsening, or "
                          "associated with serious symptoms, seek medical "
                          "assessment promptly.",
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // ------------------------------------------------
            // NOTES
            // ------------------------------------------------
            const Text(
              "Notes",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: notesController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: "Add observations or additional information...",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
              ),
            ),

            const SizedBox(height: 25),

            // ------------------------------------------------
            // SAVE
            // ------------------------------------------------
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: loading
                    ? null
                    : () async {
                        setState(() {
                          loading = true;
                        });

                        await saveAssessment();

                        if (mounted) {
                          setState(() {
                            loading = false;
                          });
                        }
                      },
                icon: loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  loading ? "SAVING..." : "SAVE ASSESSMENT",
                  style: const TextStyle(
                    fontSize: 17,
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

            const SizedBox(height: 30),

            // ------------------------------------------------
            // HISTORY
            // ------------------------------------------------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Assessment History",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                if (history.isNotEmpty)
                  TextButton(
                    onPressed: clearHistory,
                    child: const Text(
                      "Clear All",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 10),

            if (history.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Column(
                      children: const [
                        Icon(Icons.history, size: 45, color: Colors.grey),
                        SizedBox(height: 8),
                        Text(
                          "No previous assessments",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              ...List.generate(history.length, (index) {
                final item = history[index];

                final int itemScore = (item["score"] as num?)?.toInt() ?? 0;

                final String date = formatDate(item["date"]?.toString() ?? "");

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: getScoreColor(itemScore).withAlpha(30),
                      child: Icon(
                        Icons.directions_walk,
                        color: getScoreColor(itemScore),
                      ),
                    ),
                    title: Text(
                      "$itemScore/100 • ${item["result"] ?? ""}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "$date\nBalance: ${item["balance"] ?? "Unknown"}",
                    ),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => deleteHistoryItem(index),
                    ),
                  ),
                );
              }),

            const SizedBox(height: 25),

            // ------------------------------------------------
            // DISCLAIMER
            // ------------------------------------------------
            Card(
              color: Colors.grey.shade100,
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "Important: This feature provides basic observational "
                  "screening only. It does not diagnose neurological, "
                  "musculoskeletal, balance, or other medical conditions. "
                  "Seek professional medical assessment for persistent, "
                  "sudden, severe, or worsening walking problems.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // CHECKBOX WIDGET
  // ----------------------------------------------------------

  Widget _checkItem({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    Color valueColor = Colors.teal,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: CheckboxListTile(
        value: value,
        onChanged: (newValue) {
          onChanged(newValue ?? false);
        },
        activeColor: valueColor,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        secondary: Icon(
          Icons.check_circle_outline,
          color: value ? valueColor : Colors.grey,
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // DATE FORMAT
  // ----------------------------------------------------------

  String formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);

      return "${date.day.toString().padLeft(2, '0')}/"
          "${date.month.toString().padLeft(2, '0')}/"
          "${date.year} "
          "${date.hour.toString().padLeft(2, '0')}:"
          "${date.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return isoDate;
    }
  }
}

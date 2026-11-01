import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DiabeticFootScreen extends StatefulWidget {
  const DiabeticFootScreen({super.key});

  @override
  State<DiabeticFootScreen> createState() => _DiabeticFootScreenState();
}String _formatFootAIResult(Map<String, dynamic> data) {
  final analysis =
      Map<String, dynamic>.from(data["analysis"] ?? data);

  return """
🦶 MEDOC AI FOOT ANALYSIS

AI Result
${analysis["result"] ?? analysis["condition"] ?? "Foot analysis completed"}

Risk Level: ${analysis["risk_level"] ?? "Not available"}

Redness: ${analysis["redness"] ?? "Not detected"}
Swelling: ${analysis["swelling"] ?? "Not detected"}
Wound: ${analysis["wound"] ?? "Not detected"}
Blister: ${analysis["blister"] ?? "Not detected"}
Skin Change: ${analysis["skin_color_change"] ?? "Not detected"}

Recommendation:
${analysis["recommendation"] ?? "Continue monitoring and seek professional advice for concerning changes."}

⚠ AI screening only. This is not a medical diagnosis.
""";
}

class _DiabeticFootScreenState extends State<DiabeticFootScreen> {
  static const String historyKey = 'diabetic_foot_history';

  final ImagePicker _picker = ImagePicker();

  File? footImage;
  bool aiLoading = false;
  String aiFootResult = "";
  bool redness = false;
  bool swelling = false;
  bool wound = false;
  bool blister = false;
  bool skinColorChange = false;

  List<Map<String, dynamic>> history = [];

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  // ============================================================
  // LOAD HISTORY
  // ============================================================

  Future<void> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();

    final savedHistory = prefs.getStringList(historyKey);

    if (savedHistory == null) {
      return;
    }

    final loaded = savedHistory.map((item) {
      return Map<String, dynamic>.from(jsonDecode(item) as Map);
    }).toList();

    if (!mounted) return;

    setState(() {
      history = loaded;
    });
  }

  // ============================================================
  // SAVE HISTORY
  // ============================================================

  Future<void> saveHistory() async {
    final prefs = await SharedPreferences.getInstance();

    final encoded = history.map((item) {
      return jsonEncode(item);
    }).toList();

    await prefs.setStringList(historyKey, encoded);
  }

  // ============================================================
  // PICK IMAGE FROM GALLERY
  // ============================================================

  Future<void> pickFootPhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() {
        footImage = File(image.path);
      });
    } catch (e) {
      showMessage("Could not select the photo.");
    }
  }

  // ============================================================
  // TAKE PHOTO
  // ============================================================

  Future<void> takeFootPhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() {
        footImage = File(image.path);
      });
    } catch (e) {
      showMessage("Could not take the photo.");
    }
  }

  // ============================================================
  // CHECK WHETHER ANY WARNING SIGN EXISTS
  // ============================================================

  bool get hasWarningSigns {
    return redness || swelling || wound || blister || skinColorChange;
  }

  // ============================================================
  // SAVE CURRENT CHECK
  // ============================================================

  Future<void> saveCurrentCheck() async {
    final now = DateTime.now();

    final record = <String, dynamic>{
      "date": now.toIso8601String(),
      "hasPhoto": footImage != null,
      "photoPath": footImage?.path ?? "",
      "redness": redness,
      "swelling": swelling,
      "wound": wound,
      "blister": blister,
      "skinColorChange": skinColorChange,
      "hasWarningSigns": hasWarningSigns,
    };

    setState(() {
      history.insert(0, record);
    });

    await saveHistory();

    if (!mounted) return;

    showMessage("Foot check saved successfully.");

    resetCurrentCheck();
  }

  // ============================================================
  // RESET CURRENT CHECK
  // ============================================================

  void resetCurrentCheck() {
    setState(() {
      footImage = null;
      redness = false;
      swelling = false;
      wound = false;
      blister = false;
      skinColorChange = false;
    });
  }

  // ============================================================
  // DELETE ONE HISTORY ITEM
  // ============================================================

  Future<void> deleteHistoryItem(int index) async {
    setState(() {
      history.removeAt(index);
    });

    await saveHistory();

    if (!mounted) return;

    showMessage("History item deleted.");
  }

  // ============================================================
  // CLEAR ALL HISTORY
  // ============================================================

  Future<void> clearAllHistory() async {
    if (history.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Clear History"),
          content: const Text(
            "Are you sure you want to delete all diabetic foot "
            "monitoring history?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text("CANCEL"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text("CLEAR"),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    setState(() {
      history.clear();
    });

    await saveHistory();

    if (!mounted) return;

    showMessage("All history cleared.");
  }

Future<void> runAIFootAnalysis() async {
  if (footImage == null) {
    showMessage("Please take or select a foot photo first.");
    return;
  }

  setState(() {
    aiLoading = true;
    aiFootResult = "";
  });

  try {
    // Replace with YOUR computer's IPv4 address.
    const String backendUrl =
        "http://YOUR_PC_IP:8000/analyze-foot";

    final request = http.MultipartRequest(
      "POST",
      Uri.parse(backendUrl),
    );

    request.files.add(
      await http.MultipartFile.fromPath(
        "image",
        footImage!.path,
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (!mounted) return;

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      setState(() {
        aiFootResult = _formatFootAIResult(data);
        aiLoading = false;
      });
    } else {
      setState(() {
        aiFootResult =
            "AI backend error (${response.statusCode}):\n${response.body}";
        aiLoading = false;
      });
    }
  } catch (e) {
    if (!mounted) return;

    setState(() {
      aiFootResult =
          "Could not connect to MEDOC Foot AI backend.\n\n$e";
      aiLoading = false;
    });
  }
}
  // ============================================================
  // CHECK FOOT
  // ============================================================

  Future<void> checkFoot() async {
    if (footImage == null &&
        !redness &&
        !swelling &&
        !wound &&
        !blister &&
        !skinColorChange) {
      showMessage("Please add a photo or select at least one observation.");
      return;
    }

    await saveCurrentCheck();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                hasWarningSigns
                    ? Icons.warning_amber_rounded
                    : Icons.check_circle,
                color: hasWarningSigns ? Colors.orange : Colors.green,
              ),
              const SizedBox(width: 10),
              const Expanded(child: Text("Foot Check Result")),
            ],
          ),
          content: Text(
            hasWarningSigns
                ? "One or more warning signs were selected. "
                      "This app cannot diagnose the cause. If there is "
                      "a wound, increasing redness, swelling, discharge, "
                      "severe pain, or another concerning change, seek "
                      "medical attention."
                : "No warning signs were selected. Continue regular "
                      "foot checks and seek medical advice if you notice "
                      "new or worsening changes.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // ============================================================
  // FORMAT DATE
  // ============================================================

  String formatDate(String? dateString) {
    if (dateString == null) return "";

    final date = DateTime.tryParse(dateString);

    if (date == null) return "";

    String twoDigits(int value) {
      return value.toString().padLeft(2, "0");
    }

    return "${twoDigits(date.day)}/"
        "${twoDigits(date.month)}/"
        "${date.year} "
        "${twoDigits(date.hour)}:"
        "${twoDigits(date.minute)}";
  }

  // ============================================================
  // WARNING LIST
  // ============================================================

  List<String> getWarningList(Map<String, dynamic> item) {
    final warnings = <String>[];

    if (item["redness"] == true) {
      warnings.add("Redness");
    }

    if (item["swelling"] == true) {
      warnings.add("Swelling");
    }

    if (item["wound"] == true) {
      warnings.add("Wound");
    }

    if (item["blister"] == true) {
      warnings.add("Blister");
    }

    if (item["skinColorChange"] == true) {
      warnings.add("Skin color change");
    }

    return warnings;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Diabetic Foot Monitoring"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: "History",
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DiabeticFootHistoryScreen(
                    history: history,
                    onDelete: deleteHistoryItem,
                    onClearAll: clearAllHistory,
                  ),
                ),
              );
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // ==================================================
            // INFORMATION CARD
            // ==================================================
            Card(
              color: Colors.teal.shade50,

              child: const Padding(
                padding: EdgeInsets.all(16),

                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Icon(Icons.info_outline, color: Colors.teal, size: 30),

                    SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        "Regularly checking the feet can help you notice "
                        "visible changes early. You can take a photo and "
                        "record observations for personal monitoring.",
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            // ==================================================
            // PHOTO SECTION
            // ==================================================
            const Text(
              "Foot Photo",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              height: 280,

              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade300),
              ),

              child: footImage == null
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [
                        Icon(
                          Icons.image_outlined,
                          size: 70,
                          color: Colors.grey,
                        ),

                        SizedBox(height: 12),

                        Text(
                          "No foot photo selected",
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(20),

                      child: Image.file(
                        footImage!,
                        width: double.infinity,
                        height: 280,
                        fit: BoxFit.contain,
                      ),
                    ),
            ),

            const SizedBox(height: 15),

            // ==================================================
            // PHOTO BUTTONS
            // ==================================================
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: pickFootPhoto,

                    icon: const Icon(Icons.photo_library),

                    label: const Text("Gallery"),

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,

                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: takeFootPhoto,

                    icon: const Icon(Icons.camera_alt),

                    label: const Text("Camera"),

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                      foregroundColor: Colors.white,

                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),const SizedBox(height: 12),

SizedBox(
  width: double.infinity,
  height: 55,
  child: ElevatedButton.icon(
    onPressed: aiLoading ? null : analyzeFootWithAI,
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
  aiLoading ? "ANALYZING..." : "ANALYZE FOOT WITH AI",
  style: const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  ),
), style: ElevatedButton.styleFrom(
      backgroundColor: Colors.deepPurple,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    ),
  ),
),if (aiFootResult.isNotEmpty) ...[
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
              Icon(Icons.smart_toy, color: Colors.deepPurple),
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
            aiFootResult,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    ),
  ),
],


            const SizedBox(height: 30),

            // ==================================================
            // CHECKLIST
            // ==================================================
            const Text(
              "What do you notice?",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            const Text(
              "Select anything you can visibly notice.",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 12),

            warningCheckBox(
              title: "Redness",
              subtitle: "A noticeably red area of skin",
              value: redness,

              icon: Icons.circle,

              onChanged: (value) {
                setState(() {
                  redness = value ?? false;
                });
              },
            ),

            warningCheckBox(
              title: "Swelling",
              subtitle: "An area appears swollen or enlarged",
              value: swelling,

              icon: Icons.pan_tool_alt,

              onChanged: (value) {
                setState(() {
                  swelling = value ?? false;
                });
              },
            ),

            warningCheckBox(
              title: "Wound",
              subtitle: "A cut, open area, or break in the skin",
              value: wound,

              icon: Icons.healing,

              onChanged: (value) {
                setState(() {
                  wound = value ?? false;
                });
              },
            ),

            warningCheckBox(
              title: "Blister",
              subtitle: "A visible fluid-filled area",
              value: blister,

              icon: Icons.bubble_chart,

              onChanged: (value) {
                setState(() {
                  blister = value ?? false;
                });
              },
            ),

            warningCheckBox(
              title: "Skin color change",
              subtitle: "A noticeable change from the usual appearance",
              value: skinColorChange,

              icon: Icons.color_lens,

              onChanged: (value) {
                setState(() {
                  skinColorChange = value ?? false;
                });
              },
            ),

            const SizedBox(height: 25),

            // ==================================================
            // CHECK BUTTON
            // ==================================================
            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton.icon(
                onPressed: checkFoot,

                icon: const Icon(Icons.health_and_safety),

                label: const Text(
                  "CHECK & SAVE",
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

            const SizedBox(height: 15),

            // ==================================================
            // HISTORY BUTTON
            // ==================================================
            SizedBox(
              width: double.infinity,

              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DiabeticFootHistoryScreen(
                        history: history,
                        onDelete: deleteHistoryItem,
                        onClearAll: clearAllHistory,
                      ),
                    ),
                  );
                },

                icon: const Icon(Icons.history),

                label: Text("VIEW HISTORY (${history.length})"),
              ),
            ),

            const SizedBox(height: 25),

            // ==================================================
            // SAFETY INFORMATION
            // ==================================================
            Card(
              color: Colors.orange.shade50,

              child: const Padding(
                padding: EdgeInsets.all(16),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Colors.orange),

                        SizedBox(width: 8),

                        Text(
                          "Important",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 10),

                    Text(
                      "This feature is for monitoring and education only. "
                      "The photo and checklist do not diagnose an infection, "
                      "ulcer, or other medical condition.",
                      style: TextStyle(fontSize: 14),
                    ),

                    SizedBox(height: 8),

                    Text(
                      "Seek professional medical care for a new or "
                      "worsening wound, significant swelling, severe pain, "
                      "discharge, spreading redness, or other concerning "
                      "changes.",
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
// ============================================================
// ANALYZE FOOT WITH AI BACKEND
// ============================================================

Future<void> analyzeFootWithAI() async {
  if (footImage == null) {
    showMessage("Please select or take a foot photo first.");
    return;
  }

  setState(() {
    aiLoading = true;
    aiFootResult = "";
  });

  try {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://192.168.1.6:8000/analyze-foot'),
    );

    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        footImage!.path,
      ),
    );

    final streamedResponse = await request.send();

    final response = await http.Response.fromStream(streamedResponse);

    print("STATUS: ${response.statusCode}");
    print("RESPONSE: ${response.body}");

    final data = jsonDecode(response.body);

    if (!mounted) return;

    if (response.statusCode == 200 && data["success"] == true) {
      final results = data["results"] ?? {};

      setState(() {
        aiFootResult =
            "AI Analysis Completed\n\n"
            "Skin condition: ${results["skin_condition"] ?? "N/A"}\n\n"
            "Visible abnormality: ${results["visible_abnormality"] ?? "N/A"}\n\n"
            "Swelling indicator: ${results["swelling_indicator"] ?? "N/A"}\n\n"
            "Color change: ${results["color_change"] ?? "N/A"}\n\n"
            "Risk level: ${data["risk_level"] ?? "Unknown"}\n\n"
            "${data["disclaimer"] ?? ""}";
      });
    } else {
      setState(() {
        aiFootResult =
            "AI analysis failed.\n\n${data["detail"] ?? response.body}";
      });
    }
  } catch (e) {
    if (!mounted) return;

    setState(() {
      aiFootResult = "Could not connect to MedOC AI backend.\n\n$e";
    });
  } finally {
    if (mounted) {
      setState(() {
        aiLoading = false;
      });
    }
  }
}  // ============================================================
  // CHECKBOX WIDGET
  // ============================================================

  Widget warningCheckBox({
    required String title,
    required String subtitle,
    required bool value,
    required IconData icon,
    required ValueChanged<bool?> onChanged,
  }) {
    return Card(
      child: CheckboxListTile(
        value: value,

        onChanged: onChanged,

        secondary: Icon(icon, color: Colors.teal),

        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),

        subtitle: Text(subtitle),

        activeColor: Colors.teal,
      ),
    );
  }
}

// ============================================================================
// HISTORY SCREEN
// ============================================================================

class DiabeticFootHistoryScreen extends StatefulWidget {
  final List<Map<String, dynamic>> history;

  final Future<void> Function(int index) onDelete;

  final Future<void> Function() onClearAll;

  const DiabeticFootHistoryScreen({
    super.key,
    required this.history,
    required this.onDelete,
    required this.onClearAll,
  });

  @override
  State<DiabeticFootHistoryScreen> createState() =>
      _DiabeticFootHistoryScreenState();
}

class _DiabeticFootHistoryScreenState extends State<DiabeticFootHistoryScreen> {
  late List<Map<String, dynamic>> localHistory;

  @override
  void initState() {
    super.initState();

    localHistory = List<Map<String, dynamic>>.from(widget.history);
  }

  String formatDate(String? dateString) {
    if (dateString == null) return "";

    final date = DateTime.tryParse(dateString);

    if (date == null) return "";

    String twoDigits(int value) {
      return value.toString().padLeft(2, "0");
    }

    return "${twoDigits(date.day)}/"
        "${twoDigits(date.month)}/"
        "${date.year} "
        "${twoDigits(date.hour)}:"
        "${twoDigits(date.minute)}";
  }

  List<String> getWarnings(Map<String, dynamic> item) {
    final warnings = <String>[];

    if (item["redness"] == true) {
      warnings.add("Redness");
    }

    if (item["swelling"] == true) {
      warnings.add("Swelling");
    }

    if (item["wound"] == true) {
      warnings.add("Wound");
    }

    if (item["blister"] == true) {
      warnings.add("Blister");
    }

    if (item["skinColorChange"] == true) {
      warnings.add("Skin color change");
    }

    return warnings;
  }

  Future<void> deleteItem(int index) async {
    await widget.onDelete(index);

    if (!mounted) return;

    setState(() {
      localHistory.removeAt(index);
    });
  }

  Future<void> clearHistory() async {
    await widget.onClearAll();

    if (!mounted) return;

    setState(() {
      localHistory.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Foot Check History"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,

        actions: [
          if (localHistory.isNotEmpty)
            IconButton(
              tooltip: "Clear history",
              icon: const Icon(Icons.delete_sweep),
              onPressed: clearHistory,
            ),
        ],
      ),

      body: localHistory.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  Icon(Icons.history, size: 80, color: Colors.grey),

                  SizedBox(height: 15),

                  Text(
                    "No foot check history",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  SizedBox(height: 8),

                  Text(
                    "Your saved foot checks will appear here.",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),

              itemCount: localHistory.length,

              itemBuilder: (context, index) {
                final item = localHistory[index];

                final warnings = getWarnings(item);

                final hasWarning = item["hasWarningSigns"] == true;

                final photoPath = item["photoPath"]?.toString() ?? "";

                final hasPhoto =
                    item["hasPhoto"] == true && photoPath.isNotEmpty;

                return Card(
                  margin: const EdgeInsets.only(bottom: 15),

                  elevation: 3,

                  child: Padding(
                    padding: const EdgeInsets.all(15),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: hasWarning
                                  ? Colors.orange.shade100
                                  : Colors.green.shade100,

                              child: Icon(
                                hasWarning ? Icons.warning : Icons.check_circle,

                                color: hasWarning
                                    ? Colors.orange
                                    : Colors.green,
                              ),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  Text(
                                    hasWarning
                                        ? "Warning signs recorded"
                                        : "No warning signs",

                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,

                                      fontSize: 16,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  Text(
                                    formatDate(item["date"]?.toString()),

                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),

                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),

                              onPressed: () {
                                deleteItem(index);
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),

                        if (hasPhoto)
                          Container(
                            height: 180,
                            width: double.infinity,

                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),

                              color: Colors.grey.shade100,
                            ),

                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),

                              child: Image.file(
                                File(photoPath),

                                fit: BoxFit.contain,

                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,

                                      children: [
                                        Icon(
                                          Icons.broken_image_outlined,
                                          size: 45,
                                          color: Colors.grey,
                                        ),

                                        SizedBox(height: 5),

                                        Text(
                                          "Photo unavailable",
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),

                        if (hasPhoto) const SizedBox(height: 15),

                        if (warnings.isEmpty)
                          const Text(
                            "✓ No warning signs selected",
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        else
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              const Text(
                                "Observations:",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),

                              const SizedBox(height: 6),

                              ...warnings.map(
                                (warning) => Padding(
                                  padding: const EdgeInsets.only(bottom: 4),

                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.warning_amber,
                                        size: 18,
                                        color: Colors.orange,
                                      ),

                                      const SizedBox(width: 6),

                                      Text(warning),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

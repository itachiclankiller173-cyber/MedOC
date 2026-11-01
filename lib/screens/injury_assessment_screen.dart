import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class InjuryAssessmentScreen extends StatefulWidget {
  const InjuryAssessmentScreen({super.key});

  @override
  State<InjuryAssessmentScreen> createState() => _InjuryAssessmentScreenState();
}

class _InjuryAssessmentScreenState extends State<InjuryAssessmentScreen> {
  final ImagePicker picker = ImagePicker();

  // Windows/Desktop
  // Change this when testing on Android.
  final String baseUrl = "http://127.0.0.1:8000";

  File? selectedImage;

  bool analyzing = false;

  String aiResult = "";

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1600,
      );

      if (image == null) return;

      setState(() {
        selectedImage = File(image.path);
        aiResult = "";
      });
    } catch (e) {
      showMessage("Could not select image: $e");
    }
  }

  Future<void> analyzeInjury() async {
    if (selectedImage == null) {
      showMessage("Please select an injury photo first.");
      return;
    }

    setState(() {
      analyzing = true;
      aiResult = "";
    });

    try {
      final request = http.MultipartRequest(
        "POST",
        Uri.parse("$baseUrl/analyze-injury"),
      );

      request.files.add(
        await http.MultipartFile.fromPath("image", selectedImage!.path),
      );

      final response = await request.send();

      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);

        setState(() {
          aiResult =
              data["analysis"] ??
              data["result"] ??
              data["reply"] ??
              "No assessment returned by the AI.";
        });
      } else {
        setState(() {
          aiResult = "AI server error (${response.statusCode})\n$responseBody";
        });
      }
    } catch (e) {
      setState(() {
        aiResult = "Could not connect to the MedOC AI server.\n\n$e";
      });
    } finally {
      if (mounted) {
        setState(() {
          analyzing = false;
        });
      }
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void clearAssessment() {
    setState(() {
      selectedImage = null;
      aiResult = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Injury Assessment"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // --------------------------------------------------
            // INFORMATION CARD
            // --------------------------------------------------
            Card(
              color: Colors.teal.shade50,

              child: const Padding(
                padding: EdgeInsets.all(16),

                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Icon(Icons.smart_toy, color: Colors.teal, size: 35),

                    SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        "Upload a clear photo of an injury or burn. "
                        "MedOC AI can provide an educational visual assessment "
                        "and suggest whether medical attention may be needed.\n\n"
                        "This does not replace a doctor or emergency medical care.",
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Injury Photo",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            // --------------------------------------------------
            // IMAGE PREVIEW
            // --------------------------------------------------
            Container(
              width: double.infinity,
              height: 280,

              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.grey.shade400),
              ),

              child: selectedImage == null
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [
                        Icon(
                          Icons.image_outlined,
                          size: 70,
                          color: Colors.grey,
                        ),

                        SizedBox(height: 10),

                        Text(
                          "No image selected",
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(18),

                      child: Image.file(selectedImage!, fit: BoxFit.cover),
                    ),
            ),

            const SizedBox(height: 15),

            // --------------------------------------------------
            // IMAGE BUTTONS
            // --------------------------------------------------
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: analyzing
                        ? null
                        : () => pickImage(ImageSource.camera),

                    icon: const Icon(Icons.camera_alt),

                    label: const Text("Camera"),

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: analyzing
                        ? null
                        : () => pickImage(ImageSource.gallery),

                    icon: const Icon(Icons.photo_library),

                    label: const Text("Gallery"),

                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // --------------------------------------------------
            // ANALYZE BUTTON
            // --------------------------------------------------
            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton.icon(
                onPressed: selectedImage == null || analyzing
                    ? null
                    : analyzeInjury,

                icon: analyzing
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.auto_awesome),

                label: Text(
                  analyzing ? "Analyzing Image..." : "ANALYZE WITH MEDOC AI",
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

            const SizedBox(height: 20),

            // --------------------------------------------------
            // AI RESULT
            // --------------------------------------------------
            if (aiResult.isNotEmpty)
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
                            "MedOC AI Assessment",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const Divider(height: 25),

                      Text(
                        aiResult,
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),

                      const SizedBox(height: 20),

                      Container(
                        padding: const EdgeInsets.all(12),

                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),

                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Icon(Icons.warning_amber, color: Colors.orange),

                            SizedBox(width: 10),

                            Expanded(
                              child: Text(
                                "AI image analysis can be inaccurate. "
                                "Do not rely on this result for an emergency "
                                "or serious injury. Seek professional medical "
                                "care when needed.",
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 15),

                      SizedBox(
                        width: double.infinity,

                        child: OutlinedButton.icon(
                          onPressed: clearAssessment,

                          icon: const Icon(Icons.refresh),

                          label: const Text("New Assessment"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 25),

            // --------------------------------------------------
            // EMERGENCY CARD
            // --------------------------------------------------
            Card(
              color: Colors.red.shade50,

              child: const Padding(
                padding: EdgeInsets.all(16),

                child: Column(
                  children: [
                    Icon(Icons.emergency, color: Colors.red, size: 40),

                    SizedBox(height: 8),

                    Text(
                      "Emergency Warning",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 8),

                    Text(
                      "For severe bleeding, difficulty breathing, "
                      "loss of consciousness, serious burns, major "
                      "accidents, severe pain, or other life-threatening "
                      "situations, seek emergency medical help immediately.",
                      textAlign: TextAlign.center,
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
}

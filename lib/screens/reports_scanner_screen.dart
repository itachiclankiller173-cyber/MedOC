import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../services/patient_service.dart';
import '../services/ai_service.dart';
import '../services/firestore_service.dart';
import '../services/ocr_service.dart';

class ReportScannerScreen extends StatefulWidget {
  const ReportScannerScreen({super.key});

  @override
  State<ReportScannerScreen> createState() => _ReportScannerScreenState();
}

class _ReportScannerScreenState extends State<ReportScannerScreen> {
  final FirestoreService firestore = FirestoreService();

  final AIService aiService = AIService();
  final ImagePicker picker = ImagePicker();

  final OCRService ocrService = OCRService();

  File? selectedImage;

  String extractedText = "";
  bool patientLoaded = false;
  String? fileName;
  String patientId = "";

  bool loading = false;

  String result = "";

  List<Map<String, dynamic>> reports = [];

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    final patient = await PatientService().getSelectedPatient();

    if (patient != null) {
      patientId = patient.id;
      await loadReports();
    }

    setState(() {
      patientLoaded = true;
    });
  }

  Future<void> loadReports() async {
    if (patientId.isEmpty) return;

    final data = await firestore.getReports(patientId);

    reports = data.docs.map((e) => e.data()).toList();

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> pickReport() async {
    final file = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ["pdf", "jpg", "jpeg", "png"],
    );

    if (file == null) return;

    setState(() {
      fileName = file.files.single.name;
    });

    if (file.files.single.path != null) {
      final path = file.files.single.path!;

      if (path.endsWith(".jpg") ||
          path.endsWith(".jpeg") ||
          path.endsWith(".png")) {
        selectedImage = File(path);

        await scanImage();
      }
    }
  }

  Future<void> pickImageFromGallery() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    selectedImage = File(image.path);

    setState(() {});
  }

  Future<void> scanImage() async {
    if (selectedImage == null) return;

    setState(() {
      loading = true;
    });

    final inputImage = InputImage.fromFile(selectedImage!);

    extractedText = await ocrService.recognizeText(inputImage);

    setState(() {
      loading = false;
    });
  }

  Future<void> analyzeReport() async {
    if (fileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a report first")),
      );

      return;
    }

    setState(() {
      loading = true;
    });

    final response = await aiService.analyzeMedicalReport(extractedText);

    final patient = await PatientService().getSelectedPatient();

    if (patient == null) return;

    await firestore.saveReport(
      patientId: patientId,
      fileName: fileName!,
      reportType: "Medical Report",
      aiResult: response,
    );

    await loadReports();

    setState(() {
      result = response;

      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!patientLoaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (patientId.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Medical Report Scanner"),
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: Text("Please select a patient first.")),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Medical Report Scanner"),

        backgroundColor: Colors.teal,

        foregroundColor: Colors.white,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            const Icon(Icons.description, size: 90, color: Colors.teal),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: pickReport,

              icon: const Icon(Icons.upload_file),

              label: const Text("Select Report"),

              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,

                foregroundColor: Colors.white,
              ),
            ),

            const SizedBox(height: 20),

            if (fileName != null)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.file_present),

                  title: Text(fileName!),
                ),
              ),
            const SizedBox(height: 15),

            if (selectedImage != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.file(
                  selectedImage!,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

            const SizedBox(height: 15),

            if (extractedText.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(extractedText),
                ),
              ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,

              height: 55,

              child: ElevatedButton(
                onPressed: analyzeReport,

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,

                  foregroundColor: Colors.white,
                ),

                child: const Text(
                  "ANALYZE REPORT",

                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 20),

            if (loading) const CircularProgressIndicator(),

            if (!loading && result.isNotEmpty)
              Card(
                elevation: 4,

                child: Padding(
                  padding: const EdgeInsets.all(15),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      const Text(
                        "AI Explanation",

                        style: TextStyle(
                          fontWeight: FontWeight.bold,

                          fontSize: 18,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(result),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 20),

            const Align(
              alignment: Alignment.centerLeft,

              child: Text(
                "Previous Reports",

                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: reports.isEmpty
                  ? const Center(child: Text("No Reports Found"))
                  : ListView.builder(
                      itemCount: reports.length,

                      itemBuilder: (context, index) {
                        final report = reports[index];

                        return Card(
                          child: ListTile(
                            leading: const Icon(
                              Icons.description,

                              color: Colors.teal,
                            ),

                            title: Text(report["fileName"] ?? ""),

                            subtitle: Text(
                              report["aiResult"] ?? "",

                              maxLines: 2,

                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

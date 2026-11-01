import 'dart:convert';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../services/ocr_service.dart';
import '../services/voice_service.dart';
import '../widgets/ai_message.dart';
import '../widgets/typing_indicator.dart';
import '../widgets/user_message.dart';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final VoiceService voice = VoiceService();
  final OCRService ocrService = OCRService();

  final TextEditingController controller = TextEditingController();
  final ScrollController scrollController = ScrollController();

  final Map<String, String> languages = {
    "English": "en-IN",
    "Malayalam": "ml-IN",
    "Hindi": "hi-IN",
    "Tamil": "ta-IN",
  };

  bool listening = false;
  bool typing = false;

  String selectedLanguage = "en-IN";

  final List<Map<String, String>> messages = [
    {"sender": "AI", "text": "Hello! I'm MedOC AI.\nHow can I help you today?"},
  ];

  @override
  void initState() {
    super.initState();
    initializeVoice();
  }

  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();
    voice.stopListening();
    voice.stopSpeaking();
    ocrService.dispose();
    super.dispose();
  }

  Future<void> initializeVoice() async {
    await voice.initialize();

    if (!mounted) return;

    setState(() {
      selectedLanguage = voice.languageCode;
    });
  }

  // ============================================================
  // UPLOAD AND ANALYZE MEDICAL REPORT
  // ============================================================

  Future<void> pickAndUploadReport() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ["pdf", "txt", "jpg", "jpeg", "png"],
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      final file = result.files.single;

      if (file.bytes == null) {
        throw Exception("Could not read the selected file.");
      }

      final fileName = file.name;

      setState(() {
        messages.add({
          "sender": "You",
          "text": "📄 Uploaded medical report: $fileName",
        });

        typing = true;
      });

      scrollToBottom();

      final request = http.MultipartRequest(
        "POST",
        Uri.parse("${ApiConfig.baseUrl}/analyze-report"),
      );

      request.files.add(
        http.MultipartFile.fromBytes("file", file.bytes!, filename: fileName),
      );

      final streamedResponse = await request.send();

      final response = await http.Response.fromStream(streamedResponse);

      debugPrint("REPORT STATUS: ${response.statusCode}");

      debugPrint("REPORT RESPONSE: ${response.body}");

      if (!mounted) return;

      Map<String, dynamic> data = {};

      try {
        data = jsonDecode(response.body);
      } catch (_) {
        data = {};
      }

      String reply;

      if (response.statusCode == 200 && data["success"] == true) {
        reply =
            data["reply"]?.toString() ??
            data["analysis"]?.toString() ??
            data["message"]?.toString() ??
            "The report was uploaded, but no analysis was returned.";
      } else {
        reply =
            data["error"]?.toString() ??
            "Unable to analyze the medical report.";
      }

      setState(() {
        typing = false;

        messages.add({"sender": "AI", "text": reply});
      });

      if (response.statusCode == 200) {
        await voice.speak(reply, languageCode: selectedLanguage);
      }
    } catch (e) {
      debugPrint("REPORT UPLOAD ERROR: $e");

      if (!mounted) return;

      setState(() {
        typing = false;

        messages.add({"sender": "AI", "text": "Report upload error: $e"});
      });
    }

    scrollToBottom();
  }

  // ============================================================
  // CHANGE LANGUAGE
  // ============================================================

  Future<void> selectLanguage(String languageCode) async {
    await voice.changeLanguage(languageCode);

    if (!mounted) return;

    final languageName = languages.entries
        .firstWhere(
          (entry) => entry.value == languageCode,
          orElse: () => const MapEntry("English", "en-IN"),
        )
        .key;

    setState(() {
      selectedLanguage = languageCode;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Language changed to $languageName")),
    );
  }

  // ============================================================
  // SCROLL
  // ============================================================

  void scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ============================================================
  // SEND CHAT MESSAGE
  // ============================================================

  Future<void> sendMessage() async {
    if (controller.text.trim().isEmpty || typing) {
      return;
    }

    final userMessage = controller.text.trim();

    setState(() {
      messages.add({"sender": "You", "text": userMessage});

      typing = true;
    });

    controller.clear();

    scrollToBottom();

    try {
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/chat"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "message": userMessage,
          "language": selectedLanguage,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final reply =
            data["reply"]?.toString() ??
            "Sorry, I could not generate a response.";

        setState(() {
          typing = false;

          messages.add({"sender": "AI", "text": reply});
        });

        await voice.speak(reply, languageCode: selectedLanguage);
      } else {
        setState(() {
          typing = false;

          messages.add({"sender": "AI", "text": "Server Error"});
        });
      }
    } catch (e) {
      debugPrint("BACKEND ERROR: $e");

      if (!mounted) return;

      setState(() {
        typing = false;

        messages.add({
          "sender": "AI",
          "text": "Cannot connect to MedOC backend.\n\nError: $e",
        });
      });
    }

    scrollToBottom();
  }

  // ============================================================
  // START VOICE
  // ============================================================

  Future<void> startVoice() async {
    setState(() {
      listening = true;
    });

    await voice.startListening((text) {
      if (!mounted) return;

      setState(() {
        controller.text = text;
      });
    }, languageCode: selectedLanguage);

    if (!mounted) return;

    setState(() {
      listening = false;
    });
  }

  // ============================================================
  // STOP VOICE
  // ============================================================

  Future<void> stopVoice() async {
    await voice.stopListening();

    if (!mounted) return;

    setState(() {
      listening = false;
    });

    if (controller.text.trim().isNotEmpty) {
      await sendMessage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedLanguageName = languages.entries
        .firstWhere(
          (entry) => entry.value == selectedLanguage,
          orElse: () => const MapEntry("English", "en-IN"),
        )
        .key;

    return Scaffold(
      appBar: AppBar(
        title: const Text("MedOC AI"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,

        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.language),

            onSelected: selectLanguage,

            itemBuilder: (context) {
              return languages.entries.map((entry) {
                return PopupMenuItem<String>(
                  value: entry.value,

                  child: Row(
                    children: [
                      Icon(
                        selectedLanguage == entry.value
                            ? Icons.check_circle
                            : Icons.language,
                        color: selectedLanguage == entry.value
                            ? Colors.teal
                            : Colors.grey,
                      ),

                      const SizedBox(width: 12),

                      Text(entry.key),
                    ],
                  ),
                );
              }).toList();
            },
          ),
        ],
      ),

      body: Column(
        children: [
          // Language indicator
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.teal.withValues(alpha: 0.08),

            child: Row(
              children: [
                const Icon(Icons.language, color: Colors.teal, size: 18),

                const SizedBox(width: 8),

                Text(
                  "Language: $selectedLanguageName",
                  style: const TextStyle(
                    color: Colors.teal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Messages
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length + (typing ? 1 : 0),

              itemBuilder: (context, index) {
                if (typing && index == messages.length) {
                  return const TypingIndicator();
                }

                final message = messages[index];

                if (message["sender"] == "AI") {
                  return AIMessage(text: message["text"]!);
                }

                return UserMessage(text: message["text"]!);
              },
            ),
          ),

          // Input area
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),

            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
            ),

            child: Row(
              children: [
                // Upload report
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  color: Colors.teal,
                  tooltip: "Upload PDF Medical Report",

                  onPressed: typing
                      ? null
                      : () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return SafeArea(
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.description,
                                        size: 45,
                                        color: Colors.teal,
                                      ),

                                      const SizedBox(height: 12),

                                      const Text(
                                        "Upload Medical Report",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      const SizedBox(height: 8),

                                      const Text(
                                        "Supported: PDF, TXT, JPG, JPEG and PNG",
                                        textAlign: TextAlign.center,
                                      ),

                                      const SizedBox(height: 20),

                                      ElevatedButton.icon(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          pickAndUploadReport();
                                        },
                                        icon: const Icon(Icons.upload_file),
                                        label: const Text(
                                          "Select Medical Report",
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                ),
                // Voice
                AvatarGlow(
                  animate: listening,
                  glowColor: Colors.teal,
                  duration: const Duration(milliseconds: 1500),
                  repeat: true,

                  child: IconButton(
                    icon: Icon(
                      listening ? Icons.mic : Icons.mic_none,
                      color: Colors.teal,
                    ),

                    onPressed: () async {
                      if (listening) {
                        await stopVoice();
                      } else {
                        await startVoice();
                      }
                    },
                  ),
                ),

                // Text input
                Expanded(
                  child: TextField(
                    controller: controller,
                    minLines: 1,
                    maxLines: 5,

                    onSubmitted: (_) {
                      sendMessage();
                    },

                    decoration: InputDecoration(
                      hintText: "Ask MedOC AI anything...",
                      filled: true,
                      fillColor: Colors.grey.shade100,

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),

                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Send button
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.teal,

                  child: IconButton(
                    icon: const Icon(Icons.send),
                    color: Colors.white,

                    onPressed: typing ? null : sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

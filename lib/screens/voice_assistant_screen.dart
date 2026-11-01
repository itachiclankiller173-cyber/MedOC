import 'package:flutter/material.dart';
import '../widgets/siri_wave.dart';
import '../widgets/siri_orb.dart';
import '../services/voice_service.dart';
import '../services/ai_service.dart';
import '../widgets/glowing_mic.dart';

class VoiceAssistantScreen extends StatefulWidget {
  const VoiceAssistantScreen({super.key});

  @override
  State<VoiceAssistantScreen> createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends State<VoiceAssistantScreen>
    with SingleTickerProviderStateMixin {
  final VoiceService voice = VoiceService();

  final AIService ai = AIService();

  late AnimationController controller;

  bool listening = false;

  String userText = "Tap the microphone";

  String aiReply = "";

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
      lowerBound: 0.8,
      upperBound: 1.2,
    );

    initializeVoice();
  }

  Future<void> initializeVoice() async {
    await voice.initialize();
  }

  Future<void> startListening() async {
    if (listening) return;

    setState(() {
      listening = true;
      aiReply = "";
    });

    controller.repeat(reverse: true);

    await voice.startListening((text) async {
      if (text.isEmpty) return;

      setState(() {
        userText = text;
      });

      final response = await ai.analyzeMedicalReport(text);

      setState(() {
        aiReply = response;
      });

      await voice.speak(response);
    });
  }

  Future<void> stopListening() async {
    await voice.stopListening();

    controller.stop();

    controller.reset();

    setState(() {
      listening = false;
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Widget buildMic() {
    return Column(
      children: [
        ScaleTransition(
          scale: controller,
          child: CircleAvatar(
            radius: 55,
            backgroundColor: listening ? Colors.red : Colors.teal,

            child: IconButton(
              iconSize: 55,

              color: Colors.white,

              icon: Icon(listening ? Icons.mic : Icons.mic_none),

              onPressed: () {
                if (listening) {
                  stopListening();
                } else {
                  startListening();
                }
              },
            ),
          ),
        ),

        const SizedBox(height: 15),

        Text(
          listening ? "Listening..." : "Tap Microphone",

          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Voice Assistant"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            const SizedBox(height: 30),

            Stack(
              alignment: Alignment.center,
              children: [
                SiriWave(listening: listening),

                SiriOrb(listening: listening),

                GlowingMic(
                  listening: listening,
                  onTap: () {
                    if (listening) {
                      stopListening();
                    } else {
                      startListening();
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 25),

            Text(
              listening ? "🎤 Listening..." : "Tap the microphone",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: listening ? Colors.red : Colors.teal,
              ),
            ),

            const SizedBox(height: 30),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const Text(
                      "You",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 10),

                    Text(userText),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: Card(
                elevation: 5,

                child: Padding(
                  padding: const EdgeInsets.all(16),

                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        const Text(
                          "MedOC AI",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),

                        const SizedBox(height: 15),

                        Text(
                          aiReply.isEmpty ? "Waiting..." : aiReply,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

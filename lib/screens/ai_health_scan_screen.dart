import 'package:flutter/material.dart';

class AIHealthScanScreen extends StatelessWidget {
  const AIHealthScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> scans = [
      {"title": "Eye", "icon": Icons.remove_red_eye, "color": Colors.blue},

      {"title": "Ear", "icon": Icons.hearing, "color": Colors.orange},

      {"title": "Mouth", "icon": Icons.masks, "color": Colors.red},

      {"title": "Tongue", "icon": Icons.face, "color": Colors.pink},

      {
        "title": "Teeth",
        "icon": Icons.sentiment_satisfied,
        "color": Colors.cyan,
      },

      {"title": "Nails", "icon": Icons.back_hand, "color": Colors.purple},

      {"title": "Skin", "icon": Icons.health_and_safety, "color": Colors.green},

      {"title": "Hair", "icon": Icons.content_cut, "color": Colors.brown},

      {
        "title": "Foot",
        "icon": Icons.accessibility_new,
        "color": Colors.indigo,
      },

      {"title": "Hand", "icon": Icons.pan_tool, "color": Colors.teal},

      {"title": "Wound", "icon": Icons.healing, "color": Colors.deepOrange},

      {"title": "Mole", "icon": Icons.circle, "color": Colors.grey},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Health Scan"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),

      body: GridView.builder(
        padding: const EdgeInsets.all(16),

        itemCount: scans.length,

        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 1,
        ),

        itemBuilder: (context, index) {
          final item = scans[index];

          return Card(
            elevation: 6,

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),

            child: InkWell(
              borderRadius: BorderRadius.circular(20),

              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("${item["title"]} Analysis coming soon"),
                  ),
                );
              },

              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  Icon(item["icon"], size: 55, color: item["color"]),

                  const SizedBox(height: 15),

                  Text(
                    item["title"],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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

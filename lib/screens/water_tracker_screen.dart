import 'package:flutter/material.dart';

class WaterTrackerScreen extends StatefulWidget {
  const WaterTrackerScreen({super.key});

  @override
  State<WaterTrackerScreen> createState() => _WaterTrackerScreenState();
}

class _WaterTrackerScreenState extends State<WaterTrackerScreen> {
  int glasses = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Water Intake"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.water_drop, color: Colors.blue, size: 120),

            const SizedBox(height: 20),

            const Text(
              "Today's Water Intake",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 25),

            Text(
              "$glasses Glasses",
              style: const TextStyle(
                fontSize: 45,
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 35),

            LinearProgressIndicator(
              value: glasses / 8,
              minHeight: 12,
              backgroundColor: Colors.grey.shade300,
              color: Colors.blue,
            ),

            const SizedBox(height: 10),

            Text(
              "$glasses / 8 Daily Goal",
              style: const TextStyle(fontSize: 18),
            ),

            const Spacer(),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (glasses > 0) {
                        setState(() {
                          glasses--;
                        });
                      }
                    },
                    icon: const Icon(Icons.remove),
                    label: const Text("Remove"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        glasses++;
                      });
                    },
                    icon: const Icon(Icons.add),
                    label: const Text("Add Glass"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

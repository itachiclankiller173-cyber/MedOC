import 'package:flutter/material.dart';

class HealthAnalyticsScreen extends StatelessWidget {
  const HealthAnalyticsScreen({super.key});

  Widget healthTile(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Health Analytics"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Today's Health Summary",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          healthTile("Heart Rate", "72 BPM", Icons.favorite, Colors.red),

          healthTile("Blood Pressure", "120/80", Icons.bloodtype, Colors.blue),

          healthTile("Temperature", "36.8°C", Icons.thermostat, Colors.orange),

          healthTile("SpO₂", "98%", Icons.monitor_heart, Colors.green),

          const SizedBox(height: 30),

          Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: Container(
              height: 250,
              alignment: Alignment.center,
              child: const Text(
                "📈 Health Graph\n\n(Graphs will be added later)",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

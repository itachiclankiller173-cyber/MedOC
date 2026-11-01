import 'package:flutter/material.dart';

class LiveMonitorScreen extends StatelessWidget {
  const LiveMonitorScreen({super.key});

  Widget healthCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Live Health Monitor"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          healthCard("Heart Rate", "72 BPM", Icons.favorite, Colors.red),

          const SizedBox(height: 15),

          healthCard("SpO₂", "98 %", Icons.monitor_heart, Colors.green),

          const SizedBox(height: 15),

          healthCard(
            "Body Temperature",
            "36.8 °C",
            Icons.thermostat,
            Colors.orange,
          ),

          const SizedBox(height: 15),

          healthCard(
            "Blood Pressure",
            "120 / 80",
            Icons.bloodtype,
            Colors.blue,
          ),

          const SizedBox(height: 30),

          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.refresh),
            label: const Text("Refresh Sensor Data"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 55),
            ),
          ),
        ],
      ),
    );
  }
}

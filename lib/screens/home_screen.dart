import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("MedOC"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          children: const [
            DashboardCard(
              icon: Icons.favorite,
              title: "Heart Rate",
              color: Colors.red,
            ),
            DashboardCard(
              icon: Icons.thermostat,
              title: "Temperature",
              color: Colors.orange,
            ),
            DashboardCard(
              icon: Icons.bloodtype,
              title: "Blood Pressure",
              color: Colors.blue,
            ),
            DashboardCard(
              icon: Icons.monitor_heart,
              title: "SpO₂",
              color: Colors.green,
            ),
            DashboardCard(
              icon: Icons.history,
              title: "History",
              color: Colors.purple,
            ),
            DashboardCard(
              icon: Icons.smart_toy,
              title: "AI Assistant",
              color: Colors.teal,
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const DashboardCard({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {},
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 55, color: color),
            const SizedBox(height: 15),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

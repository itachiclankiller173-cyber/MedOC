import 'package:flutter/material.dart';

import '../services/firestore_service.dart';

class DashboardStatistics extends StatefulWidget {
  final String patientId;

  const DashboardStatistics({super.key, required this.patientId});

  @override
  State<DashboardStatistics> createState() => _DashboardStatisticsState();
}

class _DashboardStatisticsState extends State<DashboardStatistics> {
  final FirestoreService firestore = FirestoreService();

  String heart = "";
  String bloodPressure = "";
  String oxygen = "";

  String water = "";
  String goal = "";

  String sleep = "";

  int medicineCount = 0;

  bool loading = true;

  @override
  void initState() {
    super.initState();

    loadData();
  }

  Future loadData() async {
    final vitals = await firestore.getDashboardVitals(widget.patientId);

    if (vitals.exists) {
      final data = vitals.data()!;

      heart = data["heartRate"] ?? "";

      bloodPressure = data["bloodPressure"] ?? "";

      oxygen = data["oxygen"] ?? "";
    }

    final hydration = await firestore.getDashboardHydration(widget.patientId);

    if (hydration.exists) {
      final data = hydration.data()!;

      water = data["waterIntake"] ?? "";

      goal = data["goal"] ?? "";
    }

    final sleepData = await firestore.getDashboardSleep(widget.patientId);

    if (sleepData.exists) {
      sleep = sleepData.data()?["sleepHours"] ?? "";
    }

    medicineCount = await firestore.getMedicineCount(widget.patientId);

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        _healthCard("Heart Rate", "$heart BPM", Icons.favorite),

        _healthCard("Blood Pressure", bloodPressure, Icons.bloodtype),

        _healthCard("SpO₂", "$oxygen %", Icons.air),

        _healthCard("Medicines", "$medicineCount Active", Icons.medication),

        _healthCard("Hydration", "$water L / $goal L", Icons.water_drop),

        _healthCard("Sleep", "$sleep Hours", Icons.bedtime),
      ],
    );
  }

  Widget _healthCard(String title, String value, IconData icon) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),

      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.teal,

          child: Icon(icon, color: Colors.white),
        ),

        title: Text(title),

        subtitle: Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

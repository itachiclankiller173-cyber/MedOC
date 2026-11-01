import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
class HealthGraphsScreen extends StatelessWidget {
  final String patientId;

  const HealthGraphsScreen({
    super.key,
    required this.patientId,
  });

  double getNumber(dynamic value) {
    final match = RegExp(r'[\d.]+')
        .firstMatch(value?.toString() ?? '');

    if (match == null) return 0;

    return double.tryParse(match.group(0)!) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Health Graphs"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),

      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .collection("patients")
            .doc(patientId)
            .collection("vital_history")
            .orderBy("timestamp")
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text("Graph Error: ${snapshot.error}"),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                "No health history available yet.\nAdd vital signs first.",
                textAlign: TextAlign.center,
              ),
            );
          }

          final heartSpots = <FlSpot>[];
          final oxygenSpots = <FlSpot>[];
          final temperatureSpots = <FlSpot>[];

          for (int i = 0; i < docs.length; i++) {
            final data = docs[i].data();

            heartSpots.add(
              FlSpot(
                i.toDouble(),
                getNumber(data["heartRate"]),
              ),
            );

            oxygenSpots.add(
              FlSpot(
                i.toDouble(),
                getNumber(data["oxygen"]),
              ),
            );

            temperatureSpots.add(
              FlSpot(
                i.toDouble(),
                getNumber(data["temperature"]),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),

            child: Column(
              children: [

                HealthLineChart(
                  title: "❤️ Heart Rate History",
                  spots: heartSpots,
                  unit: "BPM",
                ),

                const SizedBox(height: 20),

                HealthLineChart(
                  title: "🫁 SpO₂ History",
                  spots: oxygenSpots,
                  unit: "%",
                ),

                const SizedBox(height: 20),

                HealthLineChart(
                  title: "🌡️ Temperature History",
                  spots: temperatureSpots,
                  unit: "°C",
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class HealthLineChart extends StatelessWidget {
  final String title;
  final List<FlSpot> spots;
  final String unit;

  const HealthLineChart({
    super.key,
    required this.title,
    required this.spots,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,

      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              height: 250,

              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),

                  titlesData: const FlTitlesData(
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),

                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),

                  borderData: FlBorderData(
                    show: true,
                  ),

                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      barWidth: 3,

                      dotData: const FlDotData(
                        show: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            Text(
              "Values in $unit",
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
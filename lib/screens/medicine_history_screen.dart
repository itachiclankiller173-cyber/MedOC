import 'package:flutter/material.dart';

import 'package:fl_chart/fl_chart.dart';

import '../services/medicine_history_storage.dart';

class MedicineHistoryScreen extends StatefulWidget {
  const MedicineHistoryScreen({super.key});

  @override
  State<MedicineHistoryScreen> createState() => _MedicineHistoryScreenState();
}

class _MedicineHistoryScreenState extends State<MedicineHistoryScreen> {
  int taken = 0;

  int missed = 0;

  @override
  void initState() {
    super.initState();

    loadHistory();
  }

  Future<void> loadHistory() async {
    final data = await MedicineHistoryStorage.getHistory();

    int t = 0;

    int m = 0;

    for (var item in data) {
      if (item["taken"] == true) {
        t++;
      } else {
        m++;
      }
    }

    setState(() {
      taken = t;

      missed = m;
    });
  }

  @override
  Widget build(BuildContext context) {
    double total = (taken + missed).toDouble();

    double percent = total == 0 ? 0 : (taken / total) * 100;

    return Scaffold(
      appBar: AppBar(title: const Text("Medicine History")),

      body: Column(
        children: [
          const SizedBox(height: 30),

          Text(
            "Adherence ${percent.toStringAsFixed(1)}%",

            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),

          SizedBox(
            height: 300,

            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(value: taken.toDouble(), title: "Taken"),

                  PieChartSectionData(
                    value: missed.toDouble(),

                    title: "Missed",
                  ),
                ],
              ),
            ),
          ),

          Text("Taken : $taken"),

          Text("Missed : $missed"),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class VitalChart extends StatelessWidget {
  const VitalChart({super.key, required this.heartRate, required this.oxygen,required this.temprature, required this.bloodPressure});
  final String heartRate;
  final String oxygen;
  final String temprature;
  final String bloodPressure;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        height: 250,

        child: LineChart(
          LineChartData(
            titlesData: const FlTitlesData(show: true),

            lineBarsData: [
              LineChartBarData(
                spots: [
                  FlSpot(0, 70),

                  FlSpot(1, 75),

                  FlSpot(2, 72),

                  FlSpot(3, 80),

                  FlSpot(4, 76),
                ],

                isCurved: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../services/firestore_service.dart';
import '../services/risk_assessment_service.dart';
import '../widgets/risk_card.dart';

class RiskAssessmentScreen extends StatefulWidget {
  final String patientId;

  const RiskAssessmentScreen({super.key, required this.patientId});

  @override
  State<RiskAssessmentScreen> createState() => _RiskAssessmentScreenState();
}

class _RiskAssessmentScreenState extends State<RiskAssessmentScreen> {
  final FirestoreService firestore = FirestoreService();

  bool loading = true;

  String heartRate = "--";
  String oxygen = "--";
  String bloodPressure = "--";
  String temperature = "--";
  String sleep = "--";
  String hydration = "--";
int? liveHeartRate;
int? liveSpo2; 
double? liveNtcTempF;
  @override
  void initState() {
    super.initState();
    loadVitals();
  }

  Future<void> loadVitals() async {
    try {
      // =========================================================
      // LOAD VITAL SIGNS
      // =========================================================

      final vitals = await firestore.getVitalSigns(widget.patientId);

      if (vitals.exists) {
        final data = vitals.data()!;

        heartRate = data["heartRate"]?.toString() ?? "--";
        oxygen = data["oxygen"]?.toString() ?? "--";
        bloodPressure = data["bloodPressure"]?.toString() ?? "--";
        temperature = data["temperature"]?.toString() ?? "--";
      }

      // =========================================================
      // LOAD MEDICAL HISTORY VITALS
      // Used as fallback if latest vital signs are unavailable
      // =========================================================

      final history = await firestore.getMedicalHistory(widget.patientId);

      if (history.exists) {
        final historyData = history.data()!;

        if (heartRate == "--" || heartRate.isEmpty) {
          heartRate = historyData["heartRate"]?.toString() ?? "--";
        }

        if (oxygen == "--" || oxygen.isEmpty) {
          oxygen = historyData["oxygen"]?.toString() ?? "--";
        }

        if (bloodPressure == "--" || bloodPressure.isEmpty) {
          bloodPressure = historyData["bloodPressure"]?.toString() ?? "--";
        }

        if (temperature == "--" || temperature.isEmpty) {
          temperature = historyData["temperature"]?.toString() ?? "--";
        }
      }

      // =========================================================
      // LOAD SLEEP
      // =========================================================

      final sleepData = await firestore.getSleep(widget.patientId);

      if (sleepData.exists) {
        sleep = sleepData.data()?["sleepHours"]?.toString() ?? "--";
      }

      // =========================================================
      // LOAD HYDRATION
      // =========================================================

      final hydrationData = await firestore.getHydration(widget.patientId);

      if (hydrationData.exists) {
        hydration = hydrationData.data()?["waterIntake"]?.toString() ?? "--";
      }

      if (!mounted) return;

      setState(() {
        loading = false;
      });
    } catch (e) {
      debugPrint("Risk Assessment loading error: $e");

      if (!mounted) return;

      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // -----------------------------
    // LOADING
    // -----------------------------

    if (loading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Risk Assessment"),
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Colors.teal),
        ),
      );
    }

    // -----------------------------
    // CALCULATE RISK
    // -----------------------------

    final result = RiskAssessmentService.assess(
      heartRate: heartRate,
      oxygen: oxygen,
      bloodPressure: bloodPressure,
      temperature: temperature,
      sleep: sleep,
      hydration: hydration,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Risk Assessment"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),

      body: RefreshIndicator(
        onRefresh: loadVitals,

        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              const Text(
                "AI Health Risk Assessment",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              Text(
                "Based on the latest available health readings.",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
              ),

              const SizedBox(height: 20),

              // -----------------------------
              // RISK CARD
              // -----------------------------
              RiskCard(result: result),

              const SizedBox(height: 25),

              const Text(
                "Current Readings",
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 15),

              _ReadingCard(
                title: "Heart Rate",
                value: liveHeartRate?.toString() ?? '--',
                unit: "BPM",
                icon: Icons.favorite,
                color: Colors.red,
              ),

              _ReadingCard(
                title: "Oxygen Saturation",
                value: liveSpo2?.toString() ?? '--',
                unit: "%",
                icon: Icons.air,
                color: Colors.green,
              ),

              _ReadingCard(
                title: "Blood Pressure",
                value: bloodPressure,
                unit: "mmHg",
                icon: Icons.bloodtype,
                color: Colors.blue,
              ),

              _ReadingCard(
                title: "Temperature",
                value: liveNtcTempF?.toStringAsFixed(1) ?? '--',                unit: "°C",
                icon: Icons.thermostat,
                color: Colors.orange,
              ),

              _ReadingCard(
                title: "Sleep",
                value: sleep,
                unit: "hrs",
                icon: Icons.bedtime,
                color: Colors.indigo,
              ),

              _ReadingCard(
                title: "Hydration",
                value: hydration,
                unit: "L",
                icon: Icons.water_drop,
                color: Colors.cyan,
              ),

              const SizedBox(height: 25),

              // -----------------------------
              // INFORMATION
              // -----------------------------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: Colors.teal.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                ),

                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Icon(Icons.info_outline, color: Colors.teal),

                    SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        "This screening provides general health "
                        "information from the available readings. "
                        "It does not replace professional medical "
                        "evaluation.",
                        style: TextStyle(fontSize: 14, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// READING CARD
// ============================================================

class _ReadingCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;

  const _ReadingCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,

      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(icon, color: color),
        ),

        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),

        trailing: Row(
          mainAxisSize: MainAxisSize.min,

          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(width: 5),

            Text(unit, style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../services/esp32_service.dart' as esp32;
import '../services/ai_service.dart';
import '../services/firestore_service.dart';
import '../services/patient_service.dart';
import '../services/health_score_service.dart';
import '../services/risk_assessment_service.dart';

import '../widgets/ai_health_summary.dart';
import '../widgets/vital_chart.dart';
import '../widgets/dashboard_statistics.dart';
import '../widgets/risk_card.dart';

import 'patient_profile_screen.dart';
import 'sos_screen.dart';
import 'medical_history_screen.dart';
import 'ai_assistant_screen.dart';
import 'gait_analysis_screen.dart';
import 'nutrition_analysis_screen.dart';
import 'ecg_screen.dart';
import 'burn_assessment_screen.dart';
import 'risk_assessment_screen.dart';
import 'medical_reports_screen.dart';
import 'diabetic_foot_screen.dart';
import 'hospital_locator_screen.dart';
import 'health_graphs_screen.dart';
import 'bmi_screen.dart';
import 'cognitive_health_screen.dart';
import 'body_3d_screen.dart';
import 'sleep_tracker_screen.dart';
import 'hydration_tracker_screen.dart';
import 'medicine_reminder_screen.dart';
import 'first_aid_screen.dart';
import 'dosage_calculator_screen.dart';
import 'body_posture_screen.dart';

List<Map<String, dynamic>> medicines = [];

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AIService aiService = AIService();
  final FirestoreService firestore = FirestoreService();

  bool aiLoading = false;
  bool sensorLoading = false;

  double? roomTemperature;
  double? roomHumidity;

  String name = 'User';
  String aiSummary = 'AI analysis will appear here.';
  String heartRate = '--';
  String bloodPressure = '--';
  String oxygen = '--';
  String temperature = '--';
  String sleep = '--';
  String water = '--';
  Timer? sensorTimer;
  String selectedPatientId = '';
  String patientId = '';

  int healthScore = 0;
  RiskAssessmentResult? riskResult;

@override
void initState() {
  super.initState();

  loadDashboard();
  loadRoomSensorData();

  sensorTimer = Timer.periodic(
    const Duration(seconds: 3),
    (_) => loadRoomSensorData(),
  );
}

@override
void dispose() {
  sensorTimer?.cancel();
  super.dispose();
}

  Future<void> loadRoomSensorData() async {
    if (mounted) {
      setState(() => sensorLoading = true);
    }

    try {
      final data = await esp32.Esp32Service.getSensorData();

      if (!mounted) return;

      setState(() {
        roomTemperature =
            (data['temperature'] as num?)?.toDouble();
        roomHumidity =
            (data['humidity'] as num?)?.toDouble();
        sensorLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => sensorLoading = false);
      debugPrint('ESP32 sensor error: $e');
    }
  }

  Future<void> loadDashboard() async {
    try {
      final patient = await PatientService().getSelectedPatient();

      if (!mounted) return;

      if (patient == null) {
        setState(() {
          selectedPatientId = '';
          patientId = '';
          name = 'User';
          medicines = [];
          riskResult = null;
        });
        return;
      }

      patientId = patient.id;
      selectedPatientId = patient.id;

      final medicineData = await firestore.getMedicines(patientId);
      final profile = await firestore.getProfile(patientId);
      final vitals = await firestore.getVitalSigns(patientId);
      final sleepData = await firestore.getSleep(patientId);
      final hydration = await firestore.getHydration(patientId);

      if (!mounted) return;

      final profileData = profile.data();
      final vitalData = vitals.data() ?? {};
      final sleepValue = sleepData.data()?['sleepHours'];
      final waterValue = hydration.data()?['waterIntake'];

      setState(() {
        medicines = medicineData.docs.map((doc) => doc.data()).toList();

        name = profileData?['name']?.toString() ?? 'User';

        heartRate = vitalData['heartRate']?.toString() ?? '--';
        bloodPressure =
            vitalData['bloodPressure']?.toString() ?? '--';
        oxygen = vitalData['oxygen']?.toString() ?? '--';
        temperature = vitalData['temperature']?.toString() ?? '--';

        sleep = sleepValue?.toString() ?? '--';
        water = waterValue?.toString() ?? '--';

        healthScore = HealthScoreService.calculate(
          heartRate: heartRate,
          oxygen: oxygen,
          bloodPressure: bloodPressure,
          sleep: sleep,
          hydration: water,
        );

        riskResult = RiskAssessmentService.assess(
          heartRate: heartRate,
          oxygen: oxygen,
          bloodPressure: bloodPressure,
          temperature: temperature,
          sleep: sleep,
          hydration: water,
        );
      });
    } catch (e) {
      debugPrint('Dashboard loading error: $e');
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load dashboard data.')),
      );
    }
  }

  Future<void> generateAISummary() async {
    setState(() => aiLoading = true);

    try {
      final result = await aiService.getHealthSummary(
        name: name,
        heartRate: heartRate,
        bloodPressure: bloodPressure,
        oxygen: oxygen,
        temperature: temperature,
        sleep: sleep,
        water: water,
      );

      if (!mounted) return;

      setState(() {
        aiSummary = result;
        aiLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        aiSummary = 'Unable to generate a summary right now.';
        aiLoading = false;
      });
    }
  }

  void openPage(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  Future<void> openPatientReports() async {
    final patient = await PatientService().getSelectedPatient();

    if (!mounted) return;

    if (patient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No active patient selected. Select a patient first.',
          ),
        ),
      );
      return;
    }

    openPage(MedicalReportsScreen(patientId: patient.id));
  }

  Future<void> openRiskAssessment() async {
    final patient = await PatientService().getSelectedPatient();

    if (!mounted) return;

    if (patient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a patient first.'),
        ),
      );
      return;
    }

    openPage(RiskAssessmentScreen(patientId: patient.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF087F8C),
        foregroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.health_and_safety, size: 28),
            SizedBox(width: 10),
            Text(
              'MedOC',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh dashboard',
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await loadDashboard();
              await loadRoomSensorData();
            },
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await loadDashboard();
          await loadRoomSensorData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF087F8C),
                      Color(0xFF26A69A),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.teal.withOpacity(0.18),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 34,
                        color: Color(0xFF087F8C),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome, $name!',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Your AI healthcare companion',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            selectedPatientId.isEmpty
                                ? 'No patient selected'
                                : 'Patient profile connected',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.favorite,
                      size: 32,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Main monitoring shortcuts
              const _SectionHeading(
                title: 'Health Monitoring',
                subtitle: 'Quick access to your health tools',
              ),
              const SizedBox(height: 14),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.18,
                children: [
                  _NavigationCard(
                    title: 'ECG Monitor',
                    subtitle: 'View waveform',
                    icon: Icons.monitor_heart,
                    color: const Color(0xFFE64B5D),
                    onTap: () => openPage(EcgScreen()),
                  ),
                  _NavigationCard(
                    title: 'Temperature',
                    subtitle: 'View temperature',
                    icon: Icons.thermostat,
                    color: const Color(0xFFEF8D32),
                    onTap: () => openPage(
                      VitalDetailScreen(
                        title: 'Temperature',
                        value: temperature,
                        unit: '°C',
                        icon: Icons.thermostat,
                        color: Colors.orange,
                        description:
                            'Temperature recorded in the selected patient profile.',
                      ),
                    ),
                  ),
                  _NavigationCard(
                    title: 'SpO₂',
                    subtitle: 'Oxygen readings',
                    icon: Icons.air,
                    color: const Color(0xFF279B70),
                    onTap: () => openPage(
                      VitalDetailScreen(
                        title: 'Blood Oxygen (SpO₂)',
                        value: oxygen,
                        unit: '%',
                        icon: Icons.air,
                        color: Colors.green,
                        description:
                            'Oxygen saturation value saved in the patient record.',
                      ),
                    ),
                  ),
                  _NavigationCard(
                    title: 'Wi-Fi Motion',
                    subtitle: 'Motion intelligence',
                    icon: Icons.wifi,
                    color: const Color(0xFF5269C8),
                    onTap: () => openPage(
                      const WifiMotionScreen(),
                    ),
                  ),
                  _NavigationCard(
                    title: 'Patient Reports',
                    subtitle: 'View medical reports',
                    icon: Icons.description,
                    color: const Color(0xFF087F8C),
                    onTap: openPatientReports,
                  ),
                  _NavigationCard(
                    title: 'AI Assistant',
                    subtitle: 'Health assistance',
                    icon: Icons.smart_toy,
                    color: const Color(0xFF8557B7),
                    onTap: () => openPage(const AIAssistantScreen()),
                  ),
                ],
              ),

              const SizedBox(height: 26),

              // Health score
              const _SectionHeading(
                title: 'Health Overview',
                subtitle: 'Summary of information in your records',
              ),
              const SizedBox(height: 14),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.035),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 104,
                      height: 104,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 100,
                            height: 100,
                            child: CircularProgressIndicator(
                              value: (healthScore.clamp(0, 100)) / 100,
                              strokeWidth: 9,
                              backgroundColor: Colors.grey.shade200,
                              color: const Color(0xFF159A8C),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$healthScore',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF153D49),
                                ),
                              ),
                              const Text(
                                'out of 100',
                                style: TextStyle(fontSize: 10),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Health Score',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            healthScore >= 90
                                ? 'High score'
                                : healthScore >= 75
                                    ? 'Good score'
                                    : healthScore >= 50
                                        ? 'Moderate score'
                                        : 'Review your health data',
                            style: const TextStyle(
                              color: Color(0xFF087F8C),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Based on available saved values. '
                            'This score is not a diagnosis.',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const _SectionHeading(
                title: 'Patient Vitals',
                subtitle: 'Values from your saved patient record',
              ),
              const SizedBox(height: 14),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.22,
                children: [
                  _VitalCard(
                    title: 'Heart Rate',
                    value: heartRate,
                    unit: 'BPM',
                    icon: Icons.favorite,
                    color: Colors.red,
                  ),
                  _VitalCard(
                    title: 'Blood Pressure',
                    value: bloodPressure,
                    unit: 'mmHg',
                    icon: Icons.bloodtype,
                    color: Colors.blue,
                  ),
                  _VitalCard(
                    title: 'SpO₂',
                    value: oxygen,
                    unit: '%',
                    icon: Icons.air,
                    color: Colors.green,
                  ),
                  _VitalCard(
                    title: 'Temperature',
                    value: temperature,
                    unit: '°C',
                    icon: Icons.thermostat,
                    color: Colors.orange,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              const _SectionHeading(
                title: 'Room Environment',
                subtitle: 'ESP32 sensor readings, when available',
              ),
              const SizedBox(height: 14),
Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Expanded(
      child: SizedBox(
        height: 160,
        child: _VitalCard(
          title: 'Room Temp.',
          value: roomTemperature?.toStringAsFixed(1) ?? '--',
          unit: '°C',
          icon: Icons.device_thermostat,
          color: Colors.deepOrange,
        ),
      ),
    ),
    const SizedBox(width: 12),
    Expanded(
      child: SizedBox(
        height: 160,
        child: _VitalCard(
          title: 'Humidity',
          value: roomHumidity?.toStringAsFixed(1) ?? '--',
          unit: '%',
          icon: Icons.water_drop,
          color: Colors.blue,
        ),
      ),
    ),
  ],
),
              if (sensorLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: LinearProgressIndicator(),
                ),

              const SizedBox(height: 24),

              const _SectionHeading(
                title: 'Daily Health Progress',
                subtitle: 'Sleep and hydration records',
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: _ProgressTile(
                      title: 'Sleep',
                      value: '$sleep hrs',
                      icon: Icons.bedtime,
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SleepTrackerScreen(),
                          ),
                        );
                        await loadDashboard();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ProgressTile(
                      title: 'Water',
                      value: '$water L',
                      icon: Icons.water_drop,
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HydrationTrackerScreen(),
                          ),
                        );
                        await loadDashboard();
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Medicines
              const _SectionHeading(
                title: 'Medicines',
                subtitle: 'Your saved medication reminders',
              ),
              const SizedBox(height: 14),

              if (medicines.isEmpty)
                Card(
                  color: Colors.white,
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.medication),
                    ),
                    title: const Text('No medicines added'),
                    subtitle: const Text('Open Medicine Reminder'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MedicineReminderScreen(
                            patientId: selectedPatientId,
                          ),
                        ),
                      );
                      await loadDashboard();
                    },
                  ),
                )
              else
                Column(
                  children: [
                    ...medicines.map((medicine) {
                      return Card(
                        color: Colors.white,
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFFE0F2F1),
                            child: Icon(
                              Icons.medication,
                              color: Color(0xFF087F8C),
                            ),
                          ),
                          title: Text(
                            medicine['medicine']?.toString() ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Dosage: ${medicine['dosage'] ?? ''}',
                              ),
                              Text(
                                'Time: ${medicine['timing'] ?? ''}',
                              ),
                              Text(medicine['food']?.toString() ?? ''),
                            ],
                          ),
                        ),
                      );
                    }),
                    Card(
                      child: ListTile(
                        leading: const Icon(
                          Icons.add_circle,
                          color: Color(0xFF087F8C),
                        ),
                        title: const Text('Add / Manage Medicines'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MedicineReminderScreen(
                                patientId: selectedPatientId,
                              ),
                            ),
                          );
                          await loadDashboard();
                        },
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 24),

              const _SectionHeading(
                title: 'Quick Actions',
                subtitle: 'More MedOC features',
              ),
              const SizedBox(height: 14),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.95,
                children: [
                  _ActionTile(
                    icon: Icons.monitor_weight,
                    title: 'BMI',
                    onTap: () => openPage(const BMIScreen()),
                  ),
                  _ActionTile(
                    icon: Icons.medication,
                    title: 'Dosage',
                    onTap: () => openPage(const DosageCalculatorScreen()),
                  ),
                  _ActionTile(
                    icon: Icons.view_in_ar,
                    title: '3D Body',
                    onTap: () => openPage(const ThreeDModelScreen()),
                  ),
                  _ActionTile(
                    icon: Icons.medical_services,
                    title: 'First Aid',
                    onTap: () => openPage(const FirstAidScreen()),
                  ),
                  _ActionTile(
                    icon: Icons.emergency,
                    title: 'SOS',
                    onTap: () => openPage(const SOSScreen()),
                  ),
                  _ActionTile(
                    icon: Icons.person,
                    title: 'Profile',
                    onTap: () => openPage(const PatientProfileScreen()),
                  ),
                  _ActionTile(
                    icon: Icons.local_hospital,
                    title: 'Hospitals',
                    onTap: () => openPage(const HospitalLocatorScreen()),
                  ),
                  _ActionTile(
                    icon: Icons.directions_walk,
                    title: 'Gait',
                    onTap: () => openPage(const GaitAnalysisScreen()),
                  ),
                  _ActionTile(
                    icon: Icons.psychology,
                    title: 'Cognitive',
                    onTap: () => openPage(const CognitiveHealthScreen()),
                  ),
                  _ActionTile(
                    icon: Icons.history,
                    title: 'History',
                    onTap: () => openPage(
                      MedicalHistoryScreen(patientId: selectedPatientId),
                    ),
                  ),
                  _ActionTile(
                    icon: Icons.accessibility_new,
                    title: 'Posture',
                    onTap: () => openPage(const BodyPostureScreen()),
                  ),
                  _ActionTile(
                    icon: Icons.description,
                    title: 'Reports',
                    onTap: openPatientReports,
                  ),
                  _ActionTile(
                    icon: Icons.warning_amber,
                    title: 'Risk',
                    onTap: openRiskAssessment,
                  ),
                  _ActionTile(
                    icon: Icons.personal_injury,
                    title: 'Foot Check',
                    onTap: () => openPage(const DiabeticFootScreen()),
                  ),
                  _ActionTile(
                    icon: Icons.local_fire_department,
                    title: 'Burn',
                    onTap: () => openPage(const BurnAssessmentScreen()),
                  ),
                  _ActionTile(
                    icon: Icons.show_chart,
                    title: 'Graphs',
                    onTap: () {
                      if (patientId.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Please create a patient profile first.',
                            ),
                          ),
                        );
                        return;
                      }

                      openPage(HealthGraphsScreen(patientId: patientId));
                    },
                  ),
                  _ActionTile(
                    icon: Icons.restaurant_menu,
                    title: 'Nutrition',
                    onTap: () => openPage(const NutritionAnalysisScreen()),
                  ),
                  _ActionTile(
                    icon: Icons.smart_toy,
                    title: 'AI Assistant',
                    onTap: () => openPage(const AIAssistantScreen()),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              const _SectionHeading(
                title: 'Live Health Data',
                subtitle: 'Updates from the selected patient record',
              ),
              const SizedBox(height: 14),

              if (selectedPatientId.isNotEmpty)
                DashboardStatistics(patientId: selectedPatientId),

              const SizedBox(height: 16),

              if (riskResult != null) RiskCard(result: riskResult!),

              const SizedBox(height: 16),

              if (selectedPatientId.isNotEmpty)
                StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: firestore.vitalStream(selectedPatientId),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('Unable to load live vital data.'),
                        ),
                      );
                    }

                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    final data = snapshot.data!.data() ?? {};

                    return VitalChart(
                      heartRate:
                          data['heartRate']?.toString() ?? '0',
                      oxygen: data['oxygen']?.toString() ?? '0',
                      bloodPressure:
                          data['bloodPressure']?.toString() ?? '0/0',
                      temprature:
                          data['temperature']?.toString() ?? '0',
                    );
                  },
                ),

              const SizedBox(height: 16),

              AIHealthSummary(
                heartRate: heartRate,
                oxygen: oxygen,
                bloodPressure: bloodPressure,
                sleep: sleep,
                hydration: water,
              ),

              const SizedBox(height: 16),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          color: Color(0xFF087F8C),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'AI Health Summary',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(aiSummary),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: aiLoading ? null : generateAISummary,
                        icon: aiLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.auto_awesome),
                        label: Text(
                          aiLoading ? 'Generating...' : 'Generate Summary',
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              const Center(
                child: Text(
                  'MedOC • Healthcare companion',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

// Section heading
class _SectionHeading extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeading({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF193B48),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}

// Large navigation card
class _NavigationCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _NavigationCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.025),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 27),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Vital reading card
class _VitalCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;

  const _VitalCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 26),
          const Spacer(),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
              color: Color(0xFF193B48),
            ),
          ),
          Text(
            unit,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// Progress tile
class _ProgressTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _ProgressTile({
    required this.title,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.grey.shade100),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF087F8C), size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Small quick-action tile
class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 5,
            vertical: 12,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: const Color(0xFF087F8C),
                size: 27,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Detail screen for a saved vital value
class VitalDetailScreen extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;
  final String description;

  const VitalDetailScreen({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFF087F8C),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(26),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 38,
                  backgroundColor: color.withOpacity(0.12),
                  child: Icon(icon, size: 42, color: color),
                ),
                const SizedBox(height: 20),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  value == '--' || value.isEmpty
                      ? 'No reading available'
                      : '$value $unit',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'This value is informational and is not a diagnosis.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Wi-Fi Motion Intelligence screen
class WifiMotionScreen extends StatelessWidget {
  const WifiMotionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text('Wi-Fi Motion Intelligence'),
        backgroundColor: const Color(0xFF087F8C),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Column(
              children: [
                CircleAvatar(
                  radius: 42,
                  backgroundColor: Color(0xFFE8EAFB),
                  child: Icon(
                    Icons.wifi,
                    size: 46,
                    color: Color(0xFF5269C8),
                  ),
                ),
                SizedBox(height: 18),
                Text(
                  'Wi-Fi Motion Intelligence',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'This module is reserved for the ESP32 CSI motion '
                  'data pipeline. It can display motion classifications '
                  'after compatible firmware, data collection, and '
                  'processing are connected.',
                  textAlign: TextAlign.center,
                  style: TextStyle(height: 1.5),
                ),
                SizedBox(height: 18),
                Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.memory, color: Color(0xFF5269C8)),
                  title: Text('ESP32 CSI firmware'),
                  subtitle: Text('Required for Wi-Fi channel data'),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.analytics, color: Color(0xFF5269C8)),
                  title: Text('Motion processing'),
                  subtitle: Text('Required to interpret CSI samples'),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.cloud_sync, color: Color(0xFF5269C8)),
                  title: Text('App integration'),
                  subtitle: Text('Required to show real motion results'),
                ),
                SizedBox(height: 8),
                Text(
                  'Status: Integration pending. No live motion '
                  'detection is being reported by this screen.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.deepOrange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

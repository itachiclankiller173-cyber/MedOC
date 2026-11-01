import 'package:flutter/material.dart';

class DosageCalculatorScreen extends StatefulWidget {
  const DosageCalculatorScreen({super.key});

  @override
  State<DosageCalculatorScreen> createState() =>
      _DosageCalculatorScreenState();
}

class _DosageCalculatorScreenState
    extends State<DosageCalculatorScreen> {
  final TextEditingController medicineController =
      TextEditingController();

  final TextEditingController weightController =
      TextEditingController();

  final TextEditingController doseController =
      TextEditingController();

  final TextEditingController frequencyController =
      TextEditingController();

  String result = '';

  void calculateDose() {
    final double? weight =
        double.tryParse(weightController.text.trim());

    final double? dosePerKg =
        double.tryParse(doseController.text.trim());

    final int? frequency =
        int.tryParse(frequencyController.text.trim());

    if (weight == null ||
        dosePerKg == null ||
        frequency == null ||
        weight <= 0 ||
        dosePerKg <= 0 ||
        frequency <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid values.'),
        ),
      );
      return;
    }

    // Mathematical calculation based on a clinician-provided dose.
    final double dosePerAdministration =
        weight * dosePerKg;

    final double totalDailyDose =
        dosePerAdministration * frequency;

    setState(() {
      result =
          'Calculated amount per administration: '
          '${dosePerAdministration.toStringAsFixed(2)}\n\n'
          'Calculated total for the day: '
          '${totalDailyDose.toStringAsFixed(2)}';
    });
  }

  void reset() {
    medicineController.clear();
    weightController.clear();
    doseController.clear();
    frequencyController.clear();

    setState(() {
      result = '';
    });
  }

  @override
  void dispose() {
    medicineController.dispose();
    weightController.dispose();
    doseController.dispose();
    frequencyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dosage Calculator'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.medication_outlined,
              size: 75,
              color: Colors.teal,
            ),

            const SizedBox(height: 15),

            const Text(
              'Dosage Calculator',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Enter values provided by a doctor or pharmacist.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 25),

            TextField(
              controller: medicineController,
              decoration: const InputDecoration(
                labelText: 'Medicine name',
                prefixIcon: Icon(Icons.medication),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 18),

            TextField(
              controller: weightController,
              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Patient weight (kg)',
                prefixIcon: Icon(Icons.monitor_weight),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 18),

            TextField(
              controller: doseController,
              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Prescribed dose (mg/kg)',
                prefixIcon: Icon(Icons.calculate),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 18),

            TextField(
              controller: frequencyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Doses per day',
                prefixIcon: Icon(Icons.schedule),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              height: 55,
              child: ElevatedButton(
                onPressed: calculateDose,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'Calculate',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),

            const SizedBox(height: 12),

            OutlinedButton(
              onPressed: reset,
              child: const Text('Reset'),
            ),

            if (result.isNotEmpty) ...[
              const SizedBox(height: 25),

              Card(
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(20),

                  child: Column(
                    children: [
                      const Icon(
                        Icons.calculate,
                        color: Colors.teal,
                        size: 40,
                      ),

                      const SizedBox(height: 12),

                      Text(
                        medicineController.text.isEmpty
                            ? 'Calculated Result'
                            : medicineController.text,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 15),

                      Text(
                        result,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Safety note: This calculator only performs the '
                'mathematical calculation from values supplied by '
                'a qualified healthcare professional. It does not '
                'recommend or prescribe medication doses.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
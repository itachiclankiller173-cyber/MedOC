class HealthAIService {
  String analyze({
    required String heartRate,
    required String oxygen,
    required String bloodPressure,
    required String sleep,
    required String hydration,
  }) {
    List<String> warnings = [];

    // -------------------------
    // Heart Rate
    // -------------------------

    int? hr = int.tryParse(heartRate);

    if (hr != null) {
      if (hr > 100) {
        warnings.add("Heart rate is higher than the usual resting range.");
      } else if (hr < 50) {
        warnings.add("Heart rate is lower than the usual resting range.");
      }
    }

    // -------------------------
    // Oxygen (SpO2)
    // -------------------------

    int? spo2 = int.tryParse(oxygen);

    if (spo2 != null) {
      if (spo2 < 95) {
        warnings.add("Oxygen level is below the usual range.");
      }
    }

    // -------------------------
    // Blood Pressure
    // Example: 120/80
    // -------------------------

    if (bloodPressure.contains("/")) {
      List<String> bp = bloodPressure.split("/");

      if (bp.length == 2) {
        int? systolic = int.tryParse(bp[0].trim());
        int? diastolic = int.tryParse(bp[1].trim());

        if (systolic != null && diastolic != null) {
          if (systolic >= 140 || diastolic >= 90) {
            warnings.add("Blood pressure is higher than the usual range.");
          } else if (systolic < 90 || diastolic < 60) {
            warnings.add("Blood pressure is lower than the usual range.");
          }
        }
      }
    }

    // -------------------------
    // Sleep
    // -------------------------

    double? sleepValue = double.tryParse(sleep);

    if (sleepValue != null && sleepValue < 6) {
      warnings.add("Sleep duration is below the recommended amount.");
    }

    // -------------------------
    // Hydration
    // -------------------------

    double? water = double.tryParse(hydration);

    if (water != null && water < 2) {
      warnings.add("Hydration may be low.");
    }

    // -------------------------
    // Final Result
    // -------------------------

    if (warnings.isEmpty) {
      return "Your entered health parameters look within the expected ranges. "
          "Continue maintaining healthy habits.";
    }

    return warnings.join("\n");
  }
}

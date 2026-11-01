class RiskAssessmentResult {
  final String overallRisk;
  final int riskScore;
  final List<String> warnings;
  final List<String> normalChecks;
  final List<String> recommendations;

  const RiskAssessmentResult({
    required this.overallRisk,
    required this.riskScore,
    required this.warnings,
    required this.normalChecks,
    required this.recommendations,
  });
}

class RiskAssessmentService {
  static RiskAssessmentResult assess({
    required String heartRate,
    required String oxygen,
    required String bloodPressure,
    required String temperature,
    required String sleep,
    required String hydration,
  }) {
    int score = 0;

    final warnings = <String>[];
    final normalChecks = <String>[];
    final recommendations = <String>[];

    // --------------------------------------------------
    // HEART RATE
    // --------------------------------------------------

    final hr = _parseNumber(heartRate);

    if (hr != null) {
      if (hr < 50 || hr > 120) {
        score += 2;
        warnings.add("Heart rate is outside the expected range.");
        recommendations.add("Consider rechecking your heart rate at rest.");
      } else {
        normalChecks.add("Heart rate appears within the screening range.");
      }
    }

    // --------------------------------------------------
    // OXYGEN
    // --------------------------------------------------

    final spo2 = _parseNumber(oxygen);

    if (spo2 != null) {
      if (spo2 < 90) {
        score += 3;
        warnings.add("Oxygen saturation is very low.");
        recommendations.add(
          "Seek prompt medical attention if this reading is accurate "
          "or if there are concerning symptoms.",
        );
      } else if (spo2 < 94) {
        score += 2;
        warnings.add("Oxygen saturation is below the usual range.");
        recommendations.add("Recheck the oxygen reading.");
      } else {
        normalChecks.add("Oxygen saturation appears acceptable.");
      }
    }

    // --------------------------------------------------
    // BLOOD PRESSURE
    // --------------------------------------------------

    final bp = _parseBloodPressure(bloodPressure);

    if (bp != null) {
      final systolic = bp.$1;
      final diastolic = bp.$2;

      if (systolic >= 180 || diastolic >= 120) {
        score += 3;

        warnings.add("Blood pressure reading is very high.");

        recommendations.add(
          "Recheck the reading and seek urgent medical advice, "
          "especially if you feel unwell.",
        );
      } else if (systolic >= 140 || diastolic >= 90) {
        score += 2;

        warnings.add("Blood pressure reading is elevated.");

        recommendations.add(
          "Monitor blood pressure and discuss repeated high readings "
          "with a healthcare professional.",
        );
      } else {
        normalChecks.add("Blood pressure appears within the screening range.");
      }
    }

    // --------------------------------------------------
    // TEMPERATURE
    // --------------------------------------------------

    final temp = _parseNumber(temperature);

    if (temp != null) {
      if (temp >= 39.0) {
        score += 3;

        warnings.add("Temperature is high.");

        recommendations.add(
          "Monitor temperature and consider medical advice if it "
          "remains high or symptoms worsen.",
        );
      } else if (temp >= 38.0) {
        score += 2;

        warnings.add("Temperature is elevated.");

        recommendations.add("Continue monitoring temperature and symptoms.");
      } else {
        normalChecks.add("Temperature appears within the screening range.");
      }
    }

    // --------------------------------------------------
    // SLEEP
    // --------------------------------------------------

    final sleepHours = _parseNumber(sleep);

    if (sleepHours != null) {
      if (sleepHours < 5) {
        score += 2;

        warnings.add("Sleep duration is quite low.");

        recommendations.add(
          "Try to maintain a consistent and adequate sleep schedule.",
        );
      } else if (sleepHours < 7) {
        score += 1;

        warnings.add("Sleep duration may be lower than recommended.");

        recommendations.add(
          "Consider improving sleep duration and consistency.",
        );
      } else {
        normalChecks.add("Sleep duration appears adequate.");
      }
    }

    // --------------------------------------------------
    // HYDRATION
    // --------------------------------------------------

    final water = _parseNumber(hydration);

    if (water != null) {
      if (water < 1.0) {
        score += 2;

        warnings.add("Water intake appears low.");

        recommendations.add(
          "Maintain regular fluid intake unless a healthcare professional "
          "has advised you to restrict fluids.",
        );
      } else if (water < 1.5) {
        score += 1;

        warnings.add("Water intake may be low.");

        recommendations.add(
          "Try to maintain regular hydration throughout the day.",
        );
      } else {
        normalChecks.add("Hydration appears adequate.");
      }
    }

    // --------------------------------------------------
    // OVERALL RISK
    // --------------------------------------------------

    String overallRisk;

    if (score >= 7) {
      overallRisk = "HIGH";
    } else if (score >= 3) {
      overallRisk = "MEDIUM";
    } else {
      overallRisk = "LOW";
    }

    if (warnings.isEmpty) {
      recommendations.add(
        "No major screening concerns were detected from the available readings.",
      );
    }

    return RiskAssessmentResult(
      overallRisk: overallRisk,
      riskScore: score,
      warnings: warnings,
      normalChecks: normalChecks,
      recommendations: recommendations,
    );
  }

  // --------------------------------------------------
  // NUMBER PARSER
  // --------------------------------------------------

  static double? _parseNumber(String value) {
    final cleaned = value.replaceAll(RegExp(r'[^0-9.]'), '');

    if (cleaned.isEmpty) {
      return null;
    }

    return double.tryParse(cleaned);
  }

  // --------------------------------------------------
  // BLOOD PRESSURE PARSER
  // --------------------------------------------------

  static (double, double)? _parseBloodPressure(String value) {
    final match = RegExp(
      r'(\d+(?:\.\d+)?)\s*/\s*(\d+(?:\.\d+)?)',
    ).firstMatch(value);

    if (match == null) {
      return null;
    }

    final systolic = double.tryParse(match.group(1)!);
    final diastolic = double.tryParse(match.group(2)!);

    if (systolic == null || diastolic == null) {
      return null;
    }

    return (systolic, diastolic);
  }
}

class HealthScoreService {
  static int calculate({
    required String heartRate,
    required String oxygen,
    required String bloodPressure,
    required String sleep,
    required String hydration,
  }) {
    int score = 100;

    final hr = int.tryParse(heartRate) ?? 0;
    final spo2 = int.tryParse(oxygen) ?? 0;
    final sl = double.tryParse(sleep) ?? 0;
    final water = double.tryParse(hydration) ?? 0;

    // Heart Rate
    if (hr < 60 || hr > 100) {
      score -= 10;
    }

    // Oxygen
    if (spo2 < 95) {
      score -= 20;
    }

    // Sleep
    if (sl < 7) {
      score -= 10;
    }

    // Hydration
    if (water < 2) {
      score -= 10;
    }

    // Blood Pressure
    try {
      final bp = bloodPressure.split('/');
      final sys = int.parse(bp[0]);
      final dia = int.parse(bp[1]);

      if (sys > 140 || dia > 90) {
        score -= 15;
      }

      if (sys < 90 || dia < 60) {
        score -= 10;
      }
    } catch (_) {}

    if (score < 0) score = 0;

    return score;
  }
}

import 'package:shared_preferences/shared_preferences.dart';

class HydrationStorage {
  static const String key = "water_amount";

  static Future<void> saveWater(int amount) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(key, amount);
  }

  static Future<int> getWater() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getInt(key) ?? 0;
  }

  static Future<void> resetWater() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(key);
  }
}

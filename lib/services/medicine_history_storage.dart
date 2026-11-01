import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MedicineHistoryStorage {
  static const String key = "medicine_history";

  static Future<void> saveHistory(String medicine, bool taken) async {
    final prefs = await SharedPreferences.getInstance();

    List<String> history = prefs.getStringList(key) ?? [];

    history.add(
      jsonEncode({
        "medicine": medicine,

        "taken": taken,

        "date": DateTime.now().toString(),
      }),
    );

    await prefs.setStringList(key, history);
  }

  static Future<List<Map<String, dynamic>>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();

    List<String> history = prefs.getStringList(key) ?? [];

    return history.map((item) {
      return jsonDecode(item) as Map<String, dynamic>;
    }).toList();
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(key);
  }
}

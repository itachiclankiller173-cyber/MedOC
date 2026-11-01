import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SleepStorage {
  static const String key = "sleep_history";

  static Future<void> saveSleep(Map<String, dynamic> sleep) async {
    final prefs = await SharedPreferences.getInstance();

    List<String> history = prefs.getStringList(key) ?? [];

    history.add(jsonEncode(sleep));

    await prefs.setStringList(key, history);
  }

  static Future<List<Map<String, dynamic>>> getSleep() async {
    final prefs = await SharedPreferences.getInstance();

    List<String> history = prefs.getStringList(key) ?? [];

    return history.map((item) {
      return jsonDecode(item) as Map<String, dynamic>;
    }).toList();
  }
}

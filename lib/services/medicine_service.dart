import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MedicineService {
  static const String key = "medicines";

  static Future<void> saveMedicines(List<Map<String, String>> medicines) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(key, jsonEncode(medicines));
  }

  static Future<List<Map<String, String>>> loadMedicines() async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getString(key);

    if (data == null) {
      return [];
    }

    final List decoded = jsonDecode(data);

    return decoded.map((e) => Map<String, String>.from(e)).toList();
  }
}

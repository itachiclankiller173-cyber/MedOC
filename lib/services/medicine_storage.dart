import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MedicineStorage {
  static const String key = "medicines";

  static Future<void> saveMedicine(Map<String, dynamic> medicine) async {
    final prefs = await SharedPreferences.getInstance();

    List<String> medicines = prefs.getStringList(key) ?? [];

    medicines.add(jsonEncode(medicine));

    await prefs.setStringList(key, medicines);
  }

  static Future<List<Map<String, dynamic>>> getMedicines() async {
    final prefs = await SharedPreferences.getInstance();

    List<String> medicines = prefs.getStringList(key) ?? [];

    return medicines.map((item) {
      return jsonDecode(item) as Map<String, dynamic>;
    }).toList();
  }

  static Future<void> updateMedicine(
    int index,
    Map<String, dynamic> medicine,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    List<String> medicines = prefs.getStringList(key) ?? [];

    medicines[index] = jsonEncode(medicine);

    await prefs.setStringList(key, medicines);
  }

  static Future<void> deleteMedicine(int index) async {
    final prefs = await SharedPreferences.getInstance();

    List<String> medicines = prefs.getStringList(key) ?? [];

    medicines.removeAt(index);

    await prefs.setStringList(key, medicines);
  }
}

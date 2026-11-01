import 'package:shared_preferences/shared_preferences.dart';

class LanguageService {
  static const String _key = 'selected_language';

  static Future<void> saveLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, languageCode);
  }

  static Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key) ?? 'en-IN';
  }
}
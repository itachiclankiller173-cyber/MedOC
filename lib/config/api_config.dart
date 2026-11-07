import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    // Chrome
    if (kIsWeb) {
      return "https://medoc-8rme.onrender.com";
    }

    // Real Android phone
    return "http://192.168.1.5:8000";
  }
}

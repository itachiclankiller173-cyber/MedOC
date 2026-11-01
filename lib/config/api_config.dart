import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    // Chrome
    if (kIsWeb) {
      return "http://127.0.0.1:8000";
    }

    // Real Android phone
    return "http://192.168.1.5:8000";
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;

class Esp32Service {
  static const String baseUrl = 'http://192.168.1.4:8000';
  static const String vitalsUrl = '$baseUrl/api/vitals';

  static Future<Map<String, dynamic>> getSensorData() async {
    final response = await http
        .get(Uri.parse(vitalsUrl))
        .timeout(const Duration(seconds: 8));

    if (response.statusCode != 200) {
      throw Exception('Backend error: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final data = decoded['data'];

    if (data == null) {
      throw Exception('No ESP32 readings received yet');
    }

    return Map<String, dynamic>.from(data);
  }
}
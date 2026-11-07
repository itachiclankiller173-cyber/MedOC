import 'dart:convert';
import 'package:http/http.dart' as http;

class Esp32Service {
  static const String baseUrl =
      'https://medoc-8rme.onrender.com';

  static const String vitalsUrl = '$baseUrl/api/vitals';

  static Future<Map<String, dynamic>> getSensorData() async {
    final response = await http
        .get(Uri.parse(vitalsUrl))
        .timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      throw Exception('Backend error: ${response.statusCode}');
    }

    final decoded =
        jsonDecode(response.body) as Map<String, dynamic>;

    if (decoded['success'] != true) {
      throw Exception('Failed to get MEDOC sensor data');
    }

    final data = decoded['data'];

    if (data == null || data is! Map) {
      throw Exception('No ESP32 readings received yet');
    }

    return Map<String, dynamic>.from(data);
  }
}
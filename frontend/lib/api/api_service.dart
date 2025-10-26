import 'dart:convert';
import 'package:frontend/models/alerts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Make sure this path matches your project structure

class ApiService {
  static String get baseUrl =>
      dotenv.env['API_BASE_URL'] ?? "http://192.168.29.223:8000";

  // Save token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("jwt_token", token);
  }

  // Get token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("jwt_token");
  }

  // Remove token
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("jwt_token");
  }

  // Register user
  static Future<bool> register(
      String name, String email, String phone, String password) async {
    final url = Uri.parse("$baseUrl/auth/register");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "email": email,
        "phone": phone,
        "password": password,
      }),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }

  // Login user
  static Future<bool> login(String email, String password) async {
    final url = Uri.parse("$baseUrl/auth/token");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      String token = data["access_token"];
      await saveToken(token);
      return true;
    }
    return false;
  }

  // Fetch alerts for logged-in user
  static Future<List<Alert>> getAlerts() async {
    final token = await getToken();
    if (token == null) return [];

    final url = Uri.parse("$baseUrl/alerts/me");
    final response = await http.get(
      url,
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> alertsJson = data['alerts'];
      return alertsJson.map((json) => Alert.fromJson(json)).toList();
    } else {
      return [];
    }
  }

  static Future<bool> deleteAlert(String alertId) async {
    final token = await getToken();
    if (token == null) return false;
    final url = Uri.parse('$baseUrl/alerts/$alertId');
    final response = await http.delete(url, headers: {
      'Authorization': 'Bearer $token', // Pass your token here
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  // Get user profile
  static Future<Map<String, dynamic>?> getProfile() async {
    final token = await getToken();
    if (token == null) return null;

    final url = Uri.parse("$baseUrl/users/me");
    final response = await http.get(
      url,
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  static Future<bool> registerPlayer(String playerId) async {
    final token = await getToken();
    if (token == null) return false;

    final url = Uri.parse("$baseUrl/users/player");
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: jsonEncode({"player_id": playerId}),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }
}

import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

class ApiService {
  /// Base URL automatically selecting localhost for Chrome/Web/Desktop vs Android Emulator
  static String get baseUrl {
    if (kIsWeb) {
      return "http://127.0.0.1:8000";
    }
    try {
      if (Platform.isAndroid) {
        return "http://10.0.2.2:8000";
      }
    } catch (_) {}
    return "http://127.0.0.1:8000";
  }

  /// 1. Register User (POST /auth/register)
  static Future<Map<String, dynamic>> registerUser({
    required String username,
    required String password,
    String role = "caregiver",
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/register"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "username": username,
        "password": password,
        "role": role,
      }),
    );

    return jsonDecode(response.body);
  }

  /// 2. Login User (POST /auth/login)
  static Future<Map<String, dynamic>> loginUser({
    required String username,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/login"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "username": username,
        "password": password,
      }),
    );

    return jsonDecode(response.body);
  }

  /// 3. Register Patient (POST /patient/register)
  static Future<Map<String, dynamic>> registerPatient({
    required String caregiverUsername,
    required String patientName,
    required String dob,
    required String gender,
    required String languagePreference,
    required bool readingPreference,
    required String dementiaStage,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/patient/register"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "caregiver_username": caregiverUsername,
        "patient_name": patientName,
        "dob": dob,
        "gender": gender,
        "language_preference": languagePreference,
        "reading_preference": readingPreference,
        "dementia_stage": dementiaStage,
      }),
    );

    return jsonDecode(response.body);
  }

  /// 4. Get Patients (GET /patient/{caregiver_username})
  static Future<dynamic> getPatients({
    required String caregiverUsername,
  }) async {
    final response = await http.get(
      Uri.parse("$baseUrl/patient/$caregiverUsername"),
      headers: {
        "Content-Type": "application/json",
      },
    );

    return jsonDecode(response.body);
  }
}
import 'package:flutter/foundation.dart';

import 'api_service.dart';

class RegisteredPatient {
  const RegisteredPatient({
    required this.name,
    required this.dateOfBirth,
    required this.readingPreference,
    this.dementiaStage,
    this.patientId,
  });

  final String? patientId;
  final String name;
  final DateTime dateOfBirth;
  final bool readingPreference;
  final String? dementiaStage;

  static RegisteredPatient? fromJson(Map<String, dynamic> json) {
    final name = json['patient_name'] as String?;
    final dobValue = json['dob'] as String?;
    final dateOfBirth = dobValue == null ? null : DateTime.tryParse(dobValue);
    final readingPreference = json['reading_preference'];
    final dementiaStage = json['dementia_stage'] as String? ?? json['dementiaStage'] as String?;
    final patientId = json['patient_id'] as String? ?? json['_id'] as String?;

    if (name == null || dateOfBirth == null || readingPreference is! bool) {
      return null;
    }

    return RegisteredPatient(
      name: name,
      dateOfBirth: dateOfBirth,
      readingPreference: readingPreference,
      dementiaStage: dementiaStage,
      patientId: patientId,
    );
  }
}

class PatientService extends ChangeNotifier {
  PatientService._();

  static final PatientService instance = PatientService._();

  RegisteredPatient? _patient;
  bool _isLoading = false;
  String? _error;

  RegisteredPatient? get patient => _patient;
  RegisteredPatient? get currentPatient => _patient;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String? get currentDementiaStage => _patient?.dementiaStage;

  void setPatient(RegisteredPatient? patient) {
    _patient = patient;
    notifyListeners();
  }

  Future<void> loadForCaregiver(String caregiverUsername) async {
    if (caregiverUsername.trim().isEmpty || _isLoading) return;

    _patient = null;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.getPatients(
        caregiverUsername: caregiverUsername,
      );
      final patients = response is List ? response : const [];
      _patient = patients
          .whereType<Map<String, dynamic>>()
          .map(RegisteredPatient.fromJson)
          .whereType<RegisteredPatient>()
          .firstOrNull;
      if (_patient == null) {
        _error = 'No registered patient found';
      }
    } catch (_) {
      _error = 'Unable to load patient data';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

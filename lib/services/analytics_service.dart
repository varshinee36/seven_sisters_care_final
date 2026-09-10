import 'package:flutter/foundation.dart';
import '../models/analytics_model.dart';
import 'api_service.dart';

/// Service responsible for fetching, caching, and updating Caregiver Dashboard
/// analytics from the FastAPI backend and MongoDB Atlas.
class AnalyticsService extends ChangeNotifier {
  AnalyticsService._();

  static final AnalyticsService instance = AnalyticsService._();

  DashboardAnalyticsModel _analytics = DashboardAnalyticsModel.defaults();
  bool _isLoading = false;
  String? _error;
  String? _currentPatientId;

  DashboardAnalyticsModel get analytics => _analytics;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get currentPatientId => _currentPatientId;
  bool get hasData => _analytics.hasData;

  /// Fetches aggregated and latest dashboard analytics for the single linked patient.
  /// Falls back to safe default values if the patient has no records or in case of network issues.
  Future<DashboardAnalyticsModel> fetchDashboardAnalytics(String patientId) async {
    final cleanId = patientId.trim();
    if (cleanId.isEmpty) {
      _analytics = DashboardAnalyticsModel.defaults();
      notifyListeners();
      return _analytics;
    }

    _currentPatientId = cleanId;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.getDashboardAnalytics(patientId: cleanId);
      _analytics = DashboardAnalyticsModel.fromJson(response);
      _error = null;
    } catch (e) {
      // In case of network error or backend offline, fall back safely to defaults without crashing
      _error = e.toString();
      _analytics = DashboardAnalyticsModel.defaults();
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    return _analytics;
  }

  /// Future-ready method to record game results into MongoDB via FastAPI.
  /// When called by Memory Hunt or Pair Finder, it records the session and refreshes analytics.
  Future<bool> recordGamePerformance(Map<String, dynamic> performanceData) async {
    try {
      final res = await ApiService.saveGamePerformance(performanceData);
      final success = res['id'] != null || res['message'] != null;

      final patientId = performanceData['patient_id'] as String?;
      if (success && patientId != null && patientId.isNotEmpty) {
        await fetchDashboardAnalytics(patientId);
      }
      return success;
    } catch (_) {
      return false;
    }
  }

  /// Allows setting mock or test analytics directly for widget test isolation.
  @visibleForTesting
  void setAnalyticsForTesting(DashboardAnalyticsModel model) {
    _analytics = model;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  /// Resets to default values.
  void reset() {
    _analytics = DashboardAnalyticsModel.defaults();
    _isLoading = false;
    _error = null;
    _currentPatientId = null;
    notifyListeners();
  }

  /// Alias for reset() to restore default fallback values.
  void resetToDefaults() => reset();
}

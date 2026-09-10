import 'package:flutter/material.dart';
import '../models/analytics_model.dart';
import '../services/analytics_service.dart';

/// Provider exposing AnalyticsService state reactively across the widget tree.
class AnalyticsProvider extends ChangeNotifier {
  final AnalyticsService _service;

  AnalyticsProvider([AnalyticsService? service])
      : _service = service ?? AnalyticsService.instance {
    _service.addListener(_onServiceChanged);
  }

  @override
  void dispose() {
    _service.removeListener(_onServiceChanged);
    super.dispose();
  }

  void _onServiceChanged() {
    notifyListeners();
  }

  DashboardAnalyticsModel get analytics => _service.analytics;
  bool get isLoading => _service.isLoading;
  String? get error => _service.error;
  bool get hasData => _service.hasData;

  Future<DashboardAnalyticsModel> fetchForPatient(String patientId) {
    return _service.fetchDashboardAnalytics(patientId);
  }

  Future<bool> recordGamePerformance(Map<String, dynamic> performanceData) {
    return _service.recordGamePerformance(performanceData);
  }
}

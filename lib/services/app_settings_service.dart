import 'package:flutter/material.dart';

/// Global application settings service managing dynamic font sizing
/// and theme mode across the entire app.
class AppSettingsService extends ChangeNotifier {
  AppSettingsService._();
  static final AppSettingsService instance = AppSettingsService._();

  String _themeName = "System";
  String _fontSizeName = "Medium";

  String get themeName => _themeName;
  String get fontSizeName => _fontSizeName;

  ThemeMode get themeMode {
    switch (_themeName) {
      case "Light":
        return ThemeMode.light;
      case "Dark":
        return ThemeMode.dark;
      case "System":
      default:
        return ThemeMode.system;
    }
  }

  /// Scale factor applied to TextScaler in MaterialApp builder:
  /// Small: 0.85x
  /// Medium: 1.0x (Default)
  /// Large: 1.25x
  double get fontScale {
    switch (_fontSizeName) {
      case "Small":
        return 0.85;
      case "Large":
        return 1.25;
      case "Medium":
      default:
        return 1.0;
    }
  }

  void setTheme(String theme) {
    if (_themeName != theme) {
      _themeName = theme;
      notifyListeners();
    }
  }

  void setFontSize(String size) {
    if (_fontSizeName != size) {
      _fontSizeName = size;
      notifyListeners();
    }
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// LanguageService manages persistent storage of selected language
/// using SharedPreferences, and notifies listeners on change.
class LanguageService extends ChangeNotifier {
  static const String prefLanguageKey = 'selected_language_code';

  static final LanguageService instance = LanguageService._internal();

  LanguageService._internal();
  factory LanguageService() => instance;

  SharedPreferences? _prefs;
  String _currentLanguageCode = 'en';

  String get currentLanguageCode => _currentLanguageCode;

  /// Initialize and load saved language from SharedPreferences.
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _currentLanguageCode = _prefs?.getString(prefLanguageKey) ?? 'en';
    notifyListeners();
  }

  /// Load currently saved language code.
  String getSavedLanguage() {
    if (_prefs != null) {
      return _prefs!.getString(prefLanguageKey) ?? _currentLanguageCode;
    }
    return _currentLanguageCode;
  }

  /// Save selected language code ('en', 'hi', 'as', 'bn') and notify listeners.
  Future<bool> saveLanguage(String languageCode) async {
    if (!['en', 'hi', 'as', 'bn'].contains(languageCode)) {
      return false;
    }

    _currentLanguageCode = languageCode;
    notifyListeners();

    _prefs ??= await SharedPreferences.getInstance();
    return await _prefs!.setString(prefLanguageKey, languageCode);
  }

  /// Save language by full display name ('English', 'Hindi', 'Assamese', 'Bengali').
  Future<bool> saveLanguageByName(String name) async {
    final code = codeFromName(name);
    return await saveLanguage(code);
  }

  /// Map language name to language code.
  static String codeFromName(String name) {
    switch (name.trim().toLowerCase()) {
      case 'hindi':
      case 'हिन्दी':
        return 'hi';
      case 'assamese':
      case 'অসমীয়া':
        return 'as';
      case 'bengali':
      case 'বাংলা':
        return 'bn';
      case 'english':
      default:
        return 'en';
    }
  }

  /// Map language code to display name.
  static String nameFromCode(String code) {
    switch (code.trim().toLowerCase()) {
      case 'hi':
        return 'Hindi';
      case 'as':
        return 'Assamese';
      case 'bn':
        return 'Bengali';
      case 'en':
      default:
        return 'English';
    }
  }
}

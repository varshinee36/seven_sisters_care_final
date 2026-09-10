import 'package:flutter/material.dart';
import '../services/language_service.dart';

/// LanguageProvider provides the current Locale across the entire widget tree
/// via Provider/ChangeNotifier, enabling instant UI updates without restart.
class LanguageProvider extends ChangeNotifier {
  final LanguageService _service;
  Locale _locale = const Locale('en');

  LanguageProvider(this._service) {
    _locale = Locale(_service.getSavedLanguage());
    _service.addListener(_onServiceChanged);
  }

  @override
  void dispose() {
    _service.removeListener(_onServiceChanged);
    super.dispose();
  }

  void _onServiceChanged() {
    final newCode = _service.currentLanguageCode;
    if (_locale.languageCode != newCode) {
      _locale = Locale(newCode);
      notifyListeners();
    }
  }

  Locale get currentLocale => _locale;
  String get languageCode => _locale.languageCode;
  String get currentLanguageName =>
      LanguageService.nameFromCode(_locale.languageCode);

  /// Change language by code ('en', 'hi', 'as', 'bn') and persist offline.
  Future<void> setLanguage(String code) async {
    if (!['en', 'hi', 'as', 'bn'].contains(code)) return;
    if (_locale.languageCode == code) return;

    _locale = Locale(code);
    notifyListeners();
    await _service.saveLanguage(code);
  }

  /// Change language by full name ('English', 'Hindi', 'Assamese', 'Bengali').
  Future<void> setLanguageByName(String name) async {
    final code = LanguageService.codeFromName(name);
    await setLanguage(code);
  }
}

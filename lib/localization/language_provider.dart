import 'package:flutter/material.dart';

import '../services/preference_service.dart';
import 'language_manager.dart';

class LanguageProvider extends ChangeNotifier {

  String _language = LanguageManager.english;

  String get language => _language;

  bool get isEnglish => _language == LanguageManager.english;

  bool get isHindi => _language == LanguageManager.hindi;

  /// Load saved language when app starts
  Future<void> loadLanguage() async {
    _language = await PreferenceService.getLanguage();

    LanguageManager.setLanguage(_language);

    notifyListeners();
  }

  /// Change language
  Future<void> changeLanguage(String language) async {

    _language = language;

    LanguageManager.setLanguage(language);

    await PreferenceService.saveLanguage(language);

    notifyListeners();
  }
}
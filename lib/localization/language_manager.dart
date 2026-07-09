import '../services/preference_service.dart';

class LanguageManager {
  static const String english = "english";
  static const String hindi = "hindi";

  static String _currentLanguage = english;

  static String get currentLanguage => _currentLanguage;

  static bool get isEnglish => _currentLanguage == english;

  static bool get isHindi => _currentLanguage == hindi;

  static void setLanguage(String language) {
    _currentLanguage = language;
  }

  static Future<void> loadLanguage() async {
    _currentLanguage = await PreferenceService.getLanguage();
  }
}
import 'package:shared_preferences/shared_preferences.dart';

class PreferenceService {
  static const String languageKey = "selected_language";

  /// Save selected language
  static Future<void> saveLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(languageKey, language);
  }

  /// Get selected language
  static Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(languageKey) ?? "english";
  }

  /// Clear all preferences
  static Future<void> clearPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
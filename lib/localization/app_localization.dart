import 'english/common.dart' as englishCommon;
import 'english/authentication.dart' as englishAuthentication;
import 'english/welcome.dart' as englishWelcome;
import 'english/home.dart' as englishHome;
import 'english/tutorials.dart' as englishTutorials;
import 'english/appointments.dart' as englishAppointments;
import 'english/profile.dart' as englishProfile;
import 'english/video_call.dart' as englishVideoCall;

import 'hindi/common.dart' as hindiCommon;
import 'hindi/authentication.dart' as hindiAuthentication;
import 'hindi/welcome.dart' as hindiWelcome;
import 'hindi/home.dart' as hindiHome;
import 'hindi/tutorials.dart' as hindiTutorials;
import 'hindi/appointments.dart' as hindiAppointments;
import 'hindi/profile.dart' as hindiProfile;
import 'hindi/video_call.dart' as hindiVideoCall;
import 'english/language_selection.dart' as englishLanguageSelection;
import 'hindi/language_selection.dart' as hindiLanguageSelection;

import 'language_manager.dart';

class AppLocalization {
  /// Returns UI text
  static String ui(String module, String key) {
    final moduleData = _getModule(module);

    if (moduleData.containsKey("ui")) {
      return moduleData["ui"]?[key] ?? key;
    }

    return key;
  }

  /// Returns TTS text
  static String tts(String module, String key) {
    final moduleData = _getModule(module);

    if (moduleData.containsKey("tts")) {
      return moduleData["tts"]?[key] ?? key;
    }

    return key;
  }

  static Map<String, dynamic> _getModule(String module) {
    final bool english = LanguageManager.isEnglish;

    switch (module) {
      case "common":
        return english ? englishCommon.common : hindiCommon.common;

      case "authentication":
        return english
            ? englishAuthentication.authentication
            : hindiAuthentication.authentication;

      case "welcome":
        return english
            ? englishWelcome.welcome
            : hindiWelcome.welcome;

      case "home":
        return english ? englishHome.home : hindiHome.home;

      case "tutorials":
        return english
            ? englishTutorials.tutorials
            : hindiTutorials.tutorials;

      case "appointments":
        return english
            ? englishAppointments.appointments
            : hindiAppointments.appointments;

      case "profile":
        return english
            ? englishProfile.profile
            : hindiProfile.profile;

      case "video_call":
        return english
            ? englishVideoCall.videoCall
            : hindiVideoCall.videoCall;

      case "language_selection":
        return LanguageManager.isEnglish
            ? englishLanguageSelection.languageSelection
            : hindiLanguageSelection.languageSelection;

      default:
        return {};
    }
  }
}
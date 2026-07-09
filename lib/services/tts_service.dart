import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../localization/language_manager.dart';

class TTSService {
  TTSService._();

  static final FlutterTts _tts = FlutterTts();

  static bool _initialized = false;

  static bool _isSpeaking = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    await _tts.awaitSpeakCompletion(true);

    await _tts.setSpeechRate(0.45);

    await _tts.setPitch(1.0);

    await _tts.setVolume(1.0);

    await _updateLanguage();

    _tts.setStartHandler(() {
      _isSpeaking = true;
      debugPrint("TTS Started");
    });

    _tts.setCompletionHandler(() {
      _isSpeaking = false;
      debugPrint("TTS Completed");
    });

    _tts.setCancelHandler(() {
      _isSpeaking = false;
      debugPrint("TTS Cancelled");
    });

    _tts.setErrorHandler((message) {
      _isSpeaking = false;
      debugPrint("TTS Error : $message");
    });

    _initialized = true;
  }

  static Future<void> _updateLanguage() async {
    if (LanguageManager.isEnglish) {
      await _tts.setLanguage("en-US");
    } else {
      await _tts.setLanguage("hi-IN");
    }
  }

  static Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;

    await initialize();

    await _updateLanguage();

    await _tts.stop();

    await _tts.speak(text);
  }

  static Future<void> stop() async {
    await _tts.stop();
    _isSpeaking = false;
  }

  static Future<void> pause() async {
    try {
      await _tts.pause();
    } catch (_) {}
  }

  static Future<void> setSpeechRate(double rate) async {
    await _tts.setSpeechRate(rate);
  }

  static Future<void> setPitch(double pitch) async {
    await _tts.setPitch(pitch);
  }

  static Future<void> setVolume(double volume) async {
    await _tts.setVolume(volume);
  }

  static bool get isSpeaking => _isSpeaking;
}
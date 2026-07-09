import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../localization/language_manager.dart';

class SpeechService {
  SpeechService._();

  static final SpeechToText _speech = SpeechToText();

  static bool _initialized = false;

  static bool _isListening = false;

  static Future<bool> initialize() async {
    if (_initialized) return true;

    _initialized = await _speech.initialize(
      onStatus: (status) {
        debugPrint("Speech Status: $status");

        _isListening = status == "listening";
      },
      onError: (error) {
        debugPrint("Speech Error: $error");
      },
    );

    return _initialized;
  }

  static Future<void> startListening({
    required Function(String text) onResult,
  }) async {
    bool available = await initialize();

    if (!available) return;

    await _speech.listen(
      localeId:
          LanguageManager.isEnglish ? "en_IN" : "hi_IN",

      listenMode: ListenMode.confirmation,

      onResult: (result) {
        onResult(result.recognizedWords);
      },
    );

    _isListening = true;
  }

  static Future<void> stopListening() async {
    await _speech.stop();

    _isListening = false;
  }

  static Future<void> cancelListening() async {
    await _speech.cancel();

    _isListening = false;
  }

  static bool get isListening => _isListening;
}
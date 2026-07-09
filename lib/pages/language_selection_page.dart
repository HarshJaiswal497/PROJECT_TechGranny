import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../localization/app_localization.dart';
import '../localization/language_provider.dart';
import '../services/preference_service.dart';
import '../services/tts_service.dart';
import 'welcome.dart';

class LanguageSelectionPage extends StatefulWidget {
  const LanguageSelectionPage({super.key});

  @override
  State<LanguageSelectionPage> createState() =>
      _LanguageSelectionPageState();
}

class _LanguageSelectionPageState
    extends State<LanguageSelectionPage> {

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speakWelcome();
    });
  }

  Future<void> _speakWelcome() async {
    await TTSService.speak(
      AppLocalization.tts(
        "language_selection",
        "welcome",
      ),
    );

    await Future.delayed(
      const Duration(milliseconds: 600),
    );

    await TTSService.speak(
      AppLocalization.tts(
        "language_selection",
        "selectLanguage",
      ),
    );
  }

  Future<void> _selectLanguage(String language) async {

    final provider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );

    await provider.changeLanguage(language);

    await PreferenceService.saveLanguage(language);

    if (language == "english") {
      await TTSService.speak(
        AppLocalization.tts(
          "language_selection",
          "englishSelected",
        ),
      );
    } else {
      await TTSService.speak(
        AppLocalization.tts(
          "language_selection",
          "hindiSelected",
        ),
      );
    }

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const WelcomePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.language,
                size: 90,
                color: Colors.blue,
              ),

              const SizedBox(height: 20),

              Text(
                AppLocalization.ui(
                  "language_selection",
                  "title",
                ),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                AppLocalization.ui(
                  "language_selection",
                  "subtitle",
                ),
                style: const TextStyle(
                  fontSize: 22,
                ),
              ),

              const SizedBox(height: 50),

              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () => _selectLanguage("hindi"),
                  child: Text(
                    "🇮🇳 ${AppLocalization.ui(
                      "language_selection",
                      "hindi",
                    )}",
                    style: const TextStyle(
                      fontSize: 22,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () => _selectLanguage("english"),
                  child: Text(
                    "🇬🇧 ${AppLocalization.ui(
                      "language_selection",
                      "english",
                    )}",
                    style: const TextStyle(
                      fontSize: 22,
                    ),
                  ),
                ),
              ),
              ],
            ),
          ),
        ),
      );
    }
    }
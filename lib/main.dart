import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'localization/language_provider.dart';
import 'pages/language_selection_page.dart';
import 'services/tts_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize TTS
  await TTSService.initialize();

  // Load saved language
  final languageProvider = LanguageProvider();
  await languageProvider.loadLanguage();
  runApp(
    ChangeNotifierProvider(
      create: (_) => languageProvider,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'TechGranny',

          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
            ),
            useMaterial3: true,
          ),

          home: const LanguageSelectionPage(),
        );
      },
    );
  }
}
import 'package:flutter/material.dart';

import '../localization/app_localization.dart';
import '../services/tts_service.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await TTSService.initialize();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await TTSService.speak(
        AppLocalization.tts(
          "appointments",
          "intro",
        ),
      );
    });
  }

  @override
  void dispose() {
    TTSService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalization.ui(
            "appointments",
            "title",
          ),
        ),
      ),
      body: Center(
        child: Text(
          AppLocalization.ui(
            "appointments",
            "comingSoon",
          ),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
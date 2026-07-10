import 'package:flutter/material.dart';

import '../localization/app_localization.dart';
import '../services/tts_service.dart';
import 'tutorials/send_photos_tutorial_page.dart';
import 'tutorials/pay_via_upi_tutorial_page.dart';
import 'tutorials/video_call_tutorial_page.dart';
// import 'tutorials/whatsapp_tutorial_page.dart';
// import 'tutorials/video_call_tutorial_page.dart';
// import 'tutorials/doctor_booking_tutorial_page.dart';

class TutorialsPage extends StatefulWidget {
  const TutorialsPage({super.key});

  @override
  State<TutorialsPage> createState() => _TutorialsPageState();
}

class _TutorialsPageState extends State<TutorialsPage> {
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
          "tutorials",
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
        centerTitle: true,
        title: Text(
          AppLocalization.ui(
            "tutorials",
            "title",
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _tutorialCard(
            context: context,
            icon: Icons.qr_code_scanner,
            title: AppLocalization.ui(
              "tutorials",
              "upi",
            ),
            subtitle: AppLocalization.tts(
              "tutorials",
              "upi",
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PayViaUpiTutorialPage(),
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          _tutorialCard(
            context: context,
            icon: Icons.video_call,
            title: AppLocalization.ui(
              "tutorials",
              "videoCall",
            ),
            subtitle: AppLocalization.tts(
              "tutorials",
              "videoCall",
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const VideoCallTutorialPage(),
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          _tutorialCard(
            context: context,
            icon: Icons.photo,
            title: AppLocalization.ui(
              "tutorials",
              "whatsapp",
            ),
            subtitle: AppLocalization.tts(
              "tutorials",
              "whatsapp",
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SendPhotosTutorialPage(),
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          _tutorialCard(
            context: context,
            icon: Icons.local_hospital,
            title: AppLocalization.ui(
              "tutorials",
              "doctor",
            ),
            subtitle: AppLocalization.tts(
              "tutorials",
              "doctor",
            ),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Doctor tutorial will be connected here."),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _tutorialCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 12,
        ),
        leading: CircleAvatar(
          radius: 26,
          backgroundColor: const Color(0xFF9B4DFF),
          child: Icon(
            icon,
            color: Colors.white,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(subtitle),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 18,
        ),
        onTap: onTap,
      ),
    );
  }
}
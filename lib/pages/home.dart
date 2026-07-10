// ignore_for_file: deprecated_member_use

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/tts_service.dart';
import '../localization/app_localization.dart';
import '../localization/language_manager.dart';
import 'package:techgrannyapp/pages/tutorials/video_call_tutorial_page.dart';
import 'package:techgrannyapp/pages/tutorials/pay_via_upi_tutorial_page.dart';
import 'package:techgrannyapp/pages/tutorials/send_photos_tutorial_page.dart';

class HomePage extends StatefulWidget {
  final VoidCallback onViewAllTutorials;
  final VoidCallback onViewAllAppointments;
  const HomePage({
    super.key,
    required this.onViewAllTutorials,
    required this.onViewAllAppointments,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // ---------------- USER DATA ----------------
  String _userName = '';
  bool _loadingName = true;

  // ---------------- VOICE / OVERLAY ----------------

  bool _isSpeaking = false;
  bool _shouldStop = false;

  // highlight targets
  // 0 = none
  // 1 = header
  // 2 = continue learning
  // 3 = explore tutorials
  // 4 = appointment section
  // 5 = bottom navigation
  int _highlightTarget = 0;

  @override
  void initState() {
    super.initState();
    _fetchUserName();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await TTSService.initialize();

      await TTSService.setLanguage(
        LanguageManager.currentLanguage,
      );

      await _speakHomeInstructions();
    });
  }


  Future<void> _fetchUserName() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _loadingName = false;
        return;
      }

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists && doc.data() != null) {
        setState(() {
          _userName = doc['name'] ?? '';
          _loadingName = false;
        });
      } else {
        setState(() => _loadingName = false);
      }
    } catch (e) {
      debugPrint('Error fetching user name: $e');
      setState(() => _loadingName = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // ================= MAIN CONTENT =================
          Container(
            decoration: const BoxDecoration(
              gradient: SweepGradient(
                center: Alignment.center,
                startAngle: 0.0,
                endAngle: 6.28319,
                colors: [
                  Color(0xFFEBD4FF),
                  Color(0xFFFFE4F3),
                  Color(0xFFCCE5FF),
                  Color(0xFFEBD4FF),
                ],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ================= HEADER =================
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _highlightWrapper(
                        active: _highlightTarget == 1,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.35),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const CircleAvatar(
                                    radius: 26,
                                    backgroundImage: AssetImage(
                                      'assets/images/profile.jpg',
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _loadingName
                                              ? AppLocalization.ui("home", "greeting")
                                              : _userName.isNotEmpty
                                                  ? "${AppLocalization.ui("home", "greetingWithName")} $_userName 👋"
                                                  : AppLocalization.ui("home", "greeting"),
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        Text(
                                          AppLocalization.ui(
                                            "home",
                                            "welcomeBack",
                                          ),
                                          style: const  TextStyle(
                                            fontSize: 14,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // 🔊 VOICE REPLAY ICON
                                  GestureDetector(
                                    onTap: () async {
                                      await TTSService.stop();

                                      await _speakHomeInstructions();
                                    },
                                    child: const CircleAvatar(
                                      backgroundColor: Colors.deepPurple,
                                      child: Icon(
                                        Icons.volume_up_rounded,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ================= CONTINUE LEARNING =================
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _highlightWrapper(
                        active: _highlightTarget == 2,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.deepPurple.withOpacity(0.15),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppLocalization.ui(
                                        "home",
                                        "continueLearningTitle",
                                      ),
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      AppLocalization.ui(
                                        "home",
                                        "continueLearningSubtitle",
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.black54,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    LinearProgressIndicator(
                                      value: 0.3,
                                      minHeight: 5,
                                      borderRadius: BorderRadius.circular(8),
                                      backgroundColor: Colors.grey[200],
                                      color: Colors.green,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                         AppLocalization.ui(
                                           "home",
                                           "resume",
                                         ),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // ================= EXPLORE TUTORIALS =================
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _highlightWrapper(
                        active: _highlightTarget == 3,
                        child: sectionHeader(
                          title: AppLocalization.ui(
                            "home",
                            "exploreTutorials",
                          ),
                          onPressed: widget.onViewAllTutorials,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    SizedBox(
                      height: 200,
                      child: _highlightWrapper(
                        active: _highlightTarget == 3,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.only(left: 16),
                          children: [
                            buildTutorialCard(
                              AppLocalization.ui(
                                "home",
                                "videoCallTutorial",
                              ),
                              "assets/images/video.jpg",
                              0.6,
                              Icons.videocam_rounded,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const VideoCallTutorialPage(),
                                  ),
                                );
                              },
                            ),
                            buildTutorialCard(
                              AppLocalization.ui(
                                "home",
                                "upiTutorial",
                              ),
                              "assets/images/upi.jpg",
                              0.3,
                              Icons.qr_code_2_rounded,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const PayViaUpiTutorialPage(),
                                  ),
                                );
                              },
                            ),
                            buildTutorialCard(
                              AppLocalization.ui(
                                "home",
                                "whatsappTutorial",
                              ),
                              "assets/images/chat.jpg",
                              0.8,
                              Icons.chat_bubble_outline_rounded,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const SendPhotosTutorialPage(),
                                  ),
                                );
                              },
                            ),
                            buildTutorialCard(
                              AppLocalization.ui(
                                "home",
                                "doctorTutorial",
                              ),
                              "assets/images/doctor.jpg",
                              0.0,
                              Icons.local_hospital_rounded,
                              onTap: () {},
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // ================= APPOINTMENT =================
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _highlightWrapper(
                        active: _highlightTarget == 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            sectionHeader(
                              title: AppLocalization.ui(
                                "home",
                                "bookAppointment",
                              ),
                              onPressed: widget.onViewAllAppointments,
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.deepPurple.withOpacity(0.15),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.asset(
                                      "assets/images/video.jpg",
                                      height: 60,
                                      width: 60,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          AppLocalization.ui(
                                            "home",
                                            "needHelp",
                                          ),
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          AppLocalization.ui(
                                            "home",
                                            "appointmentDescription",
                                          ),
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.deepPurple,
                                    ),
                                    child: Text(
                                     AppLocalization.ui(
                                       "home",
                                       "book",
                                     ),
                                     style: const TextStyle(
                                       color: Colors.white,
                                     ),
                                   ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ================= OVERLAY =================
          if (_isSpeaking) _buildOverlay(),
        ],
      ),
    );
  }

  // ================= HIGHLIGHT WRAPPER =================
  Widget _highlightWrapper({required bool active, required Widget child}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        boxShadow: active
            ? [
                BoxShadow(
                  color: Colors.redAccent.withOpacity(0.8),
                  blurRadius: 20,
                  spreadRadius: 4,
                ),
              ]
            : [],
      ),
      child: child,
    );
  }

  // ================= OVERLAY =================
  Widget _buildOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.45),
        child: Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: _stopSpeaking,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9B4DFF),
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 18,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child:  Text(
                AppLocalization.ui(
                  "home",
                  "skip",
                ),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ================= VOICE INSTRUCTIONS =================
  Future<void> _speakHomeInstructions() async {
    if (_isSpeaking) return;

    _shouldStop = false;

    setState(() {
      _isSpeaking = true;
      _highlightTarget = 1;
    });

    try {
      // Header
      await TTSService.speak(
        AppLocalization.tts(
          "home",
          "headerIntro",
        ),
      );

      if (_shouldStop) return;

      // Continue Learning
      if (mounted) {
        setState(() {
          _highlightTarget = 2;
        });
      }

      await TTSService.speak(
        AppLocalization.tts(
          "home",
          "continueLearning",
        ),
      );

      if (_shouldStop) return;

      // Tutorials
      if (mounted) {
        setState(() {
          _highlightTarget = 3;
        });
      }

      await TTSService.speak(
        AppLocalization.tts(
          "home",
          "tutorials",
        ),
      );

      if (_shouldStop) return;

      // Appointment
      if (mounted) {
        setState(() {
          _highlightTarget = 4;
        });
      }

      await TTSService.speak(
        AppLocalization.tts(
          "home",
          "appointments",
        ),
      );

      if (_shouldStop) return;

      // Bottom Navigation
//       if (mounted) {
//         setState(() {
//           _highlightTarget = 5;
//         });
//       }
//
//       await TTSService.speak(
//         AppLocalization.tts(
//           "home",
//           "bottomNavigation",
//         ),
//       );
//
//       if (_shouldStop) return;

      // Replay
      if (mounted) {
        setState(() {
          _highlightTarget = 1;
        });
      }

      await TTSService.speak(
        AppLocalization.tts(
          "home",
          "replayInstruction",
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSpeaking = false;
          _highlightTarget = 0;
          _shouldStop = false;
        });
      }
    }
  }
  Future<void> _stopSpeaking() async {
    _shouldStop = true;

    await TTSService.stop();

    if (mounted) {
      setState(() {
        _isSpeaking = false;
        _highlightTarget = 0;
      });
    }
  }

  @override
  void dispose() {
    TTSService.stop();
    super.dispose();
  }

  Widget buildTutorialCard(
    String title,
    String imagePath,
    double progress,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        splashColor: Colors.deepPurple.withOpacity(0.1),
        highlightColor: Colors.deepPurple.withOpacity(0.05),
        child: Container(
          width: 160,
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.deepPurple.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: Image.asset(
                      imagePath,
                      height: 90,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.white,
                      child: Icon(icon, size: 16, color: Colors.black87),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 5,
                      borderRadius: BorderRadius.circular(8),
                      backgroundColor: Colors.grey[200],
                      color: Colors.black87,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${(progress * 100).round()}${AppLocalization.ui(
                        "home",
                        "progressDone",
                      )}",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget sectionHeader({
    required String title,
    required VoidCallback onPressed,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(50, 30),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
                   AppLocalization.ui(
                     "home",
                     "viewAll",
                   ),
            style: const TextStyle(
              fontSize: 13,
              color: Colors.deepPurple,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

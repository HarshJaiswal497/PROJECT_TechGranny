// ignore_for_file: deprecated_member_use

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:techgrannyapp/pages/tutorials/video_call_tutorial_page.dart';

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
  final FlutterTts _tts = FlutterTts();
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
    _initTts();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speakHomeInstructions();
    });
  }

  Future<void> _initTts() async {
    await _tts.awaitSpeakCompletion(true);
    await _tts.setLanguage("hi-IN");
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
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
                                              ? "Hi 👋"
                                              : _userName.isNotEmpty
                                              ? "Hi, $_userName Ji 👋"
                                              : "Hi 👋",
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const Text(
                                          "Welcome back!",
                                          style: TextStyle(
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
                                      await _tts.stop();
                                      _speakHomeInstructions();
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
                                    const Text(
                                      "Continue Learning",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      "WhatsApp – Step 3 of 10",
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
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
                                child: const Text(
                                  "Resume",
                                  style: TextStyle(color: Colors.white),
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
                          title: "Explore Tutorials",
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
                              "Make a Video Call",
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
                              "Pay Using UPI",
                              "assets/images/upi.jpg",
                              0.3,
                              Icons.qr_code_2_rounded,
                              onTap: () {},
                            ),
                            buildTutorialCard(
                              "Send Photos on WhatsApp",
                              "assets/images/chat.jpg",
                              0.8,
                              Icons.chat_bubble_outline_rounded,
                              onTap: () {},
                            ),
                            buildTutorialCard(
                              "Book a Doctor Online",
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
                              title: "Book an Appointment",
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
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Need more help?",
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          "Book an online session with a Tech Mentor via video call.",
                                          style: TextStyle(
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
                                    child: const Text(
                                      "Book",
                                      style: TextStyle(color: Colors.white),
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
              child: const Text(
                "Skip",
                style: TextStyle(
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

    bool abort() => _shouldStop;

    try {
      final name = _userName.isNotEmpty ? _userName : "जी";

      await _tts.speak(
        "नमस्ते $name! टेकग्रैनी में आपका बहुत बहुत स्वागत है। "
        "यहाँ आप मोबाइल और इंटरनेट को आसान तरीके से सीख सकती हैं।",
      );
      if (abort()) return;

      setState(() => _highlightTarget = 2);
      await _tts.speak(
        "यहाँ आप अपनी पढ़ाई वहीं से शुरू कर सकती हैं, "
        "जहाँ आपने पिछली बार छोड़ा था। "
        "रिज़्यूम बटन दबाकर आप आगे सीख सकती हैं।",
      );
      if (abort()) return;

      setState(() => _highlightTarget = 3);
      await _tts.speak(
        "इस सेक्शन में छोटे छोटे ट्यूटोरियल हैं। "
        "जैसे वीडियो कॉल करना, यूपीआई से पेमेंट करना, "
        "या व्हाट्सएप इस्तेमाल करना। "
        "किसी भी कार्ड को टैप करके सीखना शुरू करें।",
      );
      if (abort()) return;

      setState(() => _highlightTarget = 4);
      await _tts.speak(
        "अगर आपको कहीं भी दिक्कत हो, "
        "तो यहाँ से आप टेक मेंटर के साथ वीडियो कॉल बुक कर सकती हैं। "
        "वे आपकी मदद करेंगे।",
      );
      if (abort()) return;

      setState(() => _highlightTarget = 5);
      await _tts.speak(
        "नीचे नेविगेशन बार से आप होम, लर्न, अपॉइंटमेंट "
        "और प्रोफाइल सेक्शन में जा सकती हैं।",
      );
      if (abort()) return;

      setState(() => _highlightTarget = 1);
      await _tts.speak(
        "निर्देश दोबारा सुनने के लिए "
        "ऊपर वॉइस आइकन को टैप करें। "
        "हम हर कदम पर आपके साथ हैं।",
      );
    } catch (_) {}

    setState(() {
      _isSpeaking = false;
      _highlightTarget = 0;
      _shouldStop = false;
    });
  }

  Future<void> _stopSpeaking() async {
    _shouldStop = true;
    try {
      await _tts.stop();
    } catch (_) {}

    setState(() {
      _isSpeaking = false;
      _highlightTarget = 0;
    });
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
                      "${(progress * 100).round()}% done",
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
          child: const Text(
            "View All →",
            style: TextStyle(
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

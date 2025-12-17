// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class VideoCallTutorialPage extends StatefulWidget {
  const VideoCallTutorialPage({super.key});

  @override
  State<VideoCallTutorialPage> createState() => _VideoCallTutorialPageState();
}

class _VideoCallTutorialPageState extends State<VideoCallTutorialPage> {
  final FlutterTts _tts = FlutterTts();

  int _currentStep = 0;
  bool _isSpeaking = false;
  // ignore: unused_field
  bool _shouldStop = false;

  final List<_TutorialStep> _steps = [
    _TutorialStep(
      title: "Open WhatsApp",
      instruction: "सबसे पहले WhatsApp ऐप खोलिए।",
      imagePath: "assets/images/tutorials/whatsapp_open.jpeg",
    ),
    _TutorialStep(
      title: "Find the Contact",
      instruction:
          "अगर आपका कॉन्टैक्ट लिस्ट में दिख रहा है, तो उसका नाम दबाएँ। "
          "अगर नहीं दिख रहा है, तो ऊपर सर्च बटन दबाकर नाम लिखें।",
      imagePath: "assets/images/tutorials/whatsapp_contacts.jpeg",
    ),
    _TutorialStep(
      title: "Open Chat",
      instruction: "अब उस व्यक्ति के नाम पर टैप करें।",
      imagePath: "assets/images/tutorials/whatsapp_chat.jpeg",
    ),
    _TutorialStep(
      title: "Tap Video Call",
      instruction: "अब ऊपर वीडियो कैमरा के आइकॉन को दबाएँ।",
      imagePath: "assets/images/tutorials/whatsapp_video.jpeg",
    ),
    _TutorialStep(
      title: "Success",
      instruction:
          "शाबाश! आपकी वीडियो कॉल शुरू हो गई है। "
          "आपने सीख लिया कि वीडियो कॉल कैसे करते हैं।",
      imagePath: "assets/images/tutorials/whatsapp_success.jpeg",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initTts();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speakCurrentStep();
    });
  }

  Future<void> _initTts() async {
    await _tts.awaitSpeakCompletion(true);
    await _tts.setLanguage("hi-IN");
    await _tts.setSpeechRate(0.5);
  }

  // ---------------- VOICE ----------------
  Future<void> _speakCurrentStep() async {
    if (_isSpeaking) return;

    _shouldStop = false;
    setState(() => _isSpeaking = true);

    try {
      await _tts.speak(_steps[_currentStep].instruction);
    } catch (_) {}

    if (mounted) {
      setState(() {
        _isSpeaking = false;
        _shouldStop = false;
      });
    }
  }

  Future<void> _stopSpeaking() async {
    _shouldStop = true;
    try {
      await _tts.stop();
    } catch (_) {}
    setState(() => _isSpeaking = false);
  }

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() => _currentStep++);
      _speakCurrentStep();
    } else {
      Navigator.pop(context);
    }
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildMainContent(),

          // 🔊 Replay voice
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(
                Icons.volume_up,
                size: 36,
                color: Color(0xFF9B4DFF),
              ),
              onPressed: _speakCurrentStep,
            ),
          ),

          if (_isSpeaking) _buildOverlay(),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    final step = _steps[_currentStep];
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
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
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 30),

              Text(
                "Step ${_currentStep + 1} of ${_steps.length}",
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),

              const SizedBox(height: 12),

              Text(
                step.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 24),

              // 🔹 BIGGER IMAGE PLACEHOLDER
              Container(
                height: screenHeight * 0.45, // 👈 FIXED (bigger image)
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    step.imagePath,
                    fit: BoxFit.contain,
                    width: double.infinity,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                step.instruction,
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),

              const SizedBox(height: 20),

              _progressDots(),

              const Spacer(),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _speakCurrentStep,
                      child: const Text("Repeat"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _nextStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2FA4FF),
                      ),
                      child: Text(
                        _currentStep == _steps.length - 1 ? "Finish" : "Next",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Exit Tutorial"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _progressDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_steps.length, (i) {
        final active = i <= _currentStep;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? Colors.deepPurple : Colors.grey[300],
          ),
        );
      }),
    );
  }

  // OVERLAY
  Widget _buildOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.45),
        child: Stack(
          children: [
            Positioned(
              bottom: 110, // 👈 above bottom nav
              right: 20,
              child: SizedBox(
                height: 40,
                child: ElevatedButton(
                  onPressed: _stopSpeaking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9B4DFF),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Skip Voice",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- MODEL ----------------
class _TutorialStep {
  final String title;
  final String instruction;
  final String imagePath;

  _TutorialStep({
    required this.title,
    required this.instruction,
    required this.imagePath,
  });
}

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:techgrannyapp/pages/login.dart';
import 'package:techgrannyapp/pages/signup.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with TickerProviderStateMixin {
  late FlutterTts flutterTts;
  int _currentStep = 0;

  late AnimationController loginGlowController;
  late AnimationController signupGlowController;
  late AnimationController voiceGlowController;

  @override
  void initState() {
    super.initState();
    _initTts();
    _initAnimations();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speakInstructionsSequence();
    });
  }

  void _initTts() async {
    flutterTts = FlutterTts();
    await flutterTts.awaitSpeakCompletion(true);
    await flutterTts.setLanguage("hi-IN");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
  }

  void _initAnimations() {
    loginGlowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    signupGlowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    voiceGlowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  Future<void> _speakInstructionsSequence() async {
    try {
      setState(() => _currentStep = 3); // highlight voice icon
      flutterTts.awaitSpeakCompletion(true);

      await flutterTts.speak("नमस्ते! टेकग्रैनी में आपका स्वागत है।");
      await Future.delayed(const Duration(milliseconds: 500));
      await flutterTts.speak("यहाँ आपको डिजिटल दुनिया में कदम रखने में मदद मिलेगी।");
      await Future.delayed(const Duration(milliseconds: 500));
      await flutterTts.speak(
          "टॉप पर वॉइस आइकॉन को टैप करें यदि आप निर्देश दोबारा सुनना चाहते हैं।");
      await Future.delayed(const Duration(milliseconds: 500));

      // Login button
      setState(() => _currentStep = 1);
      await flutterTts.speak("यह लॉगिन बटन है।");
      await Future.delayed(const Duration(milliseconds: 500));
      await flutterTts.speak("यदि आपके पास पहले से अकाउंट है तो इसे टैप करें।");
      await Future.delayed(const Duration(milliseconds: 500));

      // Sign Up button
      setState(() => _currentStep = 2);
      await flutterTts.speak("यह साइन अप बटन है।");
      await Future.delayed(const Duration(milliseconds: 500));
      await flutterTts.speak(
          "यदि आप नए उपयोगकर्ता हैं तो इसे टैप करके अकाउंट बनाएं।");
      await Future.delayed(const Duration(milliseconds: 500));

      // Replay instruction
      setState(() => _currentStep = 3);
      await flutterTts.speak(
          "निर्देश दोबारा सुनने के लिए ऊपर वॉइस आइकॉन को टैप करें।");

      setState(() => _currentStep = 0); // reset highlights
    } catch (e) {
      debugPrint("TTS Error: $e");
    }
  }

  @override
  void dispose() {
    flutterTts.stop();
    loginGlowController.dispose();
    signupGlowController.dispose();
    voiceGlowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isSmall = width < 380;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: isSmall ? 190 : 230,
                      height: isSmall ? 190 : 230,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: const DecorationImage(
                          image: AssetImage('assets/images/main.jpg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 5,
                      right: 5,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: _currentStep == 3
                              ? [
                                  BoxShadow(
                                    color: Colors.redAccent.withOpacity(0.8),
                                    blurRadius: 20,
                                    spreadRadius: 4,
                                  ),
                                ]
                              : [],
                        ),
                        child: GestureDetector(
                          onTap: _speakInstructionsSequence,
                          child: Container(
                            width: 58,
                            height: 58,
                            decoration: const BoxDecoration(
                              color: Color(0xFF9B4DFF),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.volume_up,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.volume_up,
                        color: Color(0xFF6A3BFF),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Hindi voice support available',
                        style: const TextStyle(
                          fontFamily: 'OpenSans',
                          fontSize: 13,
                          color: Color(0xFF6A3BFF),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'Welcome to TechGranny',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Pacifico',
                    fontSize: isSmall ? 32 : 36,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                    shadows: const [
                      Shadow(
                        color: Colors.black26,
                        offset: Offset(1, 1),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Your friendly guide to the digital world.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 15,
                    color: Colors.black87.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 55),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: _currentStep == 1
                            ? [
                                BoxShadow(
                                  color: Colors.redAccent.withOpacity(0.8),
                                  blurRadius: 20,
                                  spreadRadius: 4,
                                ),
                              ]
                            : [],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LogInPage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF05C46B),
                          padding: const EdgeInsets.symmetric(vertical: 22),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 6,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.login, color: Colors.white, size: 22),
                            SizedBox(width: 8),
                            Text(
                              'Login',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: _currentStep == 2
                            ? [
                                BoxShadow(
                                  color: Colors.redAccent.withOpacity(0.8),
                                  blurRadius: 20,
                                  spreadRadius: 4,
                                ),
                              ]
                            : [],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignUpPage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2FA4FF),
                          padding: const EdgeInsets.symmetric(vertical: 22),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 4,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.person_add,
                              color: Colors.white,
                              size: 22,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Sign Up',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

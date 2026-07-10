// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'login.dart';
import 'package:techgrannyapp/pages/login.dart';
import '../localization/app_localization.dart';
import '../localization/language_provider.dart';
import '../services/tts_service.dart';
import 'package:techgrannyapp/pages/login.dart';
import 'package:techgrannyapp/pages/signup.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with TickerProviderStateMixin {
  int _currentStep = 0;
  bool _isSpeaking = false;

  /// New flag: when true, the running TTS sequence should stop ASAP.
  bool _shouldStop = false;

  late AnimationController loginGlowController;
  late AnimationController signupGlowController;
  late AnimationController voiceGlowController;

@override
void initState() {
  super.initState();

  _initAnimations();

  WidgetsBinding.instance.addPostFrameCallback((_) async {
    final provider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );

    await provider.loadLanguage();

    await TTSService.initialize();

    await TTSService.setLanguage(
      provider.language,
    );

    await _speakInstructionsSequence();
  });
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
  if (_isSpeaking) return;

  _shouldStop = false;

  setState(() {
    _isSpeaking = true;
    _currentStep = 3; // Voice button
  });

  try {
    // Voice button
    await TTSService.speak(
      AppLocalization.tts(
        "welcome",
        "welcomeMessage",
      ),
    );

    if (_shouldStop) return;

    await TTSService.speak(
      AppLocalization.tts(
        "welcome",
        "appIntroduction",
      ),
    );

    if (_shouldStop) return;

    // Login button
    if (mounted) {
      setState(() {
        _currentStep = 1;
      });
    }

    await TTSService.speak(
      AppLocalization.tts(
        "welcome",
        "loginInstruction",
      ),
    );

    if (_shouldStop) return;

    // Signup button
    if (mounted) {
      setState(() {
        _currentStep = 2;
      });
    }

    await TTSService.speak(
      AppLocalization.tts(
        "welcome",
        "signupInstruction",
      ),
    );

    if (_shouldStop) return;

    // Skip button
    if (mounted) {
      setState(() {
        _currentStep = 4;
      });
    }

    await TTSService.speak(
      AppLocalization.tts(
        "welcome",
        "skipInstruction",
      ),
    );
  } finally {
    if (mounted) {
      setState(() {
        _shouldStop = false;
        _isSpeaking = false;
        _currentStep = 0;
      });

      debugPrint("FINALLY EXECUTED");
      debugPrint("_isSpeaking = $_isSpeaking");
    }
  }
}

  Future<void> _skipSpeaking() async {
    // Request the running sequence to stop ASAP
    _shouldStop = true;

    try {
      // Ask the TTS engine to stop speaking immediately and await it.
      await TTSService.stop();
    } catch (e) {
      debugPrint("Error stopping TTS: $e");
    }

    // Clear UI speaking state
    if (mounted) {
      setState(() {
        _shouldStop = true;
        _isSpeaking = false;
        _currentStep = 0;
      });
    } else {
      _isSpeaking = false;
      _currentStep = 0;
    }
  }

  @override
  void dispose() {
    TTSService.stop();

    loginGlowController.dispose();
    signupGlowController.dispose();
    voiceGlowController.dispose();

    super.dispose();
  }

  ButtonStyle _loginButtonStyle() {
    return ButtonStyle(
      backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.disabled)) {
          return const Color(0xFFA8E6C8); // faded green (disabled)
        }
        return const Color(0xFF05C46B); // active green
      }),
      foregroundColor: MaterialStateProperty.all(Colors.white),
      elevation: MaterialStateProperty.resolveWith<double>((states) {
        if (states.contains(MaterialState.disabled)) return 0;
        return 6;
      }),
      padding: MaterialStateProperty.all(
        const EdgeInsets.symmetric(vertical: 22),
      ),
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  ButtonStyle _signupButtonStyle() {
    return ButtonStyle(
      backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.disabled)) {
          return const Color(0xFFA8D4FF); // faded blue (disabled)
        }
        return const Color(0xFF2FA4FF); // active blue
      }),
      foregroundColor: MaterialStateProperty.all(Colors.white),
      elevation: MaterialStateProperty.resolveWith<double>((states) {
        if (states.contains(MaterialState.disabled)) return 0;
        return 4;
      }),
      padding: MaterialStateProperty.all(
        const EdgeInsets.symmetric(vertical: 22),
      ),
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isSmall = width < 380;
    debugPrint("BUILD -> _isSpeaking = $_isSpeaking");
    return Scaffold(
      body: Stack(
        children: [
          // Main content
          Container(
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 20,
                ),
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
                                        color: Colors.redAccent.withOpacity(
                                          0.8,
                                        ),
                                        blurRadius: 20,
                                        spreadRadius: 4,
                                      ),
                                    ]
                                  : [],
                            ),
                            child: GestureDetector(
                              onTap: () async {
                                if (_isSpeaking) {
                                  await TTSService.stop();
                                }

                                if (mounted) {
                                  setState(() {
                                    _shouldStop = false;
                                    _currentStep = 0;
                                  });
                                }

                                await _speakInstructionsSequence();
                              },
                              child: Container(
                                width: 58,
                                height: 58,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF9B4DFF),
                                  shape: BoxShape.circle,
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    const Icon(
                                      Icons.volume_up,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                    if (_isSpeaking)
                                      Positioned(
                                        bottom: 8,
                                        child: Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                  ],
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
                            AppLocalization.ui(
                              "welcome",
                              "voiceSupport",
                            ),
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
                      AppLocalization.ui(
                        "welcome",
                        "title",
                      ),
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
                      AppLocalization.ui(
                        "welcome",
                        "subtitle",
                      ),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'OpenSans',
                        fontSize: 13,
                        color: Color(0xFF6A3BFF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 55),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Login Button
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: _isSpeaking ? 0.9 : 1.0,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: _currentStep == 1
                                  ? [
                                      BoxShadow(
                                        color: Colors.redAccent.withOpacity(
                                          0.8,
                                        ),
                                        blurRadius: 20,
                                        spreadRadius: 4,
                                      ),
                                    ]
                                  : [],
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                debugPrint("Login button pressed");
                                debugPrint("_isSpeaking = $_isSpeaking");

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LogInPage(),
                                  ),
                                );
                              },
                              style: _loginButtonStyle(),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.login,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    AppLocalization.ui(
                                      "welcome",
                                      "loginButton",
                                    ),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Signup Button
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: _isSpeaking ? 0.9 : 1.0,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: _currentStep == 2
                                  ? [
                                      BoxShadow(
                                        color: Colors.redAccent.withOpacity(
                                          0.8,
                                        ),
                                        blurRadius: 20,
                                        spreadRadius: 4,
                                      ),
                                    ]
                                  : [],
                            ),
                            child: ElevatedButton(
                              onPressed: _isSpeaking
                                  ? null
                                  : () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const SignUpPage(),
                                        ),
                                      );
                                    },
                              style: _signupButtonStyle(),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.person_add,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    AppLocalization.ui(
                                      "welcome",
                                      "signupButton",
                                    ),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
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

          // Overlay shown while speaking - DIRECT child of Stack (no AnimatedSwitcher)
          if (_isSpeaking)
            Positioned.fill(
              key: const ValueKey('speaking_overlay'),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _isSpeaking ? 1.0 : 0.0,
                curve: Curves.easeInOut,
                child: Stack(
                  children: [
                    // Dark overlay background
                    Container(color: Colors.black.withOpacity(0.45)),

                    // Skip button at bottom-right (highlighted when currentStep==4)
                    Positioned(
                      bottom: 30,
                      right: 20,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: _currentStep == 4
                              ? [
                                  BoxShadow(
                                    color: Colors.redAccent.withOpacity(0.8),
                                    blurRadius: 20,
                                    spreadRadius: 3,
                                  ),
                                ]
                              : [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.25),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                        ),
                        child: ElevatedButton(
                          onPressed: _skipSpeaking,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF9B4DFF),
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 18,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                          child: Text(
                            AppLocalization.ui(
                              "welcome",
                              "skipVoice",
                            ),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

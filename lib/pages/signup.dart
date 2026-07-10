// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:techgrannyapp/main_shell.dart';
import '../localization/app_localization.dart';
import '../services/tts_service.dart';
import '../localization/language_manager.dart';
import '../localization/language_provider.dart';
import 'package:provider/provider.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> with TickerProviderStateMixin {
  // ---------------------------
  // CORE STATE
  // ---------------------------
  int _step = 1; // 1 = phone, 2 = otp, 3 = name

  // 🔵 ADDED: highlight controller
  int _highlightTarget = 0; // 0=none, 1=field, 2=button, 3=voice

  late stt.SpeechToText _speech;

  bool _isSpeaking = false;
  bool _shouldStop = false;

  bool _speechAvailable = false;
  bool _isListening = false;
  String _listeningField = '';

  String _verificationId = "";
  String? _error;

  // ---------------------------
  // CONTROLLERS
  // ---------------------------
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _otpCtrl = TextEditingController();
  final TextEditingController _nameCtrl = TextEditingController();

@override
void initState() {
  super.initState();
  _initialize();
}

Future<void> _initialize() async {
  await TTSService.initialize();

  await _initSpeech();

  WidgetsBinding.instance.addPostFrameCallback((_) async {
    final provider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );

    await provider.loadLanguage();

    await TTSService.setLanguage(provider.language);

    _speakStepInstructions();
  });
}
  // ---------------------------
  // INIT TTS + SPEECH
  // ---------------------------


  Future<void> _initSpeech() async {
    _speech = stt.SpeechToText();
    _speechAvailable = await _speech.initialize();
  }

  // ---------------------------
  // TTS INSTRUCTIONS (UNCHANGED LOGIC, ONLY ADDED HIGHLIGHTS)
  // ---------------------------
  Future<void> _speakStepInstructions() async {
    if (_isSpeaking) return;

    _shouldStop = false;

    setState(() {
      _isSpeaking = true;
      _highlightTarget = 3;
    });

    bool abort() => _shouldStop;

    try {
      if (_step == 1) {
        setState(() => _highlightTarget = 1);

        await TTSService.speak(
          AppLocalization.tts(
            "authentication",
            "enterPhone",
          ),
        );

        if (abort()) return;

        setState(() => _highlightTarget = 2);

        await TTSService.speak(
          AppLocalization.tts(
            "authentication",
            "continueInstruction",
          ),
        );
      }

      if (_step == 2) {
        setState(() => _highlightTarget = 1);

        await TTSService.speak(
          AppLocalization.tts(
            "authentication",
            "enterOtp",
          ),
        );

        if (abort()) return;

        setState(() => _highlightTarget = 2);

        await TTSService.speak(
          AppLocalization.tts(
            "authentication",
            "verifyInstruction",
          ),
        );
      }

      if (_step == 3) {
        setState(() => _highlightTarget = 1);

        await TTSService.speak(
          AppLocalization.tts(
            "authentication",
            "enterName",
          ),
        );

        if (abort()) return;

        setState(() => _highlightTarget = 2);

        await TTSService.speak(
          AppLocalization.tts(
            "authentication",
            "continue",
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSpeaking = false;
          _shouldStop = false;
          _highlightTarget = 0;
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

  // ---------------------------
  // SPEECH TO TEXT (UNCHANGED)
  // ---------------------------
  Widget micIcon(String field) {
    final active = _isListening && _listeningField == field;

    return IconButton(
      icon: Icon(
        active ? Icons.mic : Icons.mic_none,
        color: active ? Colors.green : Colors.red,
      ),
      onPressed: _isSpeaking ? null : () => _startListening(field),
    );
  }

  Future<void> _stopListening() async {
    try {
      await _speech.stop();
    } catch (_) {}

    if (mounted) {
      setState(() {
        _isListening = false;
        _listeningField = '';
      });
    }
  }

  Future<void> _startListening(String field) async {
    if (!_speechAvailable) return;

    setState(() {
      _isListening = true;
      _listeningField = field;
    });

    await _speech.listen(
      localeId: "en_IN",
      listenMode: stt.ListenMode.dictation,
      onResult: (result) {
        final text = result.recognizedWords;

        if (field == "phone") {
          _phoneCtrl.text = text.replaceAll(RegExp(r'[^0-9]'), '');
        }
        if (field == "otp") {
          _otpCtrl.text = text.replaceAll(RegExp(r'[^0-9]'), '');
        }
        if (field == "name") {
          _nameCtrl.text = text;
        }

        // ✅ STOP listening when final result is received
        if (result.finalResult) {
          _stopListening();
        }
      },
    );
  }

  // ---------------------------
  // HIGHLIGHT WRAPPER (ADDED)
  // ---------------------------
  Widget _highlight({required bool active, required Widget child}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        boxShadow: active
            ? [
                BoxShadow(
                  color: Colors.redAccent.withOpacity(0.8),
                  blurRadius: 18,
                  spreadRadius: 4,
                ),
              ]
            : [],
      ),
      child: child,
    );
  }

  // ---------------------------
  // MAIN UI
  // ---------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: Stack(
        children: [
          _buildMainContent(),

          // 🔵 ADDED: Voice icon (top-right)
          Positioned(
            top: 50,
            right: 20,
            child: _highlight(
              active: _highlightTarget == 3,
              child: IconButton(
                icon: const Icon(
                  Icons.volume_up,
                  size: 50,
                  color: Color(0xFF9B4DFF),
                ),
                onPressed: () async {
                  await TTSService.stop();
                  _speakStepInstructions();
                },
              ),
            ),
          ),

          if (_isSpeaking) _buildOverlay(),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 80),

              if (_step == 1)
                _highlight(
                  active: _highlightTarget == 1,
                  child: _buildTextField(
                    label: AppLocalization.ui(
                      "authentication",
                      "phoneNumber",
                    ),
                    controller: _phoneCtrl,
                    field: "phone",
                    type: TextInputType.number,
                  ),
                ),

              if (_step == 2)
                _highlight(
                  active: _highlightTarget == 1,
                  child: _buildTextField(
                    label: AppLocalization.ui(
                      "authentication",
                      "otp",
                    ),
                    controller: _otpCtrl,
                    field: "otp",
                    type: TextInputType.number,
                  ),
                ),

              if (_step == 3)
                _highlight(
                  active: _highlightTarget == 1,
                  child: _buildTextField(
                    label: AppLocalization.ui(
                      "authentication",
                      "name",
                    ),
                    controller: _nameCtrl,
                    field: "name",
                  ),
                ),

              const SizedBox(height: 24),

              _highlight(
                active: _highlightTarget == 2,
                child: ElevatedButton(
                  onPressed: _step == 1
                      ? _sendOtp
                      : _step == 2
                      ? _verifyOtp
                      : _submitName,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2FA4FF), // 🔵 BLUE BUTTON
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    _step == 2
                        ? AppLocalization.ui(
                            "authentication",
                            "verify",
                          )
                        : AppLocalization.ui(
                            "authentication",
                            "continue",
                          ),
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),

              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String field,
    TextInputType type = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        suffixIcon: micIcon(field),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  // ---------------------------
  // OVERLAY
  // ---------------------------
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
                backgroundColor: Color(0xFF9B4DFF),
              ),
              child: Text(
                       AppLocalization.ui(
                         "common",
                         "skip",
                       ),
                       style: const TextStyle(
                         color: Colors.white,
                       ),
                     ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------
  // FIREBASE LOGIC
  // ---------------------------
  Future<void> _sendOtp() async {
    if (_phoneCtrl.text.length != 10) {
      await TTSService.speak(
        AppLocalization.tts(
          "authentication",
          "invalidPhoneSpeak",
        ),
      );
      return;
    }

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: "+91${_phoneCtrl.text}",
      verificationCompleted: (_) {},
      verificationFailed: (e) {
        setState(() => _error = e.message);
      },
      codeSent: (id, _) {
        _verificationId = id;
        setState(() => _step = 2);
        _speakStepInstructions();
      },
      codeAutoRetrievalTimeout: (id) {
        _verificationId = id;
      },
    );
  }

  Future<void> _verifyOtp() async {
    try {
      final cred = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _otpCtrl.text,
      );
  
      await FirebaseAuth.instance.signInWithCredential(cred);
  
      setState(() => _step = 3);
  
      _speakStepInstructions();
    } catch (_) {
      await TTSService.speak(
        AppLocalization.tts(
          "authentication",
          "invalidOtp",
        ),
      );
    }
  }

  Future<void> _submitName() async {
    final user = FirebaseAuth.instance.currentUser!;
    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .set({
      "name": _nameCtrl.text,
      "phone": user.phoneNumber,
      "languagePreference": LanguageManager.currentLanguage,
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainShell()),
    );
  }
  @override
  void dispose() {
    _phoneCtrl.dispose();
    _otpCtrl.dispose();
    _nameCtrl.dispose();

    _speech.stop();

    super.dispose();
  }
}

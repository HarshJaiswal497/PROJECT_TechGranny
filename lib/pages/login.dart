// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:techgrannyapp/main_shell.dart';

class LogInPage extends StatefulWidget {
  const LogInPage({super.key});

  @override
  State<LogInPage> createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  // ---------------- CORE ----------------
  int _step = 1; // 1 = phone, 2 = otp
  int _highlightTarget = 0; // 1=field, 2=button, 3=voice

  final FlutterTts _tts = FlutterTts();
  late stt.SpeechToText _speech;

  bool _isSpeaking = false;
  bool _shouldStop = false;

  bool _speechAvailable = false;
  bool _isListening = false;
  String _listeningField = '';

  String _verificationId = '';
  String? _error;

  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _otpCtrl = TextEditingController();

  // ---------------- INIT ----------------
  @override
  void initState() {
    super.initState();
    _initTts();
    _initSpeech();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speakLoginInstructions();
    });
  }

  Future<void> _initTts() async {
    await _tts.awaitSpeakCompletion(true);
    await _tts.setLanguage("hi-IN");
    await _tts.setSpeechRate(0.5);
  }

  Future<void> _initSpeech() async {
    _speech = stt.SpeechToText();
    _speechAvailable = await _speech.initialize();
  }

  // ---------------- TTS ----------------
  Future<void> _speakLoginInstructions() async {
    if (_isSpeaking) return;

    _shouldStop = false;
    setState(() {
      _isSpeaking = true;
      _highlightTarget = 3; // voice icon
    });

    bool abort() => _shouldStop;

    try {
      if (_step == 1) {
        setState(() => _highlightTarget = 1);
        await _tts.speak("लॉगिन करने के लिए अपना मोबाइल नंबर दर्ज करें।");
        if (abort()) return;

        setState(() => _highlightTarget = 2);
        await _tts.speak("फिर नीचे कंटिन्यू बटन दबाएँ।");
      }

      if (_step == 2) {
        setState(() => _highlightTarget = 1);
        await _tts.speak("अब ओटीपी दर्ज करें।");
        if (abort()) return;

        setState(() => _highlightTarget = 2);
        await _tts.speak("फिर वेरिफ़ाई बटन दबाएँ।");
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _isSpeaking = false;
        _highlightTarget = 0;
      });
    }
  }

  Future<void> _stopSpeaking() async {
    _shouldStop = true;
    await _tts.stop();
    setState(() {
      _isSpeaking = false;
      _highlightTarget = 0;
    });
  }

  // ---------------- SPEECH ----------------
  Widget micIcon(String field) {
    final active = _isListening && _listeningField == field;

    return IconButton(
      icon: Icon(
        active ? Icons.mic : Icons.mic_none,
        color: active ? Colors.green : Colors.red,
      ),
      onPressed: _isSpeaking
          ? null
          : () {
              if (active) {
                _stopListening();
              } else {
                _startListening(field);
              }
            },
    );
  }

  Future<void> _startListening(String field) async {
    if (!_speechAvailable) return;

    setState(() {
      _isListening = true;
      _listeningField = field;
    });

    await _speech.listen(
      localeId: 'hi_IN',
      onResult: (result) {
        if (field == 'phone') {
          _phoneCtrl.text =
              result.recognizedWords.replaceAll(RegExp(r'[^0-9]'), '');
        }
        if (field == 'otp') {
          _otpCtrl.text =
              result.recognizedWords.replaceAll(RegExp(r'[^0-9]'), '');
        }

        if (result.finalResult) {
          _stopListening();
        }
      },
    );
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    setState(() {
      _isListening = false;
      _listeningField = '';
    });
  }

  // ---------------- FIREBASE ----------------
  Future<void> _sendOtp() async {
    if (_phoneCtrl.text.length != 10) {
      await _tts.speak("कृपया 10 अंकों का मोबाइल नंबर दर्ज करें।");
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
        _speakLoginInstructions();
      },
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  Future<void> _verifyOtp() async {
    try {
      final cred = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _otpCtrl.text,
      );

      await FirebaseAuth.instance.signInWithCredential(cred);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    } catch (_) {
      await _tts.speak("ओटीपी गलत है।");
    }
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildMainContent(),

          // 🔊 Voice replay icon (top-right)
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
                  await _tts.stop();
                  _speakLoginInstructions();
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
    return Container(
      decoration: const BoxDecoration(
        gradient: SweepGradient(
          center: Alignment.center,
          colors: [
            Color(0xFFEBD4FF),
            Color(0xFFFFE4F3),
            Color(0xFFCCE5FF),
            Color(0xFFEBD4FF),
          ],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 100),

                if (_step == 1)
                  _highlight(
                    active: _highlightTarget == 1,
                    child: _buildField(
                      "Mobile Number",
                      _phoneCtrl,
                      'phone',
                    ),
                  ),

                if (_step == 2)
                  _highlight(
                    active: _highlightTarget == 1,
                    child: _buildField("OTP", _otpCtrl, 'otp'),
                  ),

                const SizedBox(height: 24),

                _highlight(
                  active: _highlightTarget == 2,
                  child: ElevatedButton(
                    onPressed: _step == 1 ? _sendOtp : _verifyOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF05C46B),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      _step == 1 ? "Continue" : "Verify",
                      style:
                          const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),

                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController ctrl,
    String field,
  ) {
    return TextField(
      controller: ctrl,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        suffixIcon: micIcon(field),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

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
              ),
              child:
                  const Text("Skip", style: TextStyle(color: Colors.white)),
            ),
          ),
        ),
      ),
    );
  }
}

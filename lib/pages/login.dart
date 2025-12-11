// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:techgrannyapp/pages/home.dart';

class LogInPage extends StatefulWidget {
  const LogInPage({super.key});

  @override
  State<LogInPage> createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> with TickerProviderStateMixin {
  late FlutterTts flutterTts;
  late stt.SpeechToText _speech;

  int _currentStep = 0;

  bool _isSpeaking = false;
  bool _shouldStop = false;

  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _firstPasswordFocus = true;
  String? _loginError;

  // Speech state
  bool _speechAvailable = false;
  bool _isListening = false;
  String _lastWords = '';
  // where we're listening to: 'mobile' or 'password' or ''
  String _listeningField = '';

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
    flutterTts = FlutterTts();
    await flutterTts.awaitSpeakCompletion(true);
    await flutterTts.setLanguage("hi-IN");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
  }

  Future<void> _initSpeech() async {
    _speech = stt.SpeechToText();
    try {
      _speechAvailable = await _speech.initialize(
        onStatus: (status) {
          // If speech stops unexpectedly, sync UI
          if (status == 'done' || status == 'notListening') {
            if (mounted) {
              setState(() {
                _isListening = false;
                _listeningField = '';
              });
            }
          }
        },
        onError: (error) {
          if (mounted) {
            setState(() {
              _isListening = false;
              _listeningField = '';
            });
          }
          debugPrint('Speech error: $error');
        },
      );
    } catch (e) {
      debugPrint('Speech init error: $e');
      _speechAvailable = false;
    }
  }

  Future<void> _speakLoginInstructions() async {
    // guard: don't start another sequence if one is running
    if (_isSpeaking) return;

    // If currently listening with mic, stop it first
    if (_isListening) {
      _stopListening();
    }

    _shouldStop = false;
    setState(() {
      _isSpeaking = true;
    });

    try {
      bool shouldAbort() => _shouldStop;

      // initial highlight - voice icon
      setState(() => _currentStep = 4);
      await flutterTts.awaitSpeakCompletion(true);
      if (shouldAbort()) return;

      await flutterTts.speak(
        "नमस्ते! आप लॉगिन पेज पर हैं। मैं आपकी मदद करूँगी।",
      );
      await Future.delayed(const Duration(milliseconds: 800));
      if (shouldAbort()) return;

      // Mobile field
      setState(() => _currentStep = 1);
      await flutterTts.speak(
        "पहला फील्ड: कृपया अपना मोबाइल नंबर सावधानी से दर्ज करें।",
      );
      await Future.delayed(const Duration(milliseconds: 800));
      if (shouldAbort()) return;

      // Password field
      setState(() => _currentStep = 2);
      await flutterTts.speak("दूसरा फील्ड: अपना पासवर्ड ध्यान से टाइप करें।");
      await Future.delayed(const Duration(milliseconds: 800));
      if (shouldAbort()) return;

      // Login button
      setState(() => _currentStep = 3);
      await flutterTts.speak("अब लॉगिन करने के लिए बटन दबाएँ।");
      await Future.delayed(const Duration(milliseconds: 800));
      if (shouldAbort()) return;

      // voice icon reminder
      setState(() => _currentStep = 4);
      await flutterTts.speak(
        "यदि आप निर्देश दोबारा सुनना चाहती हैं, तो ऊपर वॉइस आइकॉन को टैप करें। मैं आपकी मदद हमेशा करूँगी।",
      );
      await Future.delayed(const Duration(milliseconds: 600));
      if (shouldAbort()) return;

      // done
      setState(() => _currentStep = 0);
    } catch (e) {
      debugPrint("TTS Error: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isSpeaking = false;
          _shouldStop = false;
          _currentStep = 0;
        });
      } else {
        _isSpeaking = false;
        _shouldStop = false;
        _currentStep = 0;
      }
    }
  }

  Future<void> _skipSpeaking() async {
    // request sequence to stop
    _shouldStop = true;

    try {
      await flutterTts.stop();
    } catch (e) {
      debugPrint("Error stopping TTS: $e");
    }

    // If we are listening, stop that too
    if (_isListening) {
      _stopListening();
    }

    if (mounted) {
      setState(() {
        _isSpeaking = false;
        _currentStep = 0;
      });
    } else {
      _isSpeaking = false;
      _currentStep = 0;
    }
  }

  Future<void> _login() async {
    // stop any speaking/listening to avoid overlap
    _shouldStop = true;
    if (_isListening) _stopListening();
    try {
      await flutterTts.stop();
    } catch (_) {}

    final mobile = _mobileController.text.trim();
    final password = _passwordController.text.trim();

    if (mobile.isEmpty || password.isEmpty) {
      await flutterTts.speak("कृपया सभी फील्ड भरें।");
      setState(() => _loginError = "सभी फील्ड भरें।");
      return;
    }
    if (mobile.length != 10 || !RegExp(r'^[0-9]+$').hasMatch(mobile)) {
      await flutterTts.speak("मोबाइल नंबर 10 अंकों का होना चाहिए।");
      setState(() => _loginError = "मोबाइल नंबर 10 अंकों का होना चाहिए।");
      return;
    }

    // Simulated success
    await flutterTts.speak("लॉगिन सफल! आपका स्वागत है।");
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
      (Route<dynamic> route) => false,
    );
  }

  // Start listening for a specific field: 'mobile' or 'password'
  Future<void> _startListening(String field) async {
    if (_isSpeaking) {
      // prefer TTS over listening — inform user
      await flutterTts.speak("कृपया पहले निर्देश सुनने के लिए प्रतीक्षा करें।");
      return;
    }
    if (!_speechAvailable) {
      await flutterTts.speak("आपके डिवाइस पर आवाज़ इनपुट उपलब्ध नहीं है।");
      return;
    }

    // If already listening for the same field, stop
    if (_isListening && _listeningField == field) {
      _stopListening();
      return;
    }

    // If listening for another field, stop it first
    if (_isListening) {
      _stopListening();
    }

    // Start listening
    setState(() {
      _isListening = true;
      _listeningField = field;
    });

    try {
      await _speech.listen(
        onResult: (result) async {
          // result.recognizedWords contains the current text
          if (result.finalResult) {
            _lastWords = result.recognizedWords;
            if (field == 'mobile') {
              // filter digits only
              final digits = _lastWords.replaceAll(RegExp(r'[^0-9]'), '');
              final trimmed = digits.length > 10
                  ? digits.substring(0, 10)
                  : digits;
              _mobileController.text = trimmed;
              // move cursor to end
              _mobileController.selection = TextSelection.fromPosition(
                TextPosition(offset: _mobileController.text.length),
              );
            } else if (field == 'password') {
              // For password, clean whitespace and show confirm dialog
              String cleaned = _lastWords.trim().replaceAll(
                RegExp(r'\s+'),
                ' ',
              );
              _passwordController.text = cleaned;
              _passwordController.selection = TextSelection.fromPosition(
                TextPosition(offset: _passwordController.text.length),
              );

              // Show confirmation dialog so user can accept or retry
              if (mounted) {
                Future.microtask(() => _showPasswordConfirmDialog(cleaned));
              }
            }
          } else {
            // intermediate results: show as temporary text (optional)
            final partial = result.recognizedWords;
            if (field == 'mobile') {
              final digits = partial.replaceAll(RegExp(r'[^0-9]'), '');
              final trimmed = digits.length > 10
                  ? digits.substring(0, 10)
                  : digits;
              // set but don't overwrite final unless finalResult
              _mobileController.text = trimmed;
              _mobileController.selection = TextSelection.fromPosition(
                TextPosition(offset: _mobileController.text.length),
              );
            } else if (field == 'password') {
              String cleanedPartial = partial.trim().replaceAll(
                RegExp(r'\s+'),
                ' ',
              );
              _passwordController.text = cleanedPartial;
              _passwordController.selection = TextSelection.fromPosition(
                TextPosition(offset: _passwordController.text.length),
              );
            }
          }
        },
        listenMode: stt.ListenMode.confirmation,
        localeId: 'en_IN',
        onSoundLevelChange: null,
      );
    } catch (e) {
      debugPrint('Error starting listen: $e');
      setState(() {
        _isListening = false;
        _listeningField = '';
      });
    }
  }

  Future<void> _stopListening() async {
    try {
      await _speech.stop();
    } catch (e) {
      debugPrint('Error stopping listen: $e');
    }
    if (mounted) {
      setState(() {
        _isListening = false;
        _listeningField = '';
      });
    } else {
      _isListening = false;
      _listeningField = '';
    }
  }

  @override
  void dispose() {
    try {
      flutterTts.stop();
    } catch (_) {}
    if (_isListening) {
      _stopListening();
    }
    _mobileController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Button styles that show faded color when disabled
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
        const EdgeInsets.symmetric(vertical: 20, horizontal: 120),
      ),
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  ButtonStyle _backButtonStyle() {
    return ButtonStyle(
      foregroundColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.disabled)) {
          return const Color(0xFF9EC9FF); // faded blue text when disabled
        }
        return const Color(0xFF2FA4FF);
      }),
      padding: MaterialStateProperty.all(
        const EdgeInsets.symmetric(horizontal: 6),
      ),
    );
  }

  // Mic icon builder - UPDATED: red when idle, green when listening, greyed when TTS speaks
  Widget micIcon(String field) {
    final bool active = _isListening && _listeningField == field;

    // color rules:
    // - if TTS speaking, greyed out
    // - otherwise green when active, red when idle
    final Color iconColor = _isSpeaking
        ? Colors.grey
        : (active ? Colors.green : Colors.red);

    return IconButton(
      icon: Stack(
        alignment: Alignment.center,
        children: [
          Icon(active ? Icons.mic : Icons.mic_none, color: iconColor, size: 28),
          // show a small green glowing dot when actively listening
          if (active)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.7),
                      blurRadius: 6,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      onPressed: _isSpeaking
          ? null
          : () {
              // toggle listening
              if (_isListening && _listeningField == field) {
                _stopListening();
              } else {
                _startListening(field);
              }
            },
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isSmall = width < 380;

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
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Top image with voice icon
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: isSmall ? 160 : 200,
                          height: isSmall ? 160 : 200,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
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
                              boxShadow: _currentStep == 4
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
                                  try {
                                    await flutterTts.stop();
                                  } catch (_) {}
                                  await Future.delayed(
                                    const Duration(milliseconds: 150),
                                  );
                                }
                                await _speakLoginInstructions();
                              },
                              child: Container(
                                width: 50,
                                height: 50,
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
                    const SizedBox(height: 20),

                    // Title
                    Text(
                      'Log In to Your Account',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Pacifico',
                        fontSize: isSmall ? 28 : 32,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Form fields
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildTextField(
                          'Mobile Number',
                          1,
                          keyboardType: TextInputType.phone,
                          controller: _mobileController,
                          suffixIcon: micIcon('mobile'),
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          'Password',
                          2,
                          obscureText: _obscurePassword,
                          controller: _passwordController,
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility
                                      : Icons.visibility_outlined,
                                ),
                                onPressed: () {
                                  setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  );
                                },
                              ),
                              micIcon('password'),
                            ],
                          ),
                          onTap: () {
                            if (_firstPasswordFocus) {
                              flutterTts.speak(
                                "पासवर्ड देखने के लिए आंख के आइकॉन को टैप करें।",
                              );
                              _firstPasswordFocus = false;
                            }
                          },
                        ),
                        if (_loginError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              _loginError!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 13,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Login Button - disabled while speaking
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
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
                      child: ElevatedButton(
                        onPressed: _isSpeaking ? null : _login,
                        style: _loginButtonStyle(),
                        child: const Text(
                          'Log In',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Back
                    TextButton(
                      onPressed: _isSpeaking
                          ? null
                          : () {
                              Navigator.pop(context);
                            },
                      style: _backButtonStyle(),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.arrow_back,
                            color: Color(0xFF2FA4FF),
                            size: 20,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Back',
                            style: TextStyle(
                              color: Color(0xFF2FA4FF),
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ------------- Overlay (DIRECT child of Stack) -------------
          // IMPORTANT: keep this as a direct child (no AnimatedSwitcher wrapping Positioned)
          if (_isSpeaking)
            Positioned.fill(
              key: const ValueKey('login_speaking_overlay'),
              child: AnimatedOpacity(
                opacity: _isSpeaking ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: Stack(
                  children: [
                    // Dark overlay background
                    Container(color: Colors.black.withOpacity(0.45)),

                    // Skip button at bottom-right
                    Positioned(
                      bottom: 30,
                      right: 20,
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
                        child: const Text(
                          'Skip',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
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

  Widget _buildTextField(
    String label,
    int step, {
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    TextEditingController? controller,
    Widget? suffixIcon,
    Function()? onTap,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: _currentStep == step
            ? [
                BoxShadow(
                  color: Colors.redAccent.withOpacity(0.8),
                  blurRadius: 20,
                  spreadRadius: 4,
                ),
              ]
            : [],
      ),
      child: TextFormField(
        obscureText: obscureText,
        keyboardType: keyboardType,
        controller: controller,
        style: const TextStyle(fontFamily: 'OpenSans'),
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 15,
            color: Colors.black87,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }

  // Helper: show confirmation after password is filled via voice
  Future<void> _showPasswordConfirmDialog(String cleanedPassword) async {
    // Stop any lingering listening just in case
    if (_isListening) {
      await _stopListening();
    }

    // Show a simple Hindi dialog
    if (!mounted) return;
    final choice = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('पासवर्ड पुष्टि'),
        content: Text(
          'क्या यह पासवर्ड सही है?\n\n"$cleanedPassword"\n\n'
          'यदि नहीं तो "दोबारा बोलें" चुनें।',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop('retry'),
            child: const Text('दोबारा बोलें'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop('ok'),
            child: const Text('ठीक है'),
          ),
        ],
      ),
    );

    if (choice == 'retry') {
      // Clear current password text (so user can re-speak)
      if (mounted) {
        setState(() {
          _passwordController.text = '';
          _passwordController.selection = const TextSelection.collapsed(
            offset: 0,
          );
        });
      }
      // Restart listening for password
      await Future.delayed(const Duration(milliseconds: 200));
      if (mounted) _startListening('password');
    } else {
      // 'ok' or dismissed -> accept as-is; optionally confirm by voice
      try {
        await flutterTts.speak("पासवर्ड स्वीकार कर लिया गया।");
      } catch (_) {}
    }
  }
}

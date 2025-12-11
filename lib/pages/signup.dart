// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:techgrannyapp/pages/home.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> with TickerProviderStateMixin {
  late FlutterTts flutterTts;
  late stt.SpeechToText _speech;

  int _currentStep = 0;

  // Controllers for fields
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  String? _passwordError;

  // Speech state
  bool _speechAvailable = false;
  bool _isListening = false;
  String _lastWords = '';
  // where we're listening to: 'name'/'mobile'/'password'/'confirm' or ''
  String _listeningField = '';

  // TTS control
  bool _isSpeaking = false;
  bool _shouldStop = false;

  bool _firstPasswordFocus = true;

  @override
  void initState() {
    super.initState();
    _initTts();
    _initSpeech();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speakSignupInstructions();
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

  Future<void> _speakSignupInstructions() async {
    // guard re-entrancy
    if (_isSpeaking) return;

    // stop listening if running
    if (_isListening) {
      await _stopListening();
    }

    _shouldStop = false;
    setState(() {
      _isSpeaking = true;
    });

    try {
      bool shouldAbort() => _shouldStop;

      setState(() => _currentStep = 6);
      await flutterTts.awaitSpeakCompletion(true);
      if (shouldAbort()) return;
      await flutterTts.speak(
        "नमस्ते! यह साइन अप पेज है। चलिए मिलकर आपका अकाउंट बनाते हैं। नीचे दिए गए फील्ड्स में अपने विवरण ध्यान से भरें।",
      );
      await Future.delayed(const Duration(milliseconds: 800));
      if (shouldAbort()) return;

      setState(() => _currentStep = 1);
      await flutterTts.speak(
        "पहला फील्ड: कृपया अपना पूरा नाम दर्ज करें, ताकि हम आपको सही तरीके से जान सकें।",
      );
      await Future.delayed(const Duration(milliseconds: 800));
      if (shouldAbort()) return;

      setState(() => _currentStep = 2);
      await flutterTts.speak(
        "दूसरा फील्ड: अपना मोबाइल नंबर डालें, ताकि हम आपके साथ आसानी से संपर्क कर सकें।",
      );
      await Future.delayed(const Duration(milliseconds: 800));
      if (shouldAbort()) return;

      setState(() => _currentStep = 3);
      await flutterTts.speak(
        "अब अपना पासवर्ड चुनें। यह सुरक्षित और याद रखने में आसान होना चाहिए। कम से कम 6 अक्षरों का होना चाहिए।",
      );
      await Future.delayed(const Duration(milliseconds: 800));
      if (shouldAbort()) return;

      setState(() => _currentStep = 4);
      await flutterTts.speak(
        "पासवर्ड की पुष्टि करें, ताकि हम सुनिश्चित कर सकें कि आपने सही पासवर्ड डाला है।",
      );
      await Future.delayed(const Duration(milliseconds: 800));
      if (shouldAbort()) return;

      setState(() => _currentStep = 5);
      await flutterTts.speak(
        "सभी जानकारी भरने के बाद, कृपया साइन अप बटन दबाएँ और आपका अकाउंट तैयार हो जाएगा।",
      );
      await Future.delayed(const Duration(milliseconds: 800));
      if (shouldAbort()) return;

      setState(() => _currentStep = 6);
      await flutterTts.speak(
        "यदि आप निर्देश फिर से सुनना चाहें, तो ऊपर वॉइस आइकॉन को टैप करें। मैं हमेशा आपकी मदद के लिए यहाँ हूँ।",
      );

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
    _shouldStop = true;
    try {
      await flutterTts.stop();
    } catch (e) {
      debugPrint('Error stopping TTS: $e');
    }
    if (_isListening) {
      await _stopListening();
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

  void _validatePassword(String value, {bool isConfirm = false}) {
    setState(() {
      if (isConfirm) {
        _confirmController.text = value;
        if (_passwordController.text != _confirmController.text) {
          _passwordError = "पासवर्ड मेल नहीं खा रहा।";
        } else {
          _passwordError = null;
        }
      } else {
        _passwordController.text = value;
        if (_passwordController.text.length < 6) {
          _passwordError = "पासवर्ड कम से कम 6 अक्षरों का होना चाहिए।";
        } else if (_confirmController.text.isNotEmpty &&
            _confirmController.text != _passwordController.text) {
          _passwordError = "पासवर्ड मेल नहीं खा रहा।";
        } else {
          _passwordError = null;
        }
      }
    });

    if (_passwordError != null) {
      try {
        flutterTts.speak(_passwordError!);
      } catch (_) {}
    }
  }

  bool _validateFields() {
    final fullName = _fullNameController.text.trim();
    final mobile = _mobileController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();

    if (fullName.isEmpty ||
        mobile.isEmpty ||
        password.isEmpty ||
        confirm.isEmpty) {
      flutterTts.speak("कृपया सभी फील्ड्स भरें।");
      return false;
    }
    if (mobile.length != 10 || !RegExp(r'^[0-9]+$').hasMatch(mobile)) {
      flutterTts.speak("कृपया 10 अंकों का सही मोबाइल नंबर डालें।");
      return false;
    }
    if (_passwordError != null) {
      flutterTts.speak("कृपया पासवर्ड की शर्तें पूरी करें।");
      return false;
    }
    return true;
  }

  // Start listening for a specific field: 'name','mobile','password','confirm'
  Future<void> _startListening(String field) async {
    if (_isSpeaking) {
      await flutterTts.speak("कृपया पहले निर्देश सुनने के लिए प्रतीक्षा करें।");
      return;
    }
    if (!_speechAvailable) {
      await flutterTts.speak("आपके डिवाइस पर आवाज़ इनपुट उपलब्ध नहीं है।");
      return;
    }

    // If already listening the same field, stop
    if (_isListening && _listeningField == field) {
      _stopListening();
      return;
    }

    // If listening for another field, stop it first
    if (_isListening) {
      _stopListening();
    }

    setState(() {
      _isListening = true;
      _listeningField = field;
    });

    try {
      await _speech.listen(
        onResult: (result) async {
          if (result.finalResult) {
            _lastWords = result.recognizedWords;
            if (field == 'name') {
              _fullNameController.text = _lastWords.trim();
              _fullNameController.selection = TextSelection.fromPosition(
                TextPosition(offset: _fullNameController.text.length),
              );
            } else if (field == 'mobile') {
              final digits = _lastWords.replaceAll(RegExp(r'[^0-9]'), '');
              final trimmed = digits.length > 10
                  ? digits.substring(0, 10)
                  : digits;
              _mobileController.text = trimmed;
              _mobileController.selection = TextSelection.fromPosition(
                TextPosition(offset: _mobileController.text.length),
              );
            } else if (field == 'password') {
              String cleaned = _lastWords.trim().replaceAll(
                RegExp(r'\s+'),
                ' ',
              );
              _passwordController.text = cleaned;
              _passwordController.selection = TextSelection.fromPosition(
                TextPosition(offset: _passwordController.text.length),
              );
              if (mounted) {
                Future.microtask(
                  () =>
                      _showPasswordConfirmDialog(cleaned, forField: 'password'),
                );
              }
            } else if (field == 'confirm') {
              String cleaned = _lastWords.trim().replaceAll(
                RegExp(r'\s+'),
                ' ',
              );
              _confirmController.text = cleaned;
              _confirmController.selection = TextSelection.fromPosition(
                TextPosition(offset: _confirmController.text.length),
              );
              // validate confirm match
              _validatePassword(cleaned, isConfirm: true);
            }
          } else {
            // intermediate result: show temporary
            final partial = result.recognizedWords;
            if (field == 'name') {
              _fullNameController.text = partial.trim();
              _fullNameController.selection = TextSelection.fromPosition(
                TextPosition(offset: _fullNameController.text.length),
              );
            } else if (field == 'mobile') {
              final digits = partial.replaceAll(RegExp(r'[^0-9]'), '');
              final trimmed = digits.length > 10
                  ? digits.substring(0, 10)
                  : digits;
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
            } else if (field == 'confirm') {
              String cleanedPartial = partial.trim().replaceAll(
                RegExp(r'\s+'),
                ' ',
              );
              _confirmController.text = cleanedPartial;
              _confirmController.selection = TextSelection.fromPosition(
                TextPosition(offset: _confirmController.text.length),
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

  Future<void> _showPasswordConfirmDialog(
    String cleanedPassword, {
    required String forField,
  }) async {
    // Stop listening if still active
    if (_isListening) await _stopListening();

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
      if (forField == 'password') {
        setState(() {
          _passwordController.text = '';
          _passwordController.selection = const TextSelection.collapsed(
            offset: 0,
          );
        });
        await Future.delayed(const Duration(milliseconds: 200));
        if (mounted) _startListening('password');
      }
    } else {
      try {
        await flutterTts.speak("पासवर्ड स्वीकार कर लिया गया।");
      } catch (_) {}
    }
  }

  // Mic icon builder - red idle, green while listening, grey while TTS speaks
  Widget micIcon(String field) {
    final bool active = _isListening && _listeningField == field;
    final Color iconColor = _isSpeaking
        ? Colors.grey
        : (active ? Colors.green : Colors.red);

    return IconButton(
      icon: Stack(
        alignment: Alignment.center,
        children: [
          Icon(active ? Icons.mic : Icons.mic_none, color: iconColor, size: 28),
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
              if (_isListening && _listeningField == field) {
                _stopListening();
              } else {
                _startListening(field);
              }
            },
    );
  }

  @override
  void dispose() {
    try {
      flutterTts.stop();
    } catch (_) {}
    if (_isListening) _stopListening();
    _fullNameController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
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
                              boxShadow: _currentStep == 6
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
                                await _speakSignupInstructions();
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
                      'Create Your Account',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Pacifico',
                        fontSize: isSmall ? 28 : 32,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Fill in the details below to get started.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'OpenSans',
                        fontSize: 15,
                        color: Colors.black87.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Form fields
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildTextField(
                          'Full Name',
                          1,
                          controller: _fullNameController,
                          onChanged: (val) {},
                          suffixIcon: micIcon('name'),
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          'Mobile Number',
                          2,
                          keyboardType: TextInputType.phone,
                          controller: _mobileController,
                          onChanged: (val) {},
                          suffixIcon: micIcon('mobile'),
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          'Password',
                          3,
                          obscureText: _obscurePassword,
                          controller: _passwordController,
                          onChanged: (val) => _validatePassword(val),
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
                              try {
                                flutterTts.speak(
                                  "पासवर्ड देखने के लिए आंख के आइकॉन को टैप करें।",
                                );
                              } catch (_) {}
                              _firstPasswordFocus = false;
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          'Confirm Password',
                          4,
                          obscureText: _obscureConfirm,
                          controller: _confirmController,
                          onChanged: (val) =>
                              _validatePassword(val, isConfirm: true),
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  _obscureConfirm
                                      ? Icons.visibility
                                      : Icons.visibility_outlined,
                                ),
                                onPressed: () {
                                  setState(
                                    () => _obscureConfirm = !_obscureConfirm,
                                  );
                                },
                              ),
                              micIcon('confirm'),
                            ],
                          ),
                        ),
                        if (_passwordError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              _passwordError!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 13,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Sign Up Button
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: _currentStep == 5
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
                          if (_validateFields()) {
                            try {
                              flutterTts.speak(
                                "साइन अप सफल रहा! आपका अकाउंट बन गया है।",
                              );
                            } catch (_) {}
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HomePage(),
                              ),
                              (Route<dynamic> route) => false,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2FA4FF),
                          padding: const EdgeInsets.symmetric(
                            vertical: 20,
                            horizontal: 120,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 6,
                        ),
                        child: const Text(
                          'Sign Up',
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
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.arrow_back,
                            color: Color(0xFF05C46B),
                            size: 20,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Back',
                            style: TextStyle(
                              color: Color(0xFF05C46B),
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

          // Speaking overlay (direct child of Stack)
          if (_isSpeaking)
            Positioned.fill(
              key: const ValueKey('signup_speaking_overlay'),
              child: AnimatedOpacity(
                opacity: _isSpeaking ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: Stack(
                  children: [
                    Container(color: Colors.black.withOpacity(0.45)),
                    Positioned(
                      bottom: 30,
                      right: 20,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 6,
                              offset: Offset(0, 3),
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
    Function(String)? onChanged,
    Widget? suffixIcon,
    TextEditingController? controller,
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
        onChanged: onChanged,
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
}

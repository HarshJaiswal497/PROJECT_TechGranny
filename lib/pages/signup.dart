// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:techgrannyapp/pages/home.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> with TickerProviderStateMixin {
  late FlutterTts flutterTts;
  int _currentStep = 0;

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  String _fullName = '';
  String _mobileNumber = '';
  String _password = '';
  String _confirmPassword = '';
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    _initTts();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speakSignupInstructions();
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

  Future<void> _speakSignupInstructions() async {
    try {
      setState(() => _currentStep = 6);
      await flutterTts.stop();
      await flutterTts.speak(
        "नमस्ते! यह साइन अप पेज है। चलिए मिलकर आपका अकाउंट बनाते हैं। नीचे दिए गए फील्ड्स में अपने विवरण ध्यान से भरें।",
      );
      await Future.delayed(const Duration(milliseconds: 800));

      setState(() => _currentStep = 1);
      await flutterTts.stop();
      await flutterTts.speak(
        "पहला फील्ड: कृपया अपना पूरा नाम दर्ज करें, ताकि हम आपको सही तरीके से जान सकें।",
      );
      await Future.delayed(const Duration(milliseconds: 800));

      setState(() => _currentStep = 2);
      await flutterTts.stop();
      await flutterTts.speak(
        "दूसरा फील्ड: अपना मोबाइल नंबर डालें, ताकि हम आपके साथ आसानी से संपर्क कर सकें।",
      );
      await Future.delayed(const Duration(milliseconds: 800));

      setState(() => _currentStep = 3);
      await flutterTts.stop();
      await flutterTts.speak(
        "अब अपना पासवर्ड चुनें। यह सुरक्षित और याद रखने में आसान होना चाहिए। कम से कम 6 अक्षरों का होना चाहिए।",
      );
      await Future.delayed(const Duration(milliseconds: 800));

      setState(() => _currentStep = 4);
      await flutterTts.stop();
      await flutterTts.speak(
        "पासवर्ड की पुष्टि करें, ताकि हम सुनिश्चित कर सकें कि आपने सही पासवर्ड डाला है।",
      );
      await Future.delayed(const Duration(milliseconds: 800));

      setState(() => _currentStep = 5);
      await flutterTts.stop();
      await flutterTts.speak(
        "सभी जानकारी भरने के बाद, कृपया साइन अप बटन दबाएँ और आपका अकाउंट तैयार हो जाएगा।",
      );
      await Future.delayed(const Duration(milliseconds: 800));

      setState(() => _currentStep = 6);
      await flutterTts.stop();
      await flutterTts.speak(
        "यदि आप निर्देश फिर से सुनना चाहें, तो ऊपर वॉइस आइकॉन को टैप करें। मैं हमेशा आपकी मदद के लिए यहाँ हूँ।",
      );

      setState(() => _currentStep = 0);
    } catch (e) {
      debugPrint("TTS Error: $e");
    }
  }

  void _validatePassword(String value, {bool isConfirm = false}) {
    setState(() {
      if (isConfirm) {
        _confirmPassword = value;
        if (_password != _confirmPassword) {
          _passwordError = "पासवर्ड मेल नहीं खा रहा।";
        } else {
          _passwordError = null;
        }
      } else {
        _password = value;
        if (_password.length < 6) {
          _passwordError = "पासवर्ड कम से कम 6 अक्षरों का होना चाहिए।";
        } else if (_confirmPassword.isNotEmpty &&
            _confirmPassword != _password) {
          _passwordError = "पासवर्ड मेल नहीं खा रहा।";
        } else {
          _passwordError = null;
        }
      }
    });

    if (_passwordError != null) {
      flutterTts.speak(_passwordError!);
    }
  }

  bool _validateFields() {
    if (_fullName.isEmpty ||
        _mobileNumber.isEmpty ||
        _password.isEmpty ||
        _confirmPassword.isEmpty) {
      flutterTts.speak("कृपया सभी फील्ड्स भरें।");
      return false;
    }
    if (_mobileNumber.length != 10 ||
        !_mobileNumber.contains(RegExp(r'^[0-9]+$'))) {
      flutterTts.speak("कृपया 10 अंकों का सही मोबाइल नंबर डालें।");
      return false;
    }
    if (_passwordError != null) {
      flutterTts.speak("कृपया पासवर्ड की शर्तें पूरी करें।");
      return false;
    }
    return true;
  }

  @override
  void dispose() {
    flutterTts.stop();
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
                                    color: Colors.redAccent.withOpacity(0.8),
                                    blurRadius: 20,
                                    spreadRadius: 4,
                                  ),
                                ]
                              : [],
                        ),
                        child: GestureDetector(
                          onTap: _speakSignupInstructions,
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
                      onChanged: (val) => _fullName = val,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      'Mobile Number',
                      2,
                      keyboardType: TextInputType.phone,
                      onChanged: (val) => _mobileNumber = val,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      'Password',
                      3,
                      obscureText: _obscurePassword,
                      onChanged: (val) => _validatePassword(val),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_outlined,
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      'Confirm Password',
                      4,
                      obscureText: _obscureConfirm,
                      onChanged: (val) =>
                          _validatePassword(val, isConfirm: true),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility
                              : Icons.visibility_outlined,
                        ),
                        onPressed: () {
                          setState(() => _obscureConfirm = !_obscureConfirm);
                        },
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
                        flutterTts.speak(
                          "साइन अप सफल रहा! आपका अकाउंट बन गया है।",
                        );
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomePage(),
                          ),
                          (Route<dynamic> route) =>
                              false, // removes all previous routes
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
    );
  }

  Widget _buildTextField(
    String label,
    int step, {
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Function(String)? onChanged,
    Widget? suffixIcon,
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
        style: const TextStyle(fontFamily: 'OpenSans'),
        onChanged: onChanged,
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

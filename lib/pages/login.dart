// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:techgrannyapp/pages/home.dart';

class LogInPage extends StatefulWidget {
  const LogInPage({super.key});

  @override
  State<LogInPage> createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> with TickerProviderStateMixin {
  late FlutterTts flutterTts;
  int _currentStep = 0;

  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _firstPasswordFocus = true;
  String? _loginError;

  @override
  void initState() {
    super.initState();
    _initTts();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speakLoginInstructions();
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

  Future<void> _speakLoginInstructions() async {
    try {
      setState(() => _currentStep = 4);
      await flutterTts.stop();
      await flutterTts.speak(
        "नमस्ते! आप लॉगिन पेज पर हैं। मैं आपकी मदद करूँगी।",
      );
      await Future.delayed(const Duration(milliseconds: 800));

      setState(() => _currentStep = 1);
      await flutterTts.stop();
      await flutterTts.speak(
        "पहला फील्ड: कृपया अपना मोबाइल नंबर सावधानी से दर्ज करें।",
      );
      await Future.delayed(const Duration(milliseconds: 800));

      setState(() => _currentStep = 2);
      await flutterTts.stop();
      await flutterTts.speak("दूसरा फील्ड: अपना पासवर्ड ध्यान से टाइप करें।");
      await Future.delayed(const Duration(milliseconds: 800));

      setState(() => _currentStep = 3);
      await flutterTts.stop();
      await flutterTts.speak("अब लॉगिन करने के लिए बटन दबाएँ।");
      await Future.delayed(const Duration(milliseconds: 800));

      setState(() => _currentStep = 4);
      await flutterTts.stop();
      await flutterTts.speak(
        "यदि आप निर्देश दोबारा सुनना चाहती हैं, तो ऊपर वॉइस आइकॉन को टैप करें। मैं आपकी मदद हमेशा करूँगी।",
      );

      setState(() => _currentStep = 0);
    } catch (e) {
      debugPrint("TTS Error: $e");
    }
  }

  void _login() {
    final mobile = _mobileController.text.trim();
    final password = _passwordController.text.trim();

    if (mobile.isEmpty || password.isEmpty) {
      flutterTts.speak("कृपया सभी फील्ड भरें।");
      setState(() => _loginError = "सभी फील्ड भरें।");
      return;
    }
    if (mobile.length != 10 || !RegExp(r'^[0-9]+$').hasMatch(mobile)) {
      flutterTts.speak("मोबाइल नंबर 10 अंकों का होना चाहिए।");
      setState(() => _loginError = "मोबाइल नंबर 10 अंकों का होना चाहिए।");
      return;
    }

    // Login success
    flutterTts.speak("लॉगिन सफल! आपका स्वागत है।");
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
      (Route<dynamic> route) => false, // removes all previous routes
    );
  }

  @override
  void dispose() {
    flutterTts.stop();
    _mobileController.dispose();
    _passwordController.dispose();
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
                          boxShadow: _currentStep == 4
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
                          onTap: _speakLoginInstructions,
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
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      'Password',
                      2,
                      obscureText: _obscurePassword,
                      controller: _passwordController,
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

                // Login Button
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
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF05C46B),
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
                  onPressed: () {
                    Navigator.pop(context);
                  },
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
}

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class PayViaUpiTutorialPage extends StatefulWidget {
  const PayViaUpiTutorialPage({super.key});

  @override
  State<PayViaUpiTutorialPage> createState() => _PayViaUpiTutorialPageState();
}

class _PayViaUpiTutorialPageState extends State<PayViaUpiTutorialPage> {
  final FlutterTts _tts = FlutterTts();

  int _currentStep = 0;
  bool _isSpeaking = false;
  bool _shouldStop = false;

  final List<_TutorialStep> _steps = [
    _TutorialStep(
      title: "Open UPI App",
      instruction:
          "सबसे पहले अपना UPI ऐप खोलिए, जैसे Google Pay, PhonePe या BHIM।",
      imagePath: "assets/images/tutorials/upi_open_app.jpeg",
    ),
    _TutorialStep(
      title: "Tap Scan QR",
      instruction: "अब Scan QR वाले बटन को दबाइए।",
      imagePath: "assets/images/tutorials/upi_scan_qr.jpeg",
    ),
    _TutorialStep(
      title: "Scan Store QR",
      instruction:
          "अब दुकान के QR कोड को कैमरे के सामने लाइए और उसे स्कैन होने दीजिए।",
      imagePath: "assets/images/tutorials/upi_scan_store_qr.jpeg",
    ),
    _TutorialStep(
      title: "Enter Amount",
      instruction:
          "अब जितने पैसे देने हैं, वह राशि लिखिए। उदाहरण के लिए 100 रुपये।",
      imagePath: "assets/images/tutorials/upi_enter_amount.jpeg",
    ),
    _TutorialStep(
      title: "Enter UPI PIN",
      instruction:
          "अब अपना UPI PIN दर्ज करके भुगतान पूरा कीजिए। याद रखिए, अपना UPI PIN कभी भी किसी के साथ साझा न करें।",
      imagePath: "assets/images/tutorials/upi_enter_pin.jpeg",
    ),
    _TutorialStep(
      title: "Payment Successful",
      instruction:
          "शाबाश! आपका भुगतान सफलतापूर्वक हो गया है। अब आप QR कोड स्कैन करके सुरक्षित तरीके से भुगतान कर सकते हैं।",
      imagePath: "assets/images/tutorials/upi_payment_success.jpeg",
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildMainContent(),

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

              Container(
                height: screenHeight * 0.45,
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

  Widget _buildOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.45),
        child: Stack(
          children: [
            Positioned(
              bottom: 110,
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

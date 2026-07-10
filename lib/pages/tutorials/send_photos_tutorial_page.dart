// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import '../../localization/app_localization.dart';
import '../../services/tts_service.dart';

class SendPhotosTutorialPage extends StatefulWidget {
  const SendPhotosTutorialPage({super.key});

  @override
  State<SendPhotosTutorialPage> createState() =>
      _SendPhotosTutorialPageState();
}

class _SendPhotosTutorialPageState
    extends State<SendPhotosTutorialPage> {

  int _currentStep = 0;

  bool _isSpeaking = false;

  bool _shouldStop = false;

  final List<_TutorialStep> _steps = [
    _TutorialStep(
      titleKey: "photoStep1Title",
      instructionKey: "photoStep1Instruction",
      imagePath: "assets/images/tutorials/photo_open_whatsapp.jpeg",
    ),
    _TutorialStep(
      titleKey: "photoStep2Title",
      instructionKey: "photoStep2Instruction",
      imagePath: "assets/images/tutorials/photo_select_contact.jpeg",
    ),
    _TutorialStep(
      titleKey: "photoStep3Title",
      instructionKey: "photoStep3Instruction",
      imagePath: "assets/images/tutorials/photo_attachment.jpeg",
    ),
    _TutorialStep(
      titleKey: "photoStep4Title",
      instructionKey: "photoStep4Instruction",
      imagePath: "assets/images/tutorials/photo_gallery.jpeg",
    ),
    _TutorialStep(
      titleKey: "photoStep5Title",
      instructionKey: "photoStep5Instruction",
      imagePath: "assets/images/tutorials/photo_send.jpeg",
    ),
    _TutorialStep(
      titleKey: "photoStep6Title",
      instructionKey: "photoStep6Instruction",
      imagePath: "assets/images/tutorials/photo_success.jpeg",
    ),
  ];

  @override
  void initState() {
    super.initState();

    _initialize();
  }

  Future<void> _initialize() async {
    await TTSService.initialize();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speakCurrentStep();
    });
  }
    Future<void> _speakCurrentStep() async {
      if (_isSpeaking) return;

      _shouldStop = false;

      setState(() {
        _isSpeaking = true;
      });

      try {
        await TTSService.speak(
          AppLocalization.tts(
            "tutorials",
            _steps[_currentStep].instructionKey,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isSpeaking = false;
            _shouldStop = false;
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
        });
      }
    }

    void _nextStep() {
      if (_currentStep < _steps.length - 1) {
        setState(() {
          _currentStep++;
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _speakCurrentStep();
        });
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
              startAngle: 0,
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
                    "${AppLocalization.ui("tutorials", "step")} ${_currentStep + 1} ${AppLocalization.ui("tutorials", "of")} ${_steps.length}",
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    AppLocalization.ui(
                      "tutorials",
                      step.titleKey,
                    ),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Container(
                    height: screenHeight * 0.42,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple.withOpacity(.15),
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
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    AppLocalization.tts(
                      "tutorials",
                      step.instructionKey,
                    ),
                    style: const TextStyle(
                      fontSize: 17,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 20),

                  _progressDots(),

                  const Spacer(),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _speakCurrentStep,
                          child: Text(
                            AppLocalization.ui(
                              "tutorials",
                              "repeat",
                            ),
                          ),
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
                            _currentStep == _steps.length - 1
                                ? AppLocalization.ui(
                                    "tutorials",
                                    "finish",
                                  )
                                : AppLocalization.ui(
                                    "tutorials",
                                    "next",
                                  ),
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      AppLocalization.ui(
                        "tutorials",
                        "exitTutorial",
                      ),
                    ),
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
                  color: active
                      ? Colors.deepPurple
                      : Colors.grey[300],
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
                    right: 20,
                    bottom: 110,
                    child: ElevatedButton(
                      onPressed: _stopSpeaking,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9B4DFF),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 18,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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
                ],
              ),
            ),
          );
        }

        @override
        void dispose() {
          TTSService.stop();
          super.dispose();
        }
      }

      class _TutorialStep {
        final String titleKey;
        final String instructionKey;
        final String imagePath;

        const _TutorialStep({
          required this.titleKey,
          required this.instructionKey,
          required this.imagePath,
        });
      }
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FlutterTts _tts = FlutterTts();

  bool _isSpeaking = false;
  bool _shouldStop = false;

  int _highlightTarget = 0;
  // 0 = none, 1 = profile, 2 = language, 3 = help, 4 = logout, 5 = voice

  String _name = '';
  String _phone = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initTts();
    _fetchProfile();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speakInstructions();
    });
  }

  Future<void> _initTts() async {
    await _tts.awaitSpeakCompletion(true);
    await _tts.setLanguage("hi-IN");
    await _tts.setSpeechRate(0.5);
  }

  Future<void> _fetchProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      setState(() {
        _name = doc.data()?['name'] ?? '';
        _language = doc.data()?['languagePreference'] ?? 'hi';
        _phone = user.phoneNumber ?? '';
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  // ---------------- VOICE INSTRUCTIONS ----------------
  Future<void> _speakInstructions() async {
    if (_isSpeaking) return;

    _shouldStop = false;
    setState(() {
      _isSpeaking = true;
      _highlightTarget = 5; // voice icon
    });

    bool abort() => _shouldStop;

    try {
      setState(() => _highlightTarget = 1);
      await _tts.speak(
        "नमस्ते ${_name.isNotEmpty ? _name + " जी" : ""}। यह आपका प्रोफ़ाइल पेज है।",
      );
      if (abort()) return;

      setState(() => _highlightTarget = 2);
      await _tts.speak("यहाँ आप अपनी पसंदीदा भाषा बदल सकते हैं।");
      if (abort()) return;

      setState(() => _highlightTarget = 3);
      await _tts.speak("अगर आपको मदद चाहिए, तो हेल्प बटन दबाएँ।");
      if (abort()) return;

      setState(() => _highlightTarget = 4);
      await _tts.speak(
        "ऐप से सुरक्षित रूप से बाहर निकलने के लिए लॉग आउट बटन का उपयोग करें।",
      );
    } catch (_) {}

    if (mounted) {
      setState(() {
        _isSpeaking = false;
        _shouldStop = false;
        _highlightTarget = 0;
      });
    }
  }

  Future<void> _stopSpeaking() async {
    _shouldStop = true;
    try {
      await _tts.stop();
    } catch (_) {}
    setState(() {
      _isSpeaking = false;
      _highlightTarget = 0;
    });
  }

  // ---------------- ACTIONS ----------------
  Future<void> _changeLanguage() async {
    final selected = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Choose Language"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'hi'),
            child: const Text("Hindi (हिंदी)"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'en'),
            child: const Text("English"),
          ),
        ],
      ),
    );

    if (selected == null) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'languagePreference': selected,
    });

    setState(() => _language = selected);

    await _tts.speak(
      selected == 'hi'
          ? "भाषा हिंदी में सेट कर दी गई है।"
          : "Language set to English.",
    );
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildMainContent(),

          // 🔊 Voice icon
          Positioned(
            top: 40,
            right: 20,
            child: _highlightWrapper(
              active: _highlightTarget == 5,
              child: IconButton(
                icon: const Icon(
                  Icons.volume_up,
                  size: 34,
                  color: Color(0xFF9B4DFF),
                ),
                onPressed: () async {
                  await _tts.stop();
                  _speakInstructions();
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
              const SizedBox(height: 40),

              _highlightWrapper(
                active: _highlightTarget == 1,
                child: _profileCard(),
              ),
              const SizedBox(height: 20),

              _highlightWrapper(
                active: _highlightTarget == 2,
                child: _actionCard(
                  icon: Icons.language,
                  title: "Language",
                  subtitle: _language == 'hi' ? "Hindi (हिंदी)" : "English",
                  onTap: _changeLanguage,
                ),
              ),

              _highlightWrapper(
                active: _highlightTarget == 3,
                child: _actionCard(
                  icon: Icons.help_outline,
                  title: "Help",
                  subtitle: "Need help using the app?",
                  onTap: () async {
                    await _tts.speak(
                      "अगर आप कहीं अटक जाएँ, तो चिंता मत कीजिए।",
                    );
                    await _tts.speak(
                      "हर पेज के ऊपर दिए गए वॉइस आइकन पर टैप करें।",
                    );
                    await _tts.speak(
                      "दोबारा सुनें और समझें कि आगे क्या करना है।",
                    );
                  },
                ),
              ),

              const Spacer(),

              _highlightWrapper(
                active: _highlightTarget == 4,
                child: _logoutButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _highlightWrapper({required bool active, required Widget child}) {
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

  Widget _profileCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 34,
            backgroundColor: Colors.deepPurple,
            child: Icon(Icons.person, color: Colors.white, size: 34),
          ),
          const SizedBox(height: 12),
          Text(
            _loading ? "Loading..." : "${_name.isNotEmpty ? _name : "User"} Ji",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(_phone, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _actionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: _cardDecoration(),
          child: Row(
            children: [
              Icon(icon, color: Colors.deepPurple),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Widget _logoutButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.redAccent,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      onPressed: _logout,
      child: const Text(
        "Log Out",
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
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
                child: const Text(
                  "Skip",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white.withOpacity(0.9),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.deepPurple.withOpacity(0.15),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}

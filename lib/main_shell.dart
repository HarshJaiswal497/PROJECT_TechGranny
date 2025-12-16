import 'dart:ui';
import 'package:flutter/material.dart';

import 'pages/home.dart';
import 'pages/tutorials_page.dart';
import 'pages/appointments_page.dart';
import 'pages/profile_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  List<Widget> get _pages => [
        HomePage(
          onViewAllTutorials: () {
            setState(() => _currentIndex = 1); // Learn tab
          },
          onViewAllAppointments: () {
            setState(() => _currentIndex = 2); // Appointments tab
          },
        ),
        const TutorialsPage(),
        const AppointmentsPage(),
        const ProfilePage(),
      ];

  final List<IconData> _icons = [
    Icons.home_rounded,
    Icons.menu_book_rounded,
    Icons.calendar_month_rounded,
    Icons.person_rounded,
  ];

  final List<String> _labels = [
    "Home",
    "Learn",
    "Appointments",
    "Profile",
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // 🔑 THIS IS THE FIX
      onWillPop: () async {
        if (_currentIndex != 0) {
          // If not on Home tab → go to Home instead of exiting
          setState(() {
            _currentIndex = 0;
          });
          return false; // ⛔ prevent popping route
        }
        return true; // ✅ allow app exit / back to welcome
      },
      child: Scaffold(
        extendBody: true,
        body: _pages[_currentIndex],

        bottomNavigationBar: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
                child: BottomNavigationBar(
                  currentIndex: _currentIndex,
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  selectedItemColor: Colors.deepPurple,
                  unselectedItemColor: Colors.black54,
                  onTap: (index) {
                    setState(() => _currentIndex = index);
                  },
                  items: List.generate(_icons.length, (i) {
                    final selected = _currentIndex == i;
                    return BottomNavigationBarItem(
                      label: _labels[i],
                      icon: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? Colors.deepPurple.withOpacity(0.15)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(_icons[i]),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

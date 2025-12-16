import 'package:flutter/material.dart';

class TutorialsPage extends StatelessWidget {
  const TutorialsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tutorials")),
      body: const Center(child: Text("Tutorials Page")),
    );
  }
}

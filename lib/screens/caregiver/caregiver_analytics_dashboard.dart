import 'package:flutter/material.dart';

class CaregiverAnalyticsDashboard extends StatelessWidget {
  const CaregiverAnalyticsDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cognitive Analytics"),
        backgroundColor: const Color(0xFF005F46),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          "Caregiver Cognitive Analytics View",
          style: TextStyle(fontSize: 18, color: Color(0xFF005F46)),
        ),
      ),
    );
  }
}

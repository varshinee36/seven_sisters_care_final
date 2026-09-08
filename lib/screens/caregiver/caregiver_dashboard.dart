import 'package:flutter/material.dart';

class CaregiverDashboard extends StatelessWidget {
  const CaregiverDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Caregiver Dashboard"),
        backgroundColor: const Color(0xFF005F46),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          "Caregiver Dashboard View",
          style: TextStyle(fontSize: 18, color: Color(0xFF005F46)),
        ),
      ),
    );
  }
}

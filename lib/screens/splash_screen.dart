import 'dart:async';
import 'package:flutter/material.dart';
import 'get_started_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() =>
      _SplashScreenState();
}

class _SplashScreenState
    extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();

    Timer(
      const Duration(seconds: 3),
      () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                const GetStartedScreen(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    double screenWidth =
        MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF2B2525),

      body: Center(
        child: Container(
          width: screenWidth > 700 ? 500 : 340,
          padding: const EdgeInsets.all(30),

          decoration: BoxDecoration(
            color: const Color(0xFFD9E5E1),
            borderRadius:
                BorderRadius.circular(30),
          ),

          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              Image.asset(
                "assets/images/logo.jpg",
                height: 120,
              ),

              const SizedBox(height: 25),

              const Text(
                "SEVEN SISTERS CARE",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF005F46),
                ),
              ),

              const SizedBox(height: 15),

              const Text(
                "Companion for Cognitive Health\nand Elderly Well-being",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 30),

              const CircularProgressIndicator(
                color: Color(0xFF005F46),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
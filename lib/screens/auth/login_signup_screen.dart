import 'package:flutter/material.dart';

import 'login_screen.dart';
import '../registration/patient_registration_screen.dart';

class LoginSignupScreen extends StatelessWidget {
  const LoginSignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2B2525),

      body: Container(
        width: double.infinity,
        height: double.infinity,

        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              "assets/images/background.jpg",
            ),
            fit: BoxFit.cover,
          ),
        ),

        child: Center(
          child: Container(
            width: 450,
            padding: const EdgeInsets.symmetric(
              horizontal: 40,
              vertical: 50,
            ),

            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.90),
              borderRadius: BorderRadius.circular(25),
            ),

            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Seven Sisters Care",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF005F46),
                  ),
                ),

                const SizedBox(height: 15),

                const Text(
                  "AI Based Cognitive Gaming and Memory Assistance Platform",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 50),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const LoginScreen(),
                        ),
                      );
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFF005F46),

                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                    ),

                    child: const Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "OR",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF005F46),
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 55,

                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const PatientRegistrationScreen(),
                        ),
                      );
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFF73B397),

                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                    ),

                    child: const Text(
                      "Sign Up",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
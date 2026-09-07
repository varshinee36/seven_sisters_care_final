import 'package:flutter/material.dart';
import 'auth/login_signup_screen.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth =
        MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF2B2525),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: screenWidth > 700 ? 500 : 340,

              decoration: BoxDecoration(
                color: const Color(0xFFD9E5E1),
                borderRadius:
                    BorderRadius.circular(30),
              ),

              child: Column(
                mainAxisSize: MainAxisSize.min,

                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.only(
                      topLeft:
                          Radius.circular(30),
                      topRight:
                          Radius.circular(30),
                    ),

                    child: Image.asset(
                      "assets/images/elderly_family.jpg",
                      height: screenWidth > 700
                          ? 400
                          : 350,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),

                  const SizedBox(height: 40),

                  const Text(
                    "SEVEN SISTERS CARE",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight:
                          FontWeight.w700,
                      color: Color(0xFF4A1F16),
                      letterSpacing: 1,
                    ),
                  ),

                  const SizedBox(height: 25),

                  const Padding(
                    padding:
                        EdgeInsets.symmetric(
                      horizontal: 25,
                    ),
                    child: Text(
                      "Companion for Cognitive Health\nand Elderly Well-being",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  SizedBox(
                    width: 250,
                    height: 65,

                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const LoginSignupScreen(),
                          ),
                        );
                      },

                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(
                                0xFF73B397),
                        foregroundColor:
                            Colors.white,
                        elevation: 0,

                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                                      40),
                        ),
                      ),

                      child: const Text(
                        "Get Started",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
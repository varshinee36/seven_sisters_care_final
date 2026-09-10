import 'package:flutter/material.dart';
import '../patient/patient_home_screen.dart';
import '../caregiver/caregiver_dashboard.dart';
import '../../localization/app_localizations.dart';

class ChooseRoleScreen extends StatelessWidget {
  const ChooseRoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final loc = context.loc;

    return Scaffold(
      backgroundColor: const Color(0xFF2B2525),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: screenWidth > 600 ? 500 : 340,
              constraints: const BoxConstraints(minHeight: 650),

              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                image: const DecorationImage(
                  image: AssetImage(
                    "assets/images/background.jpg",
                  ),
                  fit: BoxFit.cover,
                ),
              ),

              child: Column(
                children: [
                  const SizedBox(height: 90),

                  Text(
                    loc.chooseYourRole,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF005F46),
                    ),
                  ),

                  const SizedBox(height: 100),

                  SizedBox(
                    width: 260,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PatientHomeScreen(),
                          ),
                        );
                      },

                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(260, 100),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        backgroundColor:
                            const Color(0xFF73B397),

                        foregroundColor: Colors.white,

                        elevation: 3,

                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(20),

                          side: const BorderSide(
                            color: Color(0xFF005F46),
                            width: 1.5,
                          ),
                        ),
                      ),

                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment:
                            MainAxisAlignment.center,

                        children: [
                          Text(
                            loc.patient,
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF005F46),
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            loc.continueAsPatient,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  SizedBox(
                    width: 260,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CaregiverDashboard(),
                          ),
                        );
                      },

                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(260, 100),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        backgroundColor:
                            const Color(0xFF73B397),

                        foregroundColor: Colors.white,

                        elevation: 3,

                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(20),

                          side: const BorderSide(
                            color: Color(0xFF005F46),
                            width: 1.5,
                          ),
                        ),
                      ),

                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment:
                            MainAxisAlignment.center,

                        children: [
                          Text(
                            loc.caregiver,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF005F46),
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            loc.continueAsCaregiver,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
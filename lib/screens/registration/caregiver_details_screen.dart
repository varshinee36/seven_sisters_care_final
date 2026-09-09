import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../auth/login_screen.dart';

class CaregiverDetailsScreen extends StatefulWidget {
  final String patientName;
  final String dob;
  final String gender;
  final String languagePreference;
  final bool readingPreference;
  final String dementiaStage;

  const CaregiverDetailsScreen({
    super.key,
    this.patientName = "",
    this.dob = "",
    this.gender = "Male",
    this.languagePreference = "English",
    this.readingPreference = true,
    this.dementiaStage = "Mild",
  });

  @override
  State<CaregiverDetailsScreen> createState() =>
      _CaregiverDetailsScreenState();
}

class _CaregiverDetailsScreenState
    extends State<CaregiverDetailsScreen> {
  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController phoneController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  String relationship = "Son";
  bool hidePassword = true;
  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final caregiverName = nameController.text.trim();
    final phone = phoneController.text.trim();
    final password = passwordController.text;

    if (caregiverName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter caregiver name"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (caregiverName.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Name must contain at least 3 characters"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter phone number"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (!RegExp(r'^[0-9]{10}$').hasMatch(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a valid 10 digit phone number"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter password"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password must be at least 6 characters"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // 1. Call User Registration API (POST /auth/register)
      final userResult = await ApiService.registerUser(
        username: caregiverName,
        password: password,
        role: "caregiver",
      );

      if (!mounted) return;

      if (userResult["message"] != "User registered successfully") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(userResult["detail"] ??
                userResult["message"] ??
                "User registration failed"),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      // 2. Call Patient Registration API (POST /patient/register)
      final patientResult = await ApiService.registerPatient(
        caregiverUsername: caregiverName,
        patientName: widget.patientName.isNotEmpty
            ? widget.patientName
            : caregiverName,
        dob: widget.dob.isNotEmpty ? widget.dob : "1950-01-01",
        gender: widget.gender,
        languagePreference: widget.languagePreference,
        readingPreference: widget.readingPreference,
        dementiaStage: widget.dementiaStage,
      );

      if (!mounted) return;

      if (patientResult["message"] == "Patient registered successfully" ||
          patientResult["patient_id"] != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Registration successful! Please login."),
            backgroundColor: Color(0xFF005F46),
          ),
        );

        // Navigate to LoginScreen
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(patientResult["detail"] ??
                patientResult["message"] ??
                "Patient registration failed"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Registration error: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

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
              width: screenWidth > 1200
                  ? 700
                  : screenWidth > 800
                      ? 600
                      : screenWidth > 600
                          ? 500
                          : screenWidth * 0.92,

              margin: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: const Color(0xFFCFEDE2),
                borderRadius:
                    BorderRadius.circular(30),
              ),

              child: Padding(
                padding: const EdgeInsets.all(25),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    const SizedBox(height: 10),

                    const Text(
                      "Setup Profile",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 8),

                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(
                              10),
                      child:
                          LinearProgressIndicator(
                        value: 1.0,
                        minHeight: 6,
                        backgroundColor:
                            Colors.white,
                        color:
                            const Color(
                                0xFF73B397),
                      ),
                    ),

                    const SizedBox(height: 25),

                    Center(
                      child: Container(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),

                        decoration:
                            BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius
                                  .circular(
                                      10),
                        ),

                        child: const Text(
                          "Caregiver Details",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight:
                                FontWeight.bold,
                            color: Color(
                                0xFF005F46),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor:
                                Colors.grey
                                    .shade400,

                            child: const Icon(
                              Icons.person,
                              size: 60,
                              color:
                                  Colors.white,
                            ),
                          ),

                          Positioned(
                            bottom: 0,
                            right: 0,
                            child:
                                CircleAvatar(
                              radius: 18,
                              backgroundColor:
                                  const Color(
                                      0xFF005F46),

                              child:
                                  IconButton(
                                padding:
                                    EdgeInsets
                                        .zero,

                                icon:
                                    const Icon(
                                  Icons
                                      .camera_alt,
                                  size: 15,
                                  color: Colors
                                      .white,
                                ),

                                onPressed:
                                    () {},
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    const Text(
                      "Caregiver Name",
                      style: TextStyle(
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 6),

                    TextField(
                      controller:
                          nameController,

                      decoration:
                          InputDecoration(
                        hintText:
                            "Enter Name",

                        filled: true,
                        fillColor:
                            Colors.white,

                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                                      10),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "Relationship To Patient",
                      style: TextStyle(
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 6),

                    DropdownButtonFormField<
                        String>(
                      initialValue: relationship,

                      decoration:
                          InputDecoration(
                        filled: true,
                        fillColor:
                            Colors.white,

                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                                      10),
                        ),
                      ),

                      items: [
                        "Son",
                        "Daughter",
                        "Grandson",
                        "Granddaughter",
                        "Spouse",
                        "Other"
                      ]
                          .map(
                            (item) =>
                                DropdownMenuItem(
                              value: item,
                              child:
                                  Text(item),
                            ),
                          )
                          .toList(),

                      onChanged: (value) {
                        setState(() {
                          relationship =
                              value!;
                        });
                      },
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "Phone Number",
                      style: TextStyle(
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 6),

                    TextField(
                      controller:
                          phoneController,

                      keyboardType:
                          TextInputType
                              .number,

                      maxLength: 10,

                      decoration:
                          InputDecoration(
                        hintText:
                            "9876543210",

                        counterText: "",

                        filled: true,
                        fillColor:
                            Colors.white,

                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                                      10),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "Password",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 6),

                    TextField(
                      controller: passwordController,
                      obscureText: hidePassword,
                      decoration: InputDecoration(
                        hintText: "Enter Password",
                        filled: true,
                        fillColor: Colors.white,
                        suffixIcon: IconButton(
                          icon: Icon(
                            hidePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              hidePassword = !hidePassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF005F46),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                "Submit",
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
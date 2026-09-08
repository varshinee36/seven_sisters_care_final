import 'package:flutter/material.dart';
import 'package:seven_sisters_care/screens/auth/create_account_screen.dart';

class CaregiverDetailsScreen extends StatefulWidget {
  const CaregiverDetailsScreen({super.key});

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

  String relationship = "Son";

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
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
                      value: relationship,

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

                    const SizedBox(height: 30),

                    SizedBox(
                      width:
                          double.infinity,
                      height: 55,

                      child:
                          ElevatedButton(
                        onPressed: () {
                          if (nameController
                              .text
                              .trim()
                              .isEmpty) {
                            ScaffoldMessenger
                                    .of(
                                        context)
                                .showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Please enter caregiver name",
                                ),
                              ),
                            );
                            return;
                          }

                          if (nameController
                                  .text
                                  .trim()
                                  .length <
                              3) {
                            ScaffoldMessenger
                                    .of(
                                        context)
                                .showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Name must contain at least 3 characters",
                                ),
                              ),
                            );
                            return;
                          }

                          if (phoneController
                              .text
                              .trim()
                              .isEmpty) {
                            ScaffoldMessenger
                                    .of(
                                        context)
                                .showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Please enter phone number",
                                ),
                              ),
                            );
                            return;
                          }

                          if (!RegExp(
                            r'^[0-9]{10}$',
                          ).hasMatch(
                              phoneController
                                  .text)) {
                            ScaffoldMessenger
                                    .of(
                                        context)
                                .showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Please enter a valid 10 digit phone number",
                                ),
                              ),
                            );
                            return;
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      const CreateAccountScreen(),
                            ),
                          );
                        },

                        style:
                            ElevatedButton
                                .styleFrom(
                          backgroundColor:
                              const Color(
                                  0xFF005F46),

                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                                        15),
                          ),
                        ),

                        child: const Text(
                          "Submit",
                          style: TextStyle(
                            fontSize: 20,
                            color:
                                Colors.white,
                            fontWeight:
                                FontWeight.bold,
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
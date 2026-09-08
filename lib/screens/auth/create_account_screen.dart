import 'package:flutter/material.dart';
import '../role/choose_role_screen.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() =>
      _CreateAccountScreenState();
}

class _CreateAccountScreenState
    extends State<CreateAccountScreen> {
  final TextEditingController usernameController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool hidePassword = true;
  bool hideConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2B2525),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: 450,
              padding: const EdgeInsets.all(25),

              decoration: BoxDecoration(
                color: const Color(0xFFCFEDE2),
                borderRadius: BorderRadius.circular(30),
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  Center(
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(10),
                      ),
                      child: const Text(
                        "Create Account",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight:
                              FontWeight.bold,
                          color:
                              Color(0xFF005F46),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 35),

                  const Text(
                    "Username",
                    style: TextStyle(
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  TextField(
                    controller:
                        usernameController,
                    decoration: InputDecoration(
                      hintText:
                          "Enter Username",
                      filled: true,
                      fillColor: Colors.white,
                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                                10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Password",
                    style: TextStyle(
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  TextField(
                    controller:
                        passwordController,
                    obscureText: hidePassword,
                    decoration: InputDecoration(
                      hintText:
                          "Enter Password",
                      filled: true,
                      fillColor: Colors.white,
                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                                10),
                      ),
                      suffixIcon:
                          IconButton(
                        icon: Icon(
                          hidePassword
                              ? Icons
                                  .visibility_off
                              : Icons
                                  .visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            hidePassword =
                                !hidePassword;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Confirm Password",
                    style: TextStyle(
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  TextField(
                    controller:
                        confirmPasswordController,
                    obscureText:
                        hideConfirmPassword,
                    decoration: InputDecoration(
                      hintText:
                          "Confirm Password",
                      filled: true,
                      fillColor: Colors.white,
                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                                10),
                      ),
                      suffixIcon:
                          IconButton(
                        icon: Icon(
                          hideConfirmPassword
                              ? Icons
                                  .visibility_off
                              : Icons
                                  .visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            hideConfirmPassword =
                                !hideConfirmPassword;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 35),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        if (usernameController
                            .text
                            .trim()
                            .isEmpty) {
                          ScaffoldMessenger.of(
                                  context)
                              .showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Please enter username",
                              ),
                            ),
                          );
                          return;
                        }

                        if (usernameController
                                .text
                                .trim()
                                .length <
                            4) {
                          ScaffoldMessenger.of(
                                  context)
                              .showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Username must be at least 4 characters",
                              ),
                            ),
                          );
                          return;
                        }

                        if (passwordController
                            .text
                            .isEmpty) {
                          ScaffoldMessenger.of(
                                  context)
                              .showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Please enter password",
                              ),
                            ),
                          );
                          return;
                        }

                        if (passwordController
                                .text
                                .length <
                            6) {
                          ScaffoldMessenger.of(
                                  context)
                              .showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Password must be at least 6 characters",
                              ),
                            ),
                          );
                          return;
                        }

                        if (confirmPasswordController
                            .text
                            .isEmpty) {
                          ScaffoldMessenger.of(
                                  context)
                              .showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Please confirm password",
                              ),
                            ),
                          );
                          return;
                        }

                        if (passwordController
                                .text !=
                            confirmPasswordController
                                .text) {
                          ScaffoldMessenger.of(
                                  context)
                              .showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Passwords do not match",
                              ),
                            ),
                          );
                          return;
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const ChooseRoleScreen(),
                          ),
                        );
                      },

                      style: ElevatedButton
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
                        "Create Account",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
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
    );
  }
}
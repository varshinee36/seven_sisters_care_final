import 'package:flutter/material.dart';
import 'caregiver_details_screen.dart';

class PatientRegistrationScreen extends StatefulWidget {
  const PatientRegistrationScreen({super.key});

  @override
  State<PatientRegistrationScreen> createState() =>
      _PatientRegistrationScreenState();
}

class _PatientRegistrationScreenState
    extends State<PatientRegistrationScreen> {
  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController dobController =
      TextEditingController();

  String gender = "Male";
  String language = "English";
  String readingPreference = "Yes";
  String dementiaStage = "Mild";

  @override
  void dispose() {
    nameController.dispose();
    dobController.dispose();
    super.dispose();
  }

  Future<void> selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(1950),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        dobController.text =
            "${pickedDate.day}-${pickedDate.month}-${pickedDate.year}";
      });
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
              width: screenWidth > 600 ? 500 : 360,
              margin: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: const Color(0xFFCFEDE2),
                borderRadius: BorderRadius.circular(30),
              ),

              child: Padding(
                padding: const EdgeInsets.all(25),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    const Text(
                      "Setup Profile",
                      style: TextStyle(fontSize: 14),
                    ),

                    const SizedBox(height: 10),

                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(10),

                      child: const LinearProgressIndicator(
                        value: 0.5,
                        minHeight: 8,
                        backgroundColor: Colors.white,
                        color: Color(0xFF73B397),
                      ),
                    ),

                    const SizedBox(height: 25),

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
                          "Patient Details",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight:
                                FontWeight.bold,
                            color: Color(0xFF005F46),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor:
                                Colors.grey.shade400,
                            child: const Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),

                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor:
                                  const Color(
                                      0xFF005F46),
                              child: IconButton(
                                padding:
                                    EdgeInsets.zero,
                                icon: const Icon(
                                  Icons.camera_alt,
                                  size: 14,
                                  color: Colors.white,
                                ),
                                onPressed: () {},
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    const Text(
                      "Patient Name",
                      style: TextStyle(
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 5),

                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: "Enter Name",
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

                    const SizedBox(height: 15),

                    const Text(
                      "Date of Birth",
                      style: TextStyle(
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 5),

                    TextField(
                      controller: dobController,
                      readOnly: true,
                      onTap: () {
                        selectDate(context);
                      },
                      decoration: InputDecoration(
                        hintText: "DD-MM-YYYY",
                        filled: true,
                        fillColor: Colors.white,
                        suffixIcon: IconButton(
                          icon: const Icon(
                            Icons.calendar_month,
                          ),
                          onPressed: () {
                            selectDate(context);
                          },
                        ),
                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(
                                  10),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    const Text(
                      "Gender",
                      style: TextStyle(
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: Material(
                            color: Colors.transparent,
                            child: RadioListTile(
                              dense: true,
                              value: "Male",
                              groupValue: gender,
                              title:
                                  const Text("Male"),
                              onChanged: (value) {
                                setState(() {
                                  gender = value!;
                                });
                              },
                            ),
                          ),
                        ),

                        Expanded(
                          child: Material(
                            color: Colors.transparent,
                            child: RadioListTile(
                              dense: true,
                              value: "Female",
                              groupValue: gender,
                              title:
                                  const Text("Female"),
                              onChanged: (value) {
                                setState(() {
                                  gender = value!;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    const Text(
                      "Preferred Language",
                      style: TextStyle(
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 5),

                    DropdownButtonFormField<String>(
                      value: language,
                      decoration:
                          const InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items: [
                        "English",
                        "Hindi",
                        "Assamese",
                        "Bodo",
                        "Manipuri",
                        "Mizo",
                        "Khasi",
                        "Garo",
                      ]
                          .map(
                            (e) =>
                                DropdownMenuItem(
                              value: e,
                              child: Text(e),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          language = value!;
                        });
                      },
                    ),

                    const SizedBox(height: 15),

                    const Text(
                      "Reading/Text Games Preferred",
                      style: TextStyle(
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: Material(
                            color: Colors.transparent,
                            child: RadioListTile(
                              dense: true,
                              title:
                                  const Text("Yes"),
                              value: "Yes",
                              groupValue:
                                  readingPreference,
                              onChanged: (value) {
                                setState(() {
                                  readingPreference =
                                      value!;
                                });
                              },
                            ),
                          ),
                        ),

                        Expanded(
                          child: Material(
                            color: Colors.transparent,
                            child: RadioListTile(
                              dense: true,
                              title:
                                  const Text("No"),
                              value: "No",
                              groupValue:
                                  readingPreference,
                              onChanged: (value) {
                                setState(() {
                                  readingPreference =
                                      value!;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    const Text(
                      "Dementia Stage",
                      style: TextStyle(
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 5),

                    DropdownButtonFormField<String>(
                      value: dementiaStage,
                      decoration:
                          const InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items: [
                        "Mild",
                        "Moderate",
                        "Severe",
                      ]
                          .map(
                            (e) =>
                                DropdownMenuItem(
                              value: e,
                              child: Text(e),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          dementiaStage = value!;
                        });
                      },
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 55,

                      child: ElevatedButton(
                        onPressed: () {
                          if (nameController.text
                              .trim()
                              .isEmpty) {
                            ScaffoldMessenger.of(
                                    context)
                                .showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Please enter patient name",
                                ),
                              ),
                            );
                            return;
                          }

                          if (dobController.text
                              .trim()
                              .isEmpty) {
                            ScaffoldMessenger.of(
                                    context)
                                .showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Please select date of birth",
                                ),
                              ),
                            );
                            return;
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const CaregiverDetailsScreen(),
                            ),
                          );
                        },

                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(
                                  0xFF005F46),
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                                    15),
                          ),
                        ),

                        child: const Text(
                          "Next",
                          style: TextStyle(
                            fontSize: 20,
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
        ),
      ),
    );
  }
}
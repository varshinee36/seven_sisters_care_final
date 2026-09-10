import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'caregiver_details_screen.dart';
import '../../localization/app_localizations.dart';
import '../../providers/language_provider.dart';
import '../../services/language_service.dart';

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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        try {
          final currentLang =
              context.read<LanguageProvider>().currentLanguageName;
          setState(() {
            language = currentLang;
          });
        } catch (_) {
          final currentLang = LanguageService.nameFromCode(
              LanguageService.instance.getSavedLanguage());
          setState(() {
            language = currentLang;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    dobController.dispose();
    super.dispose();
  }

  DateTime? selectedDob;

  Future<void> selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(1950),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      selectedDob = pickedDate;
      setState(() {
        dobController.text =
            "${pickedDate.day.toString().padLeft(2, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth =
        MediaQuery.of(context).size.width;
    final loc = context.loc;

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
                    Text(
                      loc.setupProfile,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF005F46),
                      ),
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

                        child: Text(
                          loc.patientDetails,
                          style: const TextStyle(
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

                    Text(
                      loc.patientName,
                      style: const TextStyle(
                        fontWeight:
                            FontWeight.w600,
                        color: Color(0xFF005F46),
                      ),
                    ),

                    const SizedBox(height: 5),

                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: loc.enterName,
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

                    Text(
                      loc.dateOfBirth,
                      style: const TextStyle(
                        fontWeight:
                            FontWeight.w600,
                        color: Color(0xFF005F46),
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

                    Text(
                      loc.gender,
                      style: const TextStyle(
                        fontWeight:
                            FontWeight.w600,
                        color: Color(0xFF005F46),
                      ),
                    ),

                    RadioGroup<String>(
                      groupValue: gender,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            gender = value;
                          });
                        }
                      },
                      child: Row(
                        children: [
                          Expanded(
                            child: Material(
                              color: Colors.transparent,
                              child: RadioListTile<String>(
                                dense: true,
                                value: "Male",
                                title: Text(
                                  loc.male,
                                  style: const TextStyle(
                                    color: Color(0xFF005F46),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Material(
                              color: Colors.transparent,
                              child: RadioListTile<String>(
                                dense: true,
                                value: "Female",
                                title: Text(
                                  loc.female,
                                  style: const TextStyle(
                                    color: Color(0xFF005F46),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 15),

                    Text(
                      loc.preferredLanguage,
                      style: const TextStyle(
                        fontWeight:
                            FontWeight.w600,
                        color: Color(0xFF005F46),
                      ),
                    ),

                    const SizedBox(height: 5),

                    DropdownButtonFormField<String>(
                      key: ValueKey(language),
                      value: language,
                      decoration:
                          const InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items: [
                        DropdownMenuItem(
                          value: "English",
                          child: Text(loc.english),
                        ),
                        DropdownMenuItem(
                          value: "Hindi",
                          child: Text(loc.hindi),
                        ),
                        DropdownMenuItem(
                          value: "Assamese",
                          child: Text(loc.assamese),
                        ),
                        DropdownMenuItem(
                          value: "Bengali",
                          child: Text(loc.bengali),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            language = value;
                          });
                          // Automatically update language across the entire application immediately!
                          try {
                            context
                                .read<LanguageProvider>()
                                .setLanguageByName(value);
                          } catch (_) {
                            LanguageService.instance.saveLanguageByName(value);
                          }
                        }
                      },
                    ),

                    const SizedBox(height: 15),

                    Text(
                      loc.readingPreference,
                      style: const TextStyle(
                        fontWeight:
                            FontWeight.w600,
                        color: Color(0xFF005F46),
                      ),
                    ),

                    RadioGroup<String>(
                      groupValue: readingPreference,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            readingPreference = value;
                          });
                        }
                      },
                      child: Row(
                        children: [
                          Expanded(
                            child: Material(
                              color: Colors.transparent,
                              child: RadioListTile<String>(
                                dense: true,
                                title: Text(
                                  loc.yes,
                                  style: const TextStyle(
                                    color: Color(0xFF005F46),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                value: "Yes",
                              ),
                            ),
                          ),
                          Expanded(
                            child: Material(
                              color: Colors.transparent,
                              child: RadioListTile<String>(
                                dense: true,
                                title: Text(
                                  loc.no,
                                  style: const TextStyle(
                                    color: Color(0xFF005F46),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                value: "No",
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 15),

                    Text(
                      loc.dementiaStage,
                      style: const TextStyle(
                        fontWeight:
                            FontWeight.w600,
                        color: Color(0xFF005F46),
                      ),
                    ),

                    const SizedBox(height: 5),

                    DropdownButtonFormField<String>(
                      key: ValueKey(dementiaStage),
                      value: dementiaStage,
                      decoration:
                          const InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items: [
                        DropdownMenuItem(
                          value: "Mild",
                          child: Text(loc.mild),
                        ),
                        DropdownMenuItem(
                          value: "Moderate",
                          child: Text(loc.moderate),
                        ),
                        DropdownMenuItem(
                          value: "Severe",
                          child: Text(loc.severe),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            dementiaStage = value;
                          });
                        }
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
                              SnackBar(
                                content: Text(
                                  loc.pleaseEnterPatientName,
                                ),
                                backgroundColor: Colors.redAccent,
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
                              SnackBar(
                                content: Text(
                                  loc.pleaseSelectDob,
                                ),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                            return;
                          }

                          // Ensure language preference is saved
                          try {
                            context
                                .read<LanguageProvider>()
                                .setLanguageByName(language);
                          } catch (_) {
                            LanguageService.instance.saveLanguageByName(language);
                          }

                          // Format DOB to YYYY-MM-DD for backend API
                          final String formattedDob = selectedDob != null
                              ? "${selectedDob!.year}-${selectedDob!.month.toString().padLeft(2, '0')}-${selectedDob!.day.toString().padLeft(2, '0')}"
                              : () {
                                  final parts = dobController.text.trim().split('-');
                                  if (parts.length == 3 && parts[0].length == 4) {
                                    return dobController.text.trim();
                                  } else if (parts.length == 3) {
                                    return "${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}";
                                  }
                                  return dobController.text.trim();
                                }();

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CaregiverDetailsScreen(
                                patientName: nameController.text.trim(),
                                dob: formattedDob,
                                gender: gender,
                                languagePreference: language,
                                readingPreference:
                                    readingPreference == "Yes",
                                dementiaStage: dementiaStage,
                              ),
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

                        child: Text(
                          loc.next,
                          style: const TextStyle(
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
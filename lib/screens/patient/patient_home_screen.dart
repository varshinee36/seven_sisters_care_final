import 'package:flutter/material.dart';

import 'games_screen.dart';
import 'activites_screen.dart';
import 'patient_settings_screen.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  void _openRemindersSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.notifications_active_rounded,
                          color: Color(0xFFD6BA5F), size: 28),
                      SizedBox(width: 10),
                      Text(
                        "Today's Reminders",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF005F46),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildReminderItem(
                time: "08:00 AM",
                title: "Morning Medication & Warm Water",
                icon: Icons.medication_rounded,
                isCompleted: true,
              ),
              const SizedBox(height: 10),
              _buildReminderItem(
                time: "10:30 AM",
                title: "Gentle Garden Stroll",
                icon: Icons.nature_people_rounded,
                isCompleted: true,
              ),
              const SizedBox(height: 10),
              _buildReminderItem(
                time: "01:00 PM",
                title: "Nutritious Lunch & Fruit",
                icon: Icons.restaurant_rounded,
                isCompleted: false,
              ),
              const SizedBox(height: 10),
              _buildReminderItem(
                time: "04:30 PM",
                title: "Brain Health Memory Game",
                icon: Icons.psychology_rounded,
                isCompleted: false,
              ),
              const SizedBox(height: 10),
              _buildReminderItem(
                time: "08:00 PM",
                title: "Evening Medicine & Family Call",
                icon: Icons.nightlight_round,
                isCompleted: false,
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReminderItem({
    required String time,
    required String title,
    required IconData icon,
    required bool isCompleted,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isCompleted
            ? const Color(0xFF005F46).withValues(alpha: 0.08)
            : const Color(0xFFD6BA5F).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCompleted
              ? const Color(0xFF005F46).withValues(alpha: 0.3)
              : const Color(0xFFD6BA5F).withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          Icon(icon,
              color: isCompleted
                  ? const Color(0xFF005F46)
                  : const Color(0xFF9E7C10),
              size: 26),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isCompleted
                        ? const Color(0xFF005F46)
                        : const Color(0xFF9E7C10),
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    decoration: isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            isCompleted
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            color: isCompleted
                ? const Color(0xFF005F46)
                : const Color(0xFF9E7C10),
          ),
        ],
      ),
    );
  }

  void _openFamilySheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.diversity_3_rounded,
                          color: Color(0xFF4C9866), size: 28),
                      SizedBox(width: 10),
                      Text(
                        "My Family & Care",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF005F46),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildFamilyContact(
                name: "Rahul (Son)",
                role: "Primary Caregiver",
                phone: "+91 9876543210",
              ),
              const SizedBox(height: 10),
              _buildFamilyContact(
                name: "Priya (Daughter)",
                role: "Emergency Contact",
                phone: "+91 9876543211",
              ),
              const SizedBox(height: 10),
              _buildFamilyContact(
                name: "Dr. Borah",
                role: "Consultant Physician",
                phone: "+91 9876543212",
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFamilyContact({
    required String name,
    required String role,
    required String phone,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF4C9866).withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF4C9866).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFF4C9866),
            radius: 20,
            child: Icon(Icons.person, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  role,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.phone_rounded,
                color: Color(0xFF005F46), size: 28),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Calling $name ($phone)..."),
                  backgroundColor: const Color(0xFF005F46),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _openTalkToAssistantSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 45,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Voice Companion",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF005F46),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "I am listening. How can I assist you right now?",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 30),
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: const Color(0xFF19D3F3).withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 68,
                    height: 68,
                    decoration: const BoxDecoration(
                      color: Color(0xFF19D3F3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.mic_rounded,
                      color: Colors.white,
                      size: 38,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  _buildVoiceChip("Read today's news"),
                  _buildVoiceChip("Play soothing music"),
                  _buildVoiceChip("Check my medications"),
                  _buildVoiceChip("Call my family"),
                ],
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text("Done"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVoiceChip(String text) {
    return ActionChip(
      label: Text(text),
      backgroundColor: const Color(0xFFF0F7F4),
      side: const BorderSide(color: Color(0xFFCFEDE2)),
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Processing: \"$text\""),
            backgroundColor: const Color(0xFF005F46),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF2B2525),
      body: SafeArea(
        child: Center(
          child: Container(
            width: screenWidth > 600 ? 500 : double.infinity,
            margin: screenWidth > 600
                ? const EdgeInsets.symmetric(vertical: 20)
                : EdgeInsets.zero,
            decoration: BoxDecoration(
              color: const Color(0xFFF7FAF8),
              borderRadius: BorderRadius.circular(screenWidth > 600 ? 30 : 0),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  // Top Header: Logo + 11:30 AM / 70% Charge + Settings Icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ClipOval(
                        child: Image.asset(
                          "assets/images/logo.jpg",
                          width: 65,
                          height: 65,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const CircleAvatar(
                              radius: 32,
                              backgroundColor: Color(0xFF005F46),
                              child: Icon(Icons.favorite,
                                  color: Colors.white, size: 32),
                            );
                          },
                        ),
                      ),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "11:30 AM",
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(Icons.battery_charging_full_rounded,
                                  size: 18, color: Colors.black87),
                              SizedBox(width: 4),
                              Text(
                                "70% Charge",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings,
                            size: 32, color: Color(0xFF4A4A4A)),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PatientSettingsScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // 4 Main Feature Cards
                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        // 1. Games Card
                        _buildHomeCard(
                          title: "Games",
                          color: const Color(0xFF459B98),
                          icon: Icons.psychology_rounded,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const GamesScreen(),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 14),

                        // 2. Activities Card
                        _buildHomeCard(
                          title: "Activities",
                          color: const Color(0xFFD64D6E),
                          icon: Icons.favorite_rounded,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ActivitesScreen(),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 14),

                        // 3. Reminders Card
                        _buildHomeCard(
                          title: "Remainders",
                          color: const Color(0xFFD6BA5F),
                          icon: Icons.notifications_active_rounded,
                          onTap: _openRemindersSheet,
                        ),

                        const SizedBox(height: 14),

                        // 4. Family Card
                        _buildHomeCard(
                          title: "Family",
                          color: const Color(0xFF4C9866),
                          icon: Icons.badge_rounded,
                          onTap: _openFamilySheet,
                        ),

                        const SizedBox(height: 14),
                      ],
                    ),
                  ),

                  // Bottom Button: Talk To Assistant
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _openTalkToAssistantSheet,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF19D3F3),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.mic_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                          SizedBox(width: 10),
                          Text(
                            "Talk to Assistant",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHomeCard({
    required String title,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          width: double.infinity,
          height: 100,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Row(
                children: [
                  Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: Colors.white, size: 36),
                  ),
                  const SizedBox(width: 22),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: IconButton(
                  icon: const Icon(Icons.volume_up,
                      color: Colors.white, size: 26),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Voice guide for $title"),
                        duration: const Duration(seconds: 1),
                        backgroundColor: color,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

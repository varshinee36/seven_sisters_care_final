import 'package:flutter/material.dart';
import '../../localization/app_localizations.dart';
import 'activities/reading_activity_screen.dart';
import 'activities/family_recognition_activity_screen.dart';
import 'activities/music_activity_screen.dart';
import 'activities/daily_routine_recall_activity_screen.dart';

class ActivitesScreen extends StatefulWidget {
  const ActivitesScreen({super.key});

  @override
  State<ActivitesScreen> createState() => _ActivitesScreenState();
}

class _ActivitesScreenState extends State<ActivitesScreen> {
  void _navigateToActivity(Widget targetScreen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => targetScreen),
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
                  // Top Header: Logo + 11:30 AM + Speaker Icon
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
                      const Text(
                        "11:30 AM",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.volume_up_rounded,
                            size: 32, color: Colors.black87),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(context.loc.activitySelectVoice),
                              backgroundColor: const Color(0xFF005F46),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Title: Activities + Voice over
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          context.loc.activities,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF005F46),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.volume_up,
                            color: Colors.black87, size: 28),
                        onPressed: () {
                          // TODO: Connect voice-over audio later.
                        },
                        tooltip: context.loc.voiceOver,
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Activities List
                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        // Card 1: Reading
                        _buildActivityCard(
                          title: context.loc.reading,
                          color: const Color(0xFFD4B75B),
                          assetPath: "assets/images/reading.jpg",
                          fallbackIcon: Icons.menu_book_rounded,
                          onTap: () => _navigateToActivity(const ReadingActivityScreen()),
                        ),

                        const SizedBox(height: 16),

                        // Card 2: Family Picture
                        _buildActivityCard(
                          title: context.loc.familyPicture,
                          color: const Color(0xFF689E89),
                          assetPath: "assets/images/familypicture.jpg",
                          fallbackIcon: Icons.photo_library_rounded,
                          onTap: () => _navigateToActivity(const FamilyRecognitionActivityScreen()),
                        ),

                        const SizedBox(height: 16),

                        // Card 3: Music
                        _buildActivityCard(
                          title: context.loc.music,
                          color: const Color(0xFFD0456E),
                          assetPath: "assets/images/music.jpg",
                          fallbackIcon: Icons.music_note_rounded,
                          onTap: () => _navigateToActivity(const MusicActivityScreen()),
                        ),

                        const SizedBox(height: 16),

                        // Card 4: Daily Routine Recall
                        _buildActivityCard(
                          title: context.loc.dailyRoutineRecall,
                          color: const Color(0xFF728DF5),
                          assetPath: "assets/images/dailyroutinerecall.jpg",
                          fallbackIcon: Icons.event_repeat_rounded,
                          onTap: () => _navigateToActivity(const DailyRoutineRecallActivityScreen()),
                        ),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),

                  // Bottom Back Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF19D3F3),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Color(0xFF19D3F3),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            context.loc.back,
                            style: const TextStyle(
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

  Widget _buildActivityCard({
    required String title,
    required Color color,
    required String assetPath,
    required IconData fallbackIcon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          width: double.infinity,
          height: 110,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      assetPath,
                      width: 70,
                      height: 70,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 70,
                        height: 70,
                        color: Colors.white.withValues(alpha: 0.2),
                        child:
                            Icon(fallbackIcon, size: 40, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.15,
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: IconButton(
                  icon:
                      const Icon(Icons.volume_up, color: Colors.white, size: 26),
                  onPressed: () {
                    final scaffoldMessenger = ScaffoldMessenger.maybeOf(context);
                    if (scaffoldMessenger != null) {
                      scaffoldMessenger.clearSnackBars();
                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content: Text(
                              "${context.loc.voiceGuideFor} ${title.replaceAll('\n', ' ')}"),
                          duration: const Duration(seconds: 1),
                          backgroundColor: color,
                        ),
                      );
                    }
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

import 'package:flutter/material.dart';

class GamesPerceptualMotorScreen extends StatefulWidget {
  const GamesPerceptualMotorScreen({super.key});

  @override
  State<GamesPerceptualMotorScreen> createState() =>
      _GamesPerceptualMotorScreenState();
}

class _GamesPerceptualMotorScreenState
    extends State<GamesPerceptualMotorScreen> {
  void _openGameDialog(String title, String description, Color color) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.toys_rounded, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18)),
            ),
          ],
        ),
        content:
            Text(description, style: const TextStyle(fontSize: 15, height: 1.4)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("$title Session Started!"),
                  backgroundColor: color,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Start Playing",
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
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
                  Row(
                    children: [
                      ClipOval(
                        child: Image.asset(
                          "assets/images/logo.jpg",
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const CircleAvatar(
                              radius: 30,
                              backgroundColor: Color(0xFF005F46),
                              child: Icon(Icons.category_rounded,
                                  color: Colors.white, size: 30),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          "11:30 AM",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.volume_up,
                            color: Colors.black87, size: 28),
                        onPressed: () {
                          // TODO: Connect voice-over audio later.
                        },
                        tooltip: 'Voice over',
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF37A34),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text(
                      "Perceptual Motor",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Shape Matching
                  _buildGameCard(
                    title: "Shape\nMatching",
                    color: const Color(0xFFFB8C00),
                    assetPath: "assets/images/shapematch.jpg",
                    fallbackIcon: Icons.interests_rounded,
                    onTap: () => _openGameDialog(
                      "Shape Matching",
                      "Match geometrical and natural shapes onto outlines to enhance spatial awareness and motor agility.",
                      const Color(0xFFFB8C00),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Drag & Place
                  _buildGameCard(
                    title: "Drag &\nPlace",
                    color: const Color(0xFFF4511E),
                    assetPath: "assets/images/perceptualmotor.jpg",
                    fallbackIcon: Icons.touch_app_rounded,
                    onTap: () => _openGameDialog(
                      "Drag & Place",
                      "Practice hand-eye touch coordination by smoothly dragging items into designated baskets.",
                      const Color(0xFFF4511E),
                    ),
                  ),

                  const Spacer(),

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
                          const Text(
                            "Back",
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

  Widget _buildGameCard({
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
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          height: 110,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
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
                        child: Icon(fallbackIcon, size: 40, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 22,
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
                  icon: const Icon(Icons.volume_up, color: Colors.white, size: 26),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Voice guidance for ${title.replaceAll('\n', ' ')}"),
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

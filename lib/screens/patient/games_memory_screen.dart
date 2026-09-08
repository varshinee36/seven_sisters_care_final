import 'package:flutter/material.dart';
import '../pair_finder_tutorial.dart';

class GamesMemoryScreen extends StatefulWidget {
  const GamesMemoryScreen({super.key});

  @override
  State<GamesMemoryScreen> createState() => _GamesMemoryScreenState();
}

class _GamesMemoryScreenState extends State<GamesMemoryScreen> {
  void _openPairFinderGame() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.style_rounded, color: Color(0xFFEA247F)),
            SizedBox(width: 10),
            Text("Pair Finder", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Match identical card pairs to exercise visual working memory and cognitive recall.",
              style: TextStyle(fontSize: 15, height: 1.4),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEA247F).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text("🍎", style: TextStyle(fontSize: 36)),
                  Text("⭐", style: TextStyle(fontSize: 36)),
                  Text("🍎", style: TextStyle(fontSize: 36)),
                  Text("⭐", style: TextStyle(fontSize: 36)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PairFinderTutorial(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEA247F),
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

  void _openMemoryHuntGame() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.search_rounded, color: Color(0xFF7A97FF)),
            SizedBox(width: 10),
            Text("Memory Hunt", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Remember hidden items and find them in order across the board.",
              style: TextStyle(fontSize: 15, height: 1.4),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF7A97FF).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text("🔍", style: TextStyle(fontSize: 36)),
                  Text("🗝️", style: TextStyle(fontSize: 36)),
                  Text("📦", style: TextStyle(fontSize: 36)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Memory Hunt Game Session Started!"),
                  backgroundColor: Color(0xFF7A97FF),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7A97FF),
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
                  // Header: Logo & 11:30 AM
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
                              child: Icon(Icons.psychology,
                                  color: Colors.white, size: 30),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        "11:30 AM",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Pill Header: Memory Games
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAA252),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text(
                      "Memory Games",
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

                  // Game Card 1: Pair Finder
                  _buildGameCard(
                    title: "Pair Finder",
                    color: const Color(0xFFEA247F),
                    assetPath: "assets/images/pairfinder.jpg",
                    fallbackIcon: Icons.extension_rounded,
                    onTap: _openPairFinderGame,
                  ),

                  const SizedBox(height: 20),

                  // Game Card 2: Memory Hunt
                  _buildGameCard(
                    title: "Memory\nHunt",
                    color: const Color(0xFF7A97FF),
                    assetPath: "assets/images/memoryhunt.jpg",
                    fallbackIcon: Icons.search_rounded,
                    onTap: _openMemoryHuntGame,
                  ),

                  const Spacer(),

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
                  icon: const Icon(Icons.volume_up, color: Colors.white, size: 26),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Playing voice guidance for $title"),
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

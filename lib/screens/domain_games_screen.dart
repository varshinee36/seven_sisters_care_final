import 'package:flutter/material.dart';

import 'pair_finder_tutorial.dart';
import 'continuous_focus_tutorial.dart'; 
enum GameDomain { memory, attention, executive, perceptual }

class GameCardData {
  final String title;
  final String description;
  final String imagePath;
  final Color color;

  const GameCardData({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.color,
  });
}

class DomainGamesScreen extends StatelessWidget {
  final GameDomain domain;

  const DomainGamesScreen({super.key, required this.domain});

  String get domainTitle {
    switch (domain) {
      case GameDomain.memory:
        return 'Memory Games';
      case GameDomain.attention:
        return 'Attention Games';
      case GameDomain.executive:
        return 'Executive Games';
      case GameDomain.perceptual:
        return 'Perceptual Motor';
    }
  }

  Color get domainBannerColor {
    switch (domain) {
      case GameDomain.memory:
        return const Color(0xFFE5A158);
      case GameDomain.attention:
        return const Color(0xFF7A4FA3);
      case GameDomain.executive:
        return const Color(0xFF4A6DA7);
      case GameDomain.perceptual:
        return const Color(0xFFE08A2E);
    }
  }

  List<GameCardData> get games {
    switch (domain) {
      case GameDomain.memory:
        return const [
          GameCardData(
            title: 'Pair Finder',
            description: 'Find the matching pair',
            imagePath: 'assets/images/pairfinder.jpg',
            color: Color(0xFFF72585),
          ),
          GameCardData(
            title: 'Memory\nHunt',
            description: 'Remember and find the correct picture',
            imagePath: 'assets/images/memoryhunt.jpg',
            color: Color(0xFF7096FA),
          ),
        ];

      case GameDomain.attention:
        return const [
          GameCardData(
            title: 'Continuous\nFocus',
            description: 'Stay focused and find the target',
            imagePath: 'assets/images/attention.jpg',
            color: Color(0xFF7A4FA3),
          ),
          GameCardData(
            title: 'Find\nDifference',
            description: 'Find what is different',
            imagePath: 'assets/images/finddifference.jpg',
            color: Color(0xFFE96A67),
          ),
        ];

      case GameDomain.executive:
        return const [
          GameCardData(
            title: 'Smart\nChoice',
            description: 'Choose the best option',
            imagePath: 'assets/images/smartchoice.jpg',
            color: Color(0xFF356B9C),
          ),
          GameCardData(
            title: 'Smart\nSort',
            description: 'Arrange things in the correct order',
            imagePath: 'assets/images/smartsort.jpg',
            color: Color(0xFF4A6DA7),
          ),
        ];

      case GameDomain.perceptual:
        return const [
          GameCardData(
            title: 'Shape\nMatch',
            description: 'Match shapes correctly',
            imagePath: 'assets/images/shapematch.jpg',
            color: Color(0xFFE08A2E),
          ),
          GameCardData(
            title: 'Missing\nPiece',
            description: 'Find the missing part',
            imagePath: 'assets/images/missingchoice.jpg',
            color: Color(0xFFE85D56),
          ),
        ];
    }
  }

  String _getTimeString() {
    final now = TimeOfDay.now();
    final hour = now.hourOfPeriod == 0 ? 12 : now.hourOfPeriod;
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              // ==========================================
              // TOP HEADER (Logo + Time)
              // ==========================================
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/logo.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                              Icons.spa_rounded,
                              size: 40,
                              color: Color(0xFF2E7D5B),
                            ),
                      ),
                    ),
                  ),

                  Expanded(
                    child: Center(
                      child: Text(
                        _getTimeString(),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 58), // Balancing spacer
                ],
              ),

              const SizedBox(height: 20),

              // ==========================================
              // TITLE PILL / BANNER (e.g. "Memory Games")
              // ==========================================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: domainBannerColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: domainBannerColor.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    domainTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // ==========================================
              // GAME CARDS LIST
              // ==========================================
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  itemCount: games.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 18),
                  itemBuilder: (context, index) {
                    final game = games[index];
                    return _gameCard(context, game);
                  },
                ),
              ),

              // ==========================================
              // BOTTOM BACK BUTTON (Cyan pill)
              // ==========================================
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                child: SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: Material(
                    color: const Color(0xFF1BE5F2),
                    borderRadius: BorderRadius.circular(29),
                    elevation: 2,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(29),
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_back_rounded,
                                color: Color(0xFF1BE5F2),
                                size: 26,
                              ),
                            ),
                            const Expanded(
                              child: Center(
                                child: Text(
                                  'Back',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 42), // Balancing spacer
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _gameCard(BuildContext context, GameCardData game) {
    return Container(
      constraints: const BoxConstraints(minHeight: 110),
      child: Material(
        color: game.color,
        borderRadius: BorderRadius.circular(22),
        elevation: 3,
        shadowColor: game.color.withValues(alpha: 0.35),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
                    onTap: () {
            final cleanTitle = game.title.replaceAll('\n', ' ');

            if (cleanTitle == 'Pair Finder') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PairFinderTutorial(),
                ),
              );
            } else if (cleanTitle == 'Continuous Focus') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ContinuousFocusTutorial(),
                ),
              );
            } else {
              _openGameMessage(context, cleanTitle);
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Stack(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Illustration image
                    Container(
                      width: 70,
                      height: 70,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Image.asset(
                        game.imagePath,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                              Icons.extension_rounded,
                              color: Colors.white,
                              size: 40,
                            ),
                      ),
                    ),

                    const SizedBox(width: 20),

                    // Game Title
                    Expanded(
                      child: Text(
                        game.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          height: 1.15,
                        ),
                      ),
                    ),

                    // Spacing for speaker icon
                    const SizedBox(width: 36),
                  ],
                ),

                // Speaker Icon in bottom-right corner
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(
                      Icons.volume_up_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: () {
                      final cleanTitle = game.title.replaceAll('\n', ' ');
                      ScaffoldMessenger.of(context).removeCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            cleanTitle,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          duration: const Duration(seconds: 1),
                          backgroundColor: game.color,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openGameMessage(BuildContext context, String gameName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: Text(
            gameName,
            style: TextStyle(
              color: domainBannerColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'This game screen will be added next.',
            style: TextStyle(fontSize: 18),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'OK',
                style: TextStyle(
                  color: domainBannerColor,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

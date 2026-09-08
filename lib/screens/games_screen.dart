import 'package:flutter/material.dart';

import 'domain_games_screen.dart';

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

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
              // TOP HEADER (Logo + Time + Games Title)
              // ==========================================
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // App Logo
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          _getTimeString(),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Games',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Balancing spacer for the logo
                  const SizedBox(width: 58),
                ],
              ),

              const SizedBox(height: 18),

              // ==========================================
              // DOMAIN CARDS LIST
              // ==========================================
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  children: [
                    _domainCard(
                      context: context,
                      title: 'Memory',
                      imagePath: 'assets/images/memory.jpg',
                      color: const Color(0xFFE85D56),
                      domain: GameDomain.memory,
                    ),
                    const SizedBox(height: 14),

                    _domainCard(
                      context: context,
                      title: 'Attention',
                      imagePath: 'assets/images/attention.jpg',
                      color: const Color(0xFF7A4FA3),
                      domain: GameDomain.attention,
                    ),
                    const SizedBox(height: 14),

                    _domainCard(
                      context: context,
                      title: 'Executive\nPlanning',
                      imagePath: 'assets/images/executiveplanning.jpg',
                      color: const Color(0xFF4A6DA7),
                      domain: GameDomain.executive,
                    ),
                    const SizedBox(height: 14),

                    _domainCard(
                      context: context,
                      title: 'Perceptual\nMotor',
                      imagePath: 'assets/images/perceptualmotor.jpg',
                      color: const Color(0xFFF27B2B),
                      domain: GameDomain.perceptual,
                    ),
                    const SizedBox(height: 14),
                  ],
                ),
              ),

              // ==========================================
              // BOTTOM BACK BUTTON
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
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
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

  Widget _domainCard({
    required BuildContext context,
    required String title,
    required String imagePath,
    required Color color,
    required GameDomain domain,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 104),
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(22),
        elevation: 3,
        shadowColor: color.withValues(alpha: 0.35),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DomainGamesScreen(domain: domain),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Stack(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Illustration image
                    Container(
                      width: 68,
                      height: 68,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Image.asset(
                        imagePath,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                              Icons.extension_rounded,
                              color: Colors.white,
                              size: 40,
                            ),
                      ),
                    ),

                    const SizedBox(width: 18),

                    // Title
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          height: 1.15,
                        ),
                      ),
                    ),

                    // Space for speaker icon in bottom right
                    const SizedBox(width: 36),
                  ],
                ),

                // Speaker Icon at bottom-right
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
                      ScaffoldMessenger.of(context).removeCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            title.replaceAll('\n', ' '),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
      ),
    );
  }
}

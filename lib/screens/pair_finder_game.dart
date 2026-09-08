import 'dart:async';
import 'dart:math';

import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/material.dart';

/// Level configuration:
/// Level 1 = 2 pairs / 4 cards (responsive 2x2 grid)
/// Level 2 = 3 pairs / 6 cards (responsive 2x3 grid)
/// Per specification: NEVER create 4 pairs.
enum GameLevel { level1, level2 }

enum PerformanceCategory { excellent, good, average, poor }

class ScoreBreakdown {
  final double accuracyScore; // 0..100
  final double hintsScore; // 0..100
  final double timeScore; // 0..100
  final double completionScore; // 0..100
  final int totalScore; // 0..100
  final PerformanceCategory category;
  final String advice;
  final GameLevel nextLevel;

  const ScoreBreakdown({
    required this.accuracyScore,
    required this.hintsScore,
    required this.timeScore,
    required this.completionScore,
    required this.totalScore,
    required this.category,
    required this.advice,
    required this.nextLevel,
  });
}

class LocalFoodItem {
  final int id;
  final String name;
  final String imagePath;
  final Color themeColor;

  const LocalFoodItem({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.themeColor,
  });
}

class MemoryCard {
  final int id;
  final String name;
  final String imagePath;
  final Color themeColor;
  bool revealed;
  bool matched;

  MemoryCard({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.themeColor,
    this.revealed = false,
    this.matched = false,
  });
}

class PairFinderGame extends StatefulWidget {
  final GameLevel initialLevel;

  const PairFinderGame({super.key, this.initialLevel = GameLevel.level1});

  @override
  State<PairFinderGame> createState() => _PairFinderGameState();
}

class _PairFinderGameState extends State<PairFinderGame> {
  final Random _random = Random();

  // ============================================================
  // PALETTE & STYLING
  // ============================================================
  static const Color forestGreen = Color(0xFF2E7D5B);
  static const Color deepGreen = Color(0xFF1D5038);
  static const Color lightCream = Color(0xFFF7FAF8);
  static const Color amberGold = Color(0xFFF9A825);
  static const Color darkText = Color(0xFF26382E);
  static const Color coralRed = Color(0xFFE96A67);
  static const Color magentaPink = Color(0xFFF72585);
  static const Color timerBrown = Color(0xFF5D4037);

  // Authentic local items from Northeast India
  static const List<LocalFoodItem> _foodPool = [
    LocalFoodItem(
      id: 1,
      name: 'Dried Fish',
      imagePath: 'assets/images/pair_finder/dried_fish.png',
      themeColor: Color(0xFFD96550),
    ),
    LocalFoodItem(
      id: 2,
      name: 'Fermented Soybean',
      imagePath: 'assets/images/pair_finder/fermented_soybean.png',
      themeColor: Color(0xFF8D6E63),
    ),
    LocalFoodItem(
      id: 3,
      name: 'Bamboo Shoot',
      imagePath: 'assets/images/pair_finder/bamboo_shoot.png',
      themeColor: Color(0xFF2E7D5B),
    ),
    LocalFoodItem(
      id: 4,
      name: 'Banana Leaf',
      imagePath: 'assets/images/pair_finder/banana_leaf.png',
      themeColor: Color(0xFF388E3C),
    ),
    LocalFoodItem(
      id: 5,
      name: 'Tea',
      imagePath: 'assets/images/pair_finder/tea.png',
      themeColor: Color(0xFFB06434),
    ),
  ];

  // ============================================================
  // GAME STATE
  // ============================================================
  late GameLevel _currentLevel;
  late List<MemoryCard> _cards;

  int? _firstSelectedIndex;
  int? _secondSelectedIndex;

  bool _checking = false;
  bool _gameFinished = false;
  bool _hintInProgress = false;
  bool _showHintBanner = false;
  String _hintMessage = '';

  // Tracked metrics
  int _attempts = 0;
  int _wrongAttempts = 0; // Max 3 wrong attempts triggers end of game
  int _hintsUsed = 0;
  int _matches = 0;
  int _score = 0;
  int _seconds = 0;

  Timer? _timer;
  ScoreBreakdown? _lastScoreBreakdown;

  // Battery monitoring
  final Battery _battery = Battery();
  int? _batteryLevel;
  Timer? _batteryTimer;

  int get _pairCount => _currentLevel == GameLevel.level1 ? 2 : 3;
  static const int _maxWrongAttempts = 3;

  @override
  void initState() {
    super.initState();
    _currentLevel = widget.initialLevel;
    _startNewGame(level: _currentLevel);
    _initBattery();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _batteryTimer?.cancel();
    super.dispose();
  }

  // ============================================================
  // BATTERY MONITORING
  // ============================================================
  Future<void> _initBattery() async {
    try {
      final level = await _battery.batteryLevel;
      if (mounted) {
        setState(() {
          _batteryLevel = level;
        });
      }
    } catch (_) {}

    _batteryTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      try {
        final level = await _battery.batteryLevel;
        if (mounted) {
          setState(() {
            _batteryLevel = level;
          });
        }
      } catch (_) {}
    });
  }

  // ============================================================
  // GAME SETUP
  // ============================================================
  void _startNewGame({GameLevel? level}) {
    _timer?.cancel();

    if (level != null) {
      _currentLevel = level;
    }

    // Pick _pairCount items randomly from the 5 local foods
    final shuffledPool = List<LocalFoodItem>.from(_foodPool)..shuffle(_random);
    final selectedItems = shuffledPool.take(_pairCount).toList();

    // Create 2 cards for each selected food
    _cards = [];
    for (final item in selectedItems) {
      _cards.add(
        MemoryCard(
          id: item.id,
          name: item.name,
          imagePath: item.imagePath,
          themeColor: item.themeColor,
        ),
      );
      _cards.add(
        MemoryCard(
          id: item.id,
          name: item.name,
          imagePath: item.imagePath,
          themeColor: item.themeColor,
        ),
      );
    }
    _cards.shuffle(_random);

    // Reset interactions and counters
    _firstSelectedIndex = null;
    _secondSelectedIndex = null;
    _checking = false;
    _gameFinished = false;
    _hintInProgress = false;
    _showHintBanner = false;
    _hintMessage = '';

    _attempts = 0;
    _wrongAttempts = 0;
    _hintsUsed = 0;
    _matches = 0;
    _score = 0;
    _seconds = 0;
    _lastScoreBreakdown = null;

    _startTimer();

    if (mounted) {
      setState(() {});
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _gameFinished) {
        timer.cancel();
        return;
      }
      setState(() {
        _seconds++;
      });
    });
  }

  String _formatTime(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String _getTimeString() {
    final now = TimeOfDay.now();
    final hour = now.hourOfPeriod == 0 ? 12 : now.hourOfPeriod;
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  // ============================================================
  // RULE-BASED WEIGHTED SCORING
  // ============================================================
  ScoreBreakdown _calculateScore() {
    // 1. Accuracy (50%)
    final double accuracyRatio =
        ((_maxWrongAttempts - _wrongAttempts) / _maxWrongAttempts).clamp(
          0.0,
          1.0,
        );
    final double accuracyScore = accuracyRatio * 100.0;

    // 2. Hints (20%)
    final double hintsRatio = (1.0 - (_hintsUsed * 0.35)).clamp(0.0, 1.0);
    final double hintsScore = hintsRatio * 100.0;

    // 3. Time (20%)
    final int targetSeconds = _currentLevel == GameLevel.level1 ? 25 : 40;
    double timeRatio;
    if (_seconds <= targetSeconds) {
      timeRatio = 1.0;
    } else {
      timeRatio =
          (1.0 - ((_seconds - targetSeconds) / (targetSeconds * 1.5))).clamp(
            0.0,
            1.0,
          );
    }
    final double timeScore = timeRatio * 100.0;

    // 4. Completion (10%)
    final double completionRatio = (_matches / _pairCount).clamp(0.0, 1.0);
    final double completionScore = completionRatio * 100.0;

    // Weighted sum
    final int total =
        ((accuracyScore * 0.50) +
                (hintsScore * 0.20) +
                (timeScore * 0.20) +
                (completionScore * 0.10))
            .round()
            .clamp(0, 100);

    // Performance category
    PerformanceCategory category;
    if (total >= 80) {
      category = PerformanceCategory.excellent;
    } else if (total >= 65) {
      category = PerformanceCategory.good;
    } else if (total >= 50) {
      category = PerformanceCategory.average;
    } else {
      category = PerformanceCategory.poor;
    }

    // Adaptive difficulty decision (STRICTLY NEVER CREATE 4 PAIRS)
    GameLevel nextLevel;
    String advice;

    switch (category) {
      case PerformanceCategory.excellent:
        if (_currentLevel == GameLevel.level1) {
          nextLevel = GameLevel.level2;
          advice =
              'Outstanding memory and focus! You are ready for Level 2 (3 pairs).';
        } else {
          nextLevel = GameLevel.level2; // Keep at level 2 (NEVER 4 pairs)
          advice =
              'Masterful performance! You have mastered Level 2 with high precision.';
        }
        break;

      case PerformanceCategory.good:
        if (_currentLevel == GameLevel.level1) {
          nextLevel = GameLevel.level2;
          advice =
              'Great work! Moving up to Level 2 (3 pairs) to strengthen your recall.';
        } else {
          nextLevel = GameLevel.level2; // Keep at level 2
          advice =
              'Solid game! Take a moment to scan the cards before each turn.';
        }
        break;

      case PerformanceCategory.average:
        nextLevel = _currentLevel; // Stay at same level
        advice =
            'Good effort! Playing at this level again will help build your recall speed.';
        break;

      case PerformanceCategory.poor:
        nextLevel = GameLevel.level1; // Reset to 2 pairs
        advice =
            'No worries! Taking your time with 2 pairs will help rebuild confidence.';
        break;
    }

    return ScoreBreakdown(
      accuracyScore: accuracyScore,
      hintsScore: hintsScore,
      timeScore: timeScore,
      completionScore: completionScore,
      totalScore: total,
      category: category,
      advice: advice,
      nextLevel: nextLevel,
    );
  }

  // ============================================================
  // CARD TAP & GAMEPLAY
  // ============================================================
  Future<void> _handleCardTap(int index) async {
    if (_checking || _gameFinished || _hintInProgress) {
      return;
    }

    final tappedCard = _cards[index];

    if (tappedCard.revealed || tappedCard.matched) {
      return;
    }

    if (_firstSelectedIndex == index) {
      return;
    }

    // --- FIRST CARD SELECTION ---
    if (_firstSelectedIndex == null) {
      setState(() {
        _firstSelectedIndex = index;
        tappedCard.revealed = true;
      });
      return;
    }

    // --- SECOND CARD SELECTION ---
    setState(() {
      _secondSelectedIndex = index;
      tappedCard.revealed = true;
      _checking = true;
      _attempts++;
    });

    await Future.delayed(const Duration(milliseconds: 750));
    if (!mounted) return;

    final firstCard = _cards[_firstSelectedIndex!];
    final secondCard = _cards[_secondSelectedIndex!];

    // Match found
    if (firstCard.id == secondCard.id) {
      setState(() {
        firstCard.matched = true;
        secondCard.matched = true;
        firstCard.revealed = true;
        secondCard.revealed = true;
        _matches++;
        _score = _calculateScore().totalScore;
      });

      if (_matches == _pairCount) {
        _timer?.cancel();
        final breakdown = _calculateScore();

        setState(() {
          _score = breakdown.totalScore;
          _lastScoreBreakdown = breakdown;
          _gameFinished = true;
          _firstSelectedIndex = null;
          _secondSelectedIndex = null;
          _checking = false;
        });

        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          _showResultDialog(outOfAttempts: false);
        }
        return;
      }
    }
    // Mismatch (Wrong Attempt)
    else {
      _wrongAttempts++;

      setState(() {
        firstCard.revealed = false;
        secondCard.revealed = false;
      });

      if (_wrongAttempts >= _maxWrongAttempts) {
        await _endGameOnMaxWrongAttempts();
        return;
      } else {
        _hintsUsed++;
        _triggerHint();
      }
    }

    if (mounted) {
      setState(() {
        _firstSelectedIndex = null;
        _secondSelectedIndex = null;
        _checking = false;
      });
    }
  }

  // ============================================================
  // HINT TRIGGER
  // ============================================================
  Future<void> _triggerHint() async {
    if (!mounted || _gameFinished) return;

    setState(() {
      _hintInProgress = true;
      _showHintBanner = true;
      _hintMessage =
          'Hint #$_hintsUsed: Cards will briefly reveal to guide your memory!';
    });

    await Future.delayed(const Duration(milliseconds: 250));
    if (!mounted || _gameFinished) return;

    setState(() {
      for (final card in _cards) {
        if (!card.matched) {
          card.revealed = true;
        }
      }
    });

    await Future.delayed(const Duration(milliseconds: 1300));
    if (!mounted || _gameFinished) return;

    setState(() {
      for (final card in _cards) {
        if (!card.matched) {
          card.revealed = false;
        }
      }
      _hintInProgress = false;
    });

    await Future.delayed(const Duration(milliseconds: 2000));
    if (mounted && !_hintInProgress) {
      setState(() {
        _showHintBanner = false;
      });
    }
  }

  // ============================================================
  // END GAME ON 3 WRONG ATTEMPTS
  // ============================================================
  Future<void> _endGameOnMaxWrongAttempts() async {
    _timer?.cancel();

    setState(() {
      for (final card in _cards) {
        card.revealed = true;
      }
      _gameFinished = true;
      _firstSelectedIndex = null;
      _secondSelectedIndex = null;
      _checking = false;
      _hintInProgress = false;
      _showHintBanner = false;
    });

    final breakdown = _calculateScore();
    _score = breakdown.totalScore;
    _lastScoreBreakdown = breakdown;

    await Future.delayed(const Duration(milliseconds: 1100));
    if (mounted) {
      _showResultDialog(outOfAttempts: true);
    }
  }

  // ============================================================
  // RESULT DIALOG
  // ============================================================
  void _showResultDialog({required bool outOfAttempts}) {
    final breakdown = _lastScoreBreakdown ?? _calculateScore();

    Color badgeColor;
    String categoryName;
    IconData categoryIcon;

    switch (breakdown.category) {
      case PerformanceCategory.excellent:
        badgeColor = const Color(0xFF2E7D5B);
        categoryName = 'Excellent';
        categoryIcon = Icons.emoji_events_rounded;
        break;
      case PerformanceCategory.good:
        badgeColor = const Color(0xFF356B9C);
        categoryName = 'Good';
        categoryIcon = Icons.thumb_up_rounded;
        break;
      case PerformanceCategory.average:
        badgeColor = const Color(0xFFEAA252);
        categoryName = 'Average';
        categoryIcon = Icons.auto_awesome_rounded;
        break;
      case PerformanceCategory.poor:
        badgeColor = const Color(0xFFD96550);
        categoryName = 'Needs Practice';
        categoryIcon = Icons.refresh_rounded;
        break;
    }

    final isNextLevelHigher =
        breakdown.nextLevel == GameLevel.level2 &&
        _currentLevel == GameLevel.level1;
    final nextLevelTitle =
        breakdown.nextLevel == GameLevel.level1
            ? 'Level 1 (2 Pairs / 4 Cards)'
            : 'Level 2 (3 Pairs / 6 Cards)';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 20,
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: badgeColor, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: badgeColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(categoryIcon, color: badgeColor, size: 44),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    outOfAttempts
                        ? 'Round Ended (3 Wrong)'
                        : (breakdown.totalScore >= 65
                            ? 'Great Job!'
                            : 'Round Complete'),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: outOfAttempts ? coralRed : deepGreen,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$categoryName • Score: ${breakdown.totalScore} / 100',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: lightCream,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE0EAE2)),
                    ),
                    child: Column(
                      children: [
                        _metricRow(
                          icon: Icons.star_rounded,
                          label: 'Total Score',
                          value: '${breakdown.totalScore} / 100',
                          color: forestGreen,
                        ),
                        const Divider(height: 12, thickness: 0.8),
                        _metricRow(
                          icon: Icons.touch_app_rounded,
                          label: 'Total Attempts',
                          value: '$_attempts',
                        ),
                        const Divider(height: 12, thickness: 0.8),
                        _metricRow(
                          icon: Icons.error_outline_rounded,
                          label: 'Wrong Attempts',
                          value: '$_wrongAttempts / $_maxWrongAttempts',
                          color: _wrongAttempts >= 3 ? coralRed : null,
                        ),
                        const Divider(height: 12, thickness: 0.8),
                        _metricRow(
                          icon: Icons.lightbulb_rounded,
                          label: 'Hints Used',
                          value: '$_hintsUsed',
                        ),
                        const Divider(height: 12, thickness: 0.8),
                        _metricRow(
                          icon: Icons.timer_rounded,
                          label: 'Time Elapsed',
                          value: _formatTime(_seconds),
                        ),
                        const Divider(height: 12, thickness: 0.8),
                        _metricRow(
                          icon: Icons.check_circle_rounded,
                          label: 'Pairs Matched',
                          value: '$_matches / $_pairCount',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: badgeColor.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: badgeColor.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline_rounded,
                          color: badgeColor,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Improvement Advice',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: badgeColor,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                breakdown.advice,
                                style: const TextStyle(
                                  fontSize: 13,
                                  height: 1.3,
                                  color: darkText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F3EE),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFB3D4C4)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isNextLevelHigher
                              ? Icons.trending_up_rounded
                              : Icons.navigation_rounded,
                          color: forestGreen,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Adaptive Difficulty Adjustment',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF557062),
                                ),
                              ),
                              Text(
                                'Next: $nextLevelTitle',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: deepGreen,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        _startNewGame(level: breakdown.nextLevel);
                      },
                      icon: Icon(
                        isNextLevelHigher
                            ? Icons.arrow_forward_rounded
                            : Icons.replay_rounded,
                        size: 24,
                      ),
                      label: Text(
                        isNextLevelHigher
                            ? 'Start Next Level'
                            : 'Play Level Again',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: forestGreen,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: forestGreen,
                        side: const BorderSide(color: forestGreen, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Back to Games',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _metricRow({
    required IconData icon,
    required String label,
    required String value,
    Color? color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color ?? forestGreen),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, color: Color(0xFF555555)),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: color ?? deepGreen,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // MAIN BUILD
  // ============================================================
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    final levelSubtext =
        _currentLevel == GameLevel.level1
            ? 'Level 1 • 4 Cards'
            : 'Level 2 • 6 Cards';

    return Scaffold(
      body: Stack(
        children: [
          // ============================================================
          // BACKGROUND IMAGE (background.jpg)
          // ============================================================
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Container(color: const Color(0xFFF7FAF8)),
            ),
          ),

          // Translucent white wash to match pair finder mockup readability
          Positioned.fill(
            child: Container(
              color: Colors.white.withValues(alpha: 0.88),
            ),
          ),

          // Safe area game content
          SafeArea(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 500),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  children: [
                    // ==========================================
                    // TOP BAR: Logo + 11:30 AM + Speaker Icon
                    // ==========================================
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // App Logo with pop navigation option
                        GestureDetector(
                          onTap: () {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                          },
                          child: Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.10),
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
                        ),

                        // Center Digital Time
                        Text(
                          _getTimeString(),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            letterSpacing: 0.5,
                          ),
                        ),

                        // Audio/Speaker Prompt
                        IconButton(
                          icon: const Icon(
                            Icons.volume_up_rounded,
                            color: Colors.black,
                            size: 32,
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).removeCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Find the matching pairs!',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                duration: Duration(seconds: 2),
                                backgroundColor: magentaPink,
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // ==========================================
                    // PAIR FINDER PINK BADGE + LEVEL INDICATOR
                    // ==========================================
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: magentaPink,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: magentaPink.withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'Pair Finder',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Level & Card Count subtitle (preserves test expectations)
                    Text(
                      levelSubtext,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black.withValues(alpha: 0.55),
                      ),
                    ),

                    if (_showHintBanner) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: amberGold.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: amberGold, width: 1.5),
                        ),
                        child: Text(
                          _hintMessage,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: darkText,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],

                    const SizedBox(height: 12),

                    // ==========================================
                    // RESPONSIVE CARD GRID
                    // ==========================================
                    Expanded(
                      child: _buildCardGrid(isTablet),
                    ),

                    const SizedBox(height: 12),

                    // ==========================================
                    // TIMER SECTION (brown stopwatch + Timer : XX)
                    // ==========================================
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: timerBrown, width: 3.5),
                          ),
                          child: Center(
                            child: Container(
                              width: 3.5,
                              height: 14,
                              decoration: BoxDecoration(
                                color: timerBrown,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Timer : $_seconds',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // ==========================================
                    // BOTTOM CONTROLS (Hint + Speaker buttons)
                    // ==========================================
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Hint Pill Button
                        Material(
                          color: amberGold,
                          borderRadius: BorderRadius.circular(12),
                          elevation: 2,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: _triggerHint,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 26,
                                vertical: 12,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(
                                    Icons.lightbulb_outline_rounded,
                                    color: Colors.white,
                                    size: 26,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Hint',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 16),

                        // Speaker Square Button
                        Material(
                          color: amberGold,
                          borderRadius: BorderRadius.circular(12),
                          elevation: 2,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              ScaffoldMessenger.of(context).removeCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Match 2 cards of the same picture!',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  duration: Duration(seconds: 2),
                                  backgroundColor: amberGold,
                                ),
                              );
                            },
                            child: Container(
                              width: 52,
                              height: 52,
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.volume_up_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // RESPONSIVE CARD GRID
  // Level 1: 2x2 grid (4 cards)
  // Level 2: 2x3 grid (6 cards)
  // ============================================================
  Widget _buildCardGrid(bool isTablet) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const double spacing = 16.0;
        final int crossAxisCount = 2; // 2 columns for 2x2 or 2x3
        final int itemCount = _cards.length; // 4 or 6 cards
        final int rows = (itemCount / crossAxisCount).ceil(); // 2 or 3 rows

        final double availableWidth =
            constraints.maxWidth - (spacing * (crossAxisCount - 1));
        final double cardWidth = availableWidth / crossAxisCount;

        final double availableHeight =
            constraints.maxHeight - (spacing * (rows - 1));
        final double cardHeight = availableHeight / rows;

        final double childAspectRatio =
            (cardHeight > 0) ? (cardWidth / cardHeight) : 1.0;

        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: itemCount,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: childAspectRatio,
          ),
          itemBuilder: (context, index) {
            return _buildMemoryCard(index, _cards[index]);
          },
        );
      },
    );
  }

  // ============================================================
  // MEMORY CARD WIDGET
  // ============================================================
  Widget _buildMemoryCard(int index, MemoryCard card) {
    final bool isFaceUp = card.revealed || card.matched;

    return GestureDetector(
      onTap: () => _handleCardTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isFaceUp ? Colors.white : const Color(0xFFE2E4E2),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isFaceUp
                ? (card.matched ? forestGreen : magentaPink)
                : const Color(0xFFCACFCB),
            width: 3.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: LayoutBuilder(
            builder: (context, cardBox) {
              if (isFaceUp) {
                return _buildRevealedCardFace(card, cardBox);
              } else {
                return _buildCardBack(cardBox);
              }
            },
          ),
        ),
      ),
    );
  }

  // Card Back: Landscape illustration matching pair finder.png
  Widget _buildCardBack(BoxConstraints constraints) {
    return Stack(
      children: [
        // Landscape image (background.jpg)
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/images/background.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFFD3DDD5),
                  child: const Icon(
                    Icons.landscape_rounded,
                    color: Color(0xFF8B9E90),
                    size: 36,
                  ),
                ),
              ),
            ),
          ),
        ),

        // Accessible text overlay for elderly readability and test assertions
        Positioned(
          bottom: 8,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Tap to Flip',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Card Face: Revealed local Northeast item image + name
  Widget _buildRevealedCardFace(MemoryCard card, BoxConstraints constraints) {
    final double maxHeight = constraints.maxHeight;
    final bool isCompact = maxHeight < 145;

    final double imgSize = isCompact ? 52 : (maxHeight * 0.44).clamp(58, 105);
    final double fontSize = isCompact ? 12 : 15;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 6,
        vertical: isCompact ? 4 : 8,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Food Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              card.imagePath,
              width: imgSize,
              height: imgSize,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: imgSize,
                  height: imgSize,
                  color: card.themeColor.withValues(alpha: 0.15),
                  child: Icon(
                    Icons.restaurant_rounded,
                    color: card.themeColor,
                    size: imgSize * 0.6,
                  ),
                );
              },
            ),
          ),

          SizedBox(height: isCompact ? 3 : 6),

          // Food Name
          Text(
            card.name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: card.themeColor,
            ),
          ),

          // Matched Indicator
          if (card.matched) ...[
            SizedBox(height: isCompact ? 2 : 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.check_circle_rounded,
                  color: forestGreen,
                  size: 16,
                ),
                SizedBox(width: 4),
                Text(
                  'Matched',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: forestGreen,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../models/cognitive_game_performance.dart';
import '../services/cognitive_adaptive_engine.dart';
import 'patient/games_memory_screen.dart';
import 'patient/memory_hunt_feedback_dialog.dart';

enum GameLevel {
  level1(1),
  level2(2),
  level3(3),
  level4(4),
  level5(5),
  level6(6),
  level7(7);

  final int levelNumber;
  const GameLevel(this.levelNumber);
}

class PairFinderRoundResult {
  final int level;
  final double score;
  final String performance;
  final DateTime timestamp;
  final String action;
  final bool exhausted;

  const PairFinderRoundResult({
    required this.level,
    required this.score,
    required this.performance,
    required this.timestamp,
    required this.action,
    required this.exhausted,
  });
}

class PairFinderPerformanceStore {
  static final ValueNotifier<List<PairFinderRoundResult>> results =
      ValueNotifier<List<PairFinderRoundResult>>(<PairFinderRoundResult>[]);

  static void add(PairFinderRoundResult result) {
    results.value = [...results.value, result];
  }
}

enum _QAction { increase, maintain, decrease }

class _PairFinderQLearning {
  static const double _alpha = 0.2;
  static const double _gamma = 0.4;
  static const double _epsilon = 0.08;
  final Random _random = Random();
  final Map<String, Map<_QAction, double>> _qValues = {};
  _QAction? _pendingAction;
  String? _pendingState;

  Map<_QAction, double> _valuesFor(String state) {
    return _qValues.putIfAbsent(state, () {
      final bucket = state.split('|').last;
      if (bucket == 'good') {
        return {
          _QAction.increase: 0.5,
          _QAction.maintain: 0.2,
          _QAction.decrease: -0.3,
        };
      }
      if (bucket == 'poor') {
        return {
          _QAction.decrease: 0.5,
          _QAction.maintain: 0.1,
          _QAction.increase: -0.4,
        };
      }
      return {
        _QAction.maintain: 0.3,
        _QAction.increase: 0.05,
        _QAction.decrease: 0.05,
      };
    });
  }

  _QAction choose(String state) {
    final values = _valuesFor(state);
    if (_random.nextDouble() < _epsilon) {
      final actions = _QAction.values.toList()..shuffle(_random);
      return actions.first;
    }
    var selected = _QAction.maintain;
    var best = values[selected]!;
    for (final action in _QAction.values) {
      final value = values[action]!;
      if (value > best || (value == best && action == _QAction.maintain)) {
        selected = action;
        best = value;
      }
    }
    return selected;
  }

  String completeRound({
    required int level,
    required int targetSeconds,
    required double score,
  }) {
    final state = '$level|${_bucket(score)}';
    if (_pendingAction != null && _pendingState != null) {
      final previous = _valuesFor(_pendingState!);
      final reward = _reward(_bucket(score));
      final oldValue = previous[_pendingAction!]!;
      final nextBest = previous.values.reduce(max);
      previous[_pendingAction!] =
          oldValue + _alpha * (reward + _gamma * nextBest - oldValue);
    }
    final action = choose(state);
    _pendingAction = action;
    _pendingState = state;
    return action.name;
  }

  String _bucket(double score) {
    if (score >= 0.7) return 'good';
    if (score >= 0.4) return 'average';
    return 'poor';
  }

  double _reward(String bucket) {
    if (bucket == 'good') return 1.0;
    if (bucket == 'average') return 0.4;
    return -0.6;
  }

  int nextLevel(int level, String action) {
    if (action == _QAction.increase.name) return min(7, level + 1);
    if (action == _QAction.decrease.name) return max(1, level - 1);
    return level;
  }

  int nextTarget(int targetSeconds, String action) {
    if (action == _QAction.increase.name) return max(20, targetSeconds - 6);
    if (action == _QAction.decrease.name) return min(90, targetSeconds + 8);
    return targetSeconds;
  }
}

class LocalFoodItem {
  final int id;
  final String name;
  final String imagePath;
  final String? fallbackImagePath;
  final Color themeColor;

  const LocalFoodItem({
    required this.id,
    required this.name,
    required this.imagePath,
    this.fallbackImagePath,
    required this.themeColor,
  });
}

class _PulsingHintCard extends StatefulWidget {
  final Widget child;
  final bool isBlinking;

  const _PulsingHintCard({
    required this.child,
    required this.isBlinking,
  });

  @override
  State<_PulsingHintCard> createState() => _PulsingHintCardState();
}

class _PulsingHintCardState extends State<_PulsingHintCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _animation = Tween<double>(begin: 0.25, end: 0.90).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.isBlinking) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _PulsingHintCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isBlinking != oldWidget.isBlinking) {
      if (widget.isBlinking) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isBlinking) {
      return widget.child;
    }
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFB82E).withValues(alpha: _animation.value),
                blurRadius: 14,
                spreadRadius: 3.5,
              ),
            ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class MemoryCard {
  final int id;
  final String name;
  final String imagePath;
  final String? fallbackImagePath;
  final Color themeColor;
  bool revealed;
  bool matched;

  MemoryCard({
    required this.id,
    required this.name,
    required this.imagePath,
    this.fallbackImagePath,
    required this.themeColor,
    this.revealed = false,
    this.matched = false,
  });
}

class PairFinderGame extends StatefulWidget {
  final dynamic initialLevel;

  const PairFinderGame({
    super.key,
    this.initialLevel,
  });

  @override
  State<PairFinderGame> createState() => _PairFinderGameState();
}

class _PairFinderGameState extends State<PairFinderGame> {
  final Random _random = Random();

  // Authentic local items from Northeast India (including Sel Roti, Pitha, Rice and Bamboo Shoot)
  static const List<LocalFoodItem> _foodPool = [
    LocalFoodItem(
      id: 1,
      name: 'Sel Roti',
      imagePath: 'assets/images/pair_finder/sel_roti.png',
      fallbackImagePath: 'assets/images/pair_finder/tea.png',
      themeColor: Color(0xFFD97706),
    ),
    LocalFoodItem(
      id: 2,
      name: 'Pitha',
      imagePath: 'assets/images/pair_finder/pitha.png',
      fallbackImagePath: 'assets/images/pair_finder/fermented_soybean.png',
      themeColor: Color(0xFF8D6E63),
    ),
    LocalFoodItem(
      id: 3,
      name: 'Rice and Bamboo Shoot',
      imagePath: 'assets/images/pair_finder/rice_bamboo_shoot.png',
      fallbackImagePath: 'assets/images/pair_finder/bamboo_shoot.png',
      themeColor: Color(0xFF2E7D5B),
    ),
    LocalFoodItem(
      id: 4,
      name: 'Bamboo Shoot',
      imagePath: 'assets/images/pair_finder/bamboo_shoot.png',
      fallbackImagePath: 'assets/images/pair_finder/bamboo_shoot.png',
      themeColor: Color(0xFF388E3C),
    ),
    LocalFoodItem(
      id: 5,
      name: 'Rice',
      imagePath: 'assets/images/pair_finder/rice.png',
      fallbackImagePath: 'assets/images/pair_finder/bamboo_shoot.png',
      themeColor: Color(0xFF607D8B),
    ),
    LocalFoodItem(
      id: 6,
      name: 'Dried Fish',
      imagePath: 'assets/images/pair_finder/dried_fish.png',
      fallbackImagePath: 'assets/images/pair_finder/dried_fish.png',
      themeColor: Color(0xFFD96550),
    ),
    LocalFoodItem(
      id: 7,
      name: 'Fermented Soybean',
      imagePath: 'assets/images/pair_finder/fermented_soybean.png',
      fallbackImagePath: 'assets/images/pair_finder/fermented_soybean.png',
      themeColor: Color(0xFF795548),
    ),
    LocalFoodItem(
      id: 8,
      name: 'Banana Leaf',
      imagePath: 'assets/images/pair_finder/banana_leaf.png',
      fallbackImagePath: 'assets/images/pair_finder/banana_leaf.png',
      themeColor: Color(0xFF2E7D32),
    ),
    LocalFoodItem(
      id: 9,
      name: 'Tea',
      imagePath: 'assets/images/pair_finder/tea.png',
      fallbackImagePath: 'assets/images/pair_finder/tea.png',
      themeColor: Color(0xFFB06434),
    ),
  ];

  // ============================================================
  // GAME STATE & ADAPTIVE SESSION
  // ============================================================
  // Configurable dynamic hint thresholds
  static const int kPairFinderHintTriggerSeconds = 15;
  static const int kPairFinderHintTriggerMismatches = 3;
  static const Duration kPairFinderHintDisplayDuration = Duration(seconds: 3);

  int _currentLevel = 1;
  int _currentTargetSeconds = 60;
  late List<MemoryCard> _cards;

  int? _firstSelectedIndex;
  int? _secondSelectedIndex;

  bool _checking = false;
  bool _gameFinished = false;
  int _matches = 0;
  int _mismatches = 0;
  int _mismatchesSinceLastMatch = 0;
  int _secondsSinceLastMatch = 0;
  Set<int> _blinkingCardIndices = {};
  bool _hintUsedInLevel = false;
  int _hintCountInLevel = 0;
  Timer? _hintBlinkTimer;

  int _seconds = 0;
  int _consecutivePoorRounds = 0;
  DateTime? _lastFlipAt;
  final List<int> _reactionGapsMs = [];
  final _PairFinderQLearning _learning = _PairFinderQLearning();

  AdaptiveSessionState? _adaptiveSession;
  int? _nextAdaptedLevel;
  int? _nextAdaptedTimer;

  Timer? _timer;

  int get _levelNumber => _currentLevel;

  int get _pairCount {
    switch (_currentLevel) {
      case 1:
        return 2;
      case 2:
      case 3:
        return 3;
      case 4:
      case 5:
      case 6:
        return 4;
      case 7:
      default:
        return 5;
    }
  }

  int get _cardCount => _pairCount * 2;
  bool get _allMatched => _matches >= _pairCount;

  @override
  void initState() {
    super.initState();
    _initAdaptiveSession();
  }

  Future<void> _initAdaptiveSession() async {
    int startLevel = 1;
    double startTimer = 60.0;

    if (widget.initialLevel != null) {
      if (widget.initialLevel is GameLevel) {
        startLevel = (widget.initialLevel as GameLevel).levelNumber;
      } else if (widget.initialLevel is int) {
        startLevel = (widget.initialLevel as int).clamp(1, 7);
      }
    } else {
      final entry = await CognitiveAdaptiveEngine.instance
          .determineEntryLevelAndTimer(targetGameId: 'pair_finder', maxLevels: 7);
      startLevel = entry.startingLevel;
      startTimer = entry.startingTimer;
    }

    _currentLevel = startLevel;
    _currentTargetSeconds = startTimer.round();

    _adaptiveSession = CognitiveAdaptiveEngine.instance.startSession(
      patientId: 'patient_001',
      gameId: 'pair_finder',
      gameName: 'Pair Finder',
      startingLevel: startLevel,
      startingTimer: startTimer,
    );

    _startNewGame();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _hintBlinkTimer?.cancel();
    if (_adaptiveSession != null) {
      CognitiveAdaptiveEngine.instance.endSession(_adaptiveSession!);
    }
    super.dispose();
  }

  // ============================================================
  // LEVEL CARD ARRANGEMENT
  // 1. Level 1 -> 2 pairs / 4 cards, shuffled.
  // 2. Level 2 -> 3 pairs / 6 cards, shuffled.
  // 3. Level 3 -> 3 pairs / 6 cards, more shuffled.
  // 4. Level 4 -> 4 pairs / 8 cards, little bit shuffled.
  // 5. Level 5 -> 4 pairs / 8 cards, more shuffled.
  // 6. Level 6 -> 4 pairs / 8 cards, more shuffled.
  // 7. Level 7 -> 5 pairs / 10 cards, shuffled.
  // ============================================================
  MemoryCard _createCard(LocalFoodItem item) {
    return MemoryCard(
      id: item.id,
      name: item.name,
      imagePath: item.imagePath,
      fallbackImagePath: item.fallbackImagePath,
      themeColor: item.themeColor,
    );
  }

  List<MemoryCard> _arrangeCardsForLevel(
    int level,
    List<LocalFoodItem> selectedItems,
  ) {
    final itemA = selectedItems[0];
    final itemB = selectedItems[1];
    final itemC = selectedItems.length > 2 ? selectedItems[2] : selectedItems[0];
    final itemD = selectedItems.length > 3 ? selectedItems[3] : selectedItems[1];
    final itemE = selectedItems.length > 4 ? selectedItems[4] : selectedItems[0];

    switch (level) {
      case 1:
        // Level 1: 2 pairs / 4 cards, shuffled (interleaved A, B, A, B)
        return [
          _createCard(itemA),
          _createCard(itemB),
          _createCard(itemA),
          _createCard(itemB),
        ];

      case 2:
        // Level 2: 3 pairs / 6 cards, shuffled (A, B, C, A, B, C)
        return [
          _createCard(itemA),
          _createCard(itemB),
          _createCard(itemC),
          _createCard(itemA),
          _createCard(itemB),
          _createCard(itemC),
        ];

      case 3:
        // Level 3: 3 pairs / 6 cards, more shuffled (A, C, B, B, A, C)
        return [
          _createCard(itemA),
          _createCard(itemC),
          _createCard(itemB),
          _createCard(itemB),
          _createCard(itemA),
          _createCard(itemC),
        ];

      case 4:
        // Level 4: 4 pairs / 8 cards, little bit shuffled (A, A, B, C, B, C, D, D)
        return [
          _createCard(itemA),
          _createCard(itemA),
          _createCard(itemB),
          _createCard(itemC),
          _createCard(itemB),
          _createCard(itemC),
          _createCard(itemD),
          _createCard(itemD),
        ];

      case 5:
        // Level 5: 4 pairs / 8 cards, more shuffled (A, B, C, D, C, D, A, B)
        return [
          _createCard(itemA),
          _createCard(itemB),
          _createCard(itemC),
          _createCard(itemD),
          _createCard(itemC),
          _createCard(itemD),
          _createCard(itemA),
          _createCard(itemB),
        ];

      case 6:
        // Level 6: 4 pairs / 8 cards, more shuffled (A, D, B, C, C, B, D, A)
        return [
          _createCard(itemA),
          _createCard(itemD),
          _createCard(itemB),
          _createCard(itemC),
          _createCard(itemC),
          _createCard(itemB),
          _createCard(itemD),
          _createCard(itemA),
        ];

      case 7:
      default:
        // Level 7: 5 pairs / 10 cards, shuffled (A, B, C, D, E, C, A, E, B, D)
        return [
          _createCard(itemA),
          _createCard(itemB),
          _createCard(itemC),
          _createCard(itemD),
          _createCard(itemE),
          _createCard(itemC),
          _createCard(itemA),
          _createCard(itemE),
          _createCard(itemB),
          _createCard(itemD),
        ];
    }
  }

  // ============================================================
  // GAME SETUP & LEVEL FLOW
  // ============================================================
  void _startNewGame() {
    _timer?.cancel();
    _hintBlinkTimer?.cancel();

    // Pick _pairCount distinct items from the authentic food pool
    final shuffledPool = List<LocalFoodItem>.from(_foodPool)..shuffle(_random);
    final selectedItems = shuffledPool.take(_pairCount).toList();

    // Arrange strictly according to the level board placement rules
    _cards = _arrangeCardsForLevel(_currentLevel, selectedItems);

    _firstSelectedIndex = null;
    _secondSelectedIndex = null;
    _checking = false;
    _gameFinished = false;
    _matches = 0;
    _mismatches = 0;
    _mismatchesSinceLastMatch = 0;
    _secondsSinceLastMatch = 0;
    _blinkingCardIndices = {};
    _hintUsedInLevel = false;
    _hintCountInLevel = 0;
    _seconds = _currentTargetSeconds;
    _lastFlipAt = null;
    _reactionGapsMs.clear();

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
        if (_seconds > 0) {
          _seconds--;
          _secondsSinceLastMatch++;

          // Dynamic hint struggle trigger on prolonged time or timer low:
          if (!_allMatched &&
              _blinkingCardIndices.isEmpty &&
              (_secondsSinceLastMatch >= kPairFinderHintTriggerSeconds ||
                  _mismatchesSinceLastMatch >= kPairFinderHintTriggerMismatches ||
                  _seconds <= 15)) {
            _triggerDynamicHint();
          }
        } else {
          timer.cancel();
          _onTimerTimeout();
        }
      });
    });
  }

  void _triggerDynamicHint() {
    if (_gameFinished || _allMatched || !mounted || _blinkingCardIndices.isNotEmpty) {
      return;
    }

    final Map<int, List<int>> unmatchedById = {};
    for (int i = 0; i < _cards.length; i++) {
      if (!_cards[i].matched) {
        unmatchedById.putIfAbsent(_cards[i].id, () => []).add(i);
      }
    }

    if (unmatchedById.isEmpty) return;

    final pairIndices = unmatchedById.values.firstWhere(
      (list) => list.length >= 2,
      orElse: () => [],
    );

    if (pairIndices.length < 2) return;

    setState(() {
      _blinkingCardIndices = {pairIndices[0], pairIndices[1]};
      _hintUsedInLevel = true;
      _hintCountInLevel++;
      _mismatchesSinceLastMatch = 0;
      _secondsSinceLastMatch = 0;
    });

    _playVoiceGuidance('Gentle Clue: Watch for the blinking cards to find a match!');

    _hintBlinkTimer?.cancel();
    _hintBlinkTimer = Timer(kPairFinderHintDisplayDuration, () {
      if (mounted) {
        setState(() {
          _blinkingCardIndices = {};
        });
      }
    });
  }

  void _onTimerTimeout() {
    if (_gameFinished || !mounted) return;
    _timer?.cancel();
    setState(() {
      _gameFinished = true;
    });

    _recordPerformance();
    _showTimeoutDialog();
  }

  String _getTimeString() {
    final now = TimeOfDay.now();
    final hour = now.hourOfPeriod == 0 ? 12 : now.hourOfPeriod;
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  void _playVoiceGuidance([String? customMessage]) {
    final message =
        customMessage ??
        (_allMatched
            ? 'All pairs matched! Press Submit to confirm.'
            : 'Find and match the pairs of local Northeast foods!');

    if (!mounted) return;
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.volume_up, color: Colors.white, size: 26),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF005F46),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 85, left: 16, right: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ============================================================
  // CARD TAP & GAMEPLAY
  // ============================================================
  Future<void> _handleCardTap(int index) async {
    if (_checking || _gameFinished) {
      return;
    }

    final tappedCard = _cards[index];
    final now = DateTime.now();
    if (_lastFlipAt != null) {
      _reactionGapsMs.add(now.difference(_lastFlipAt!).inMilliseconds);
    }
    _lastFlipAt = now;

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
    });

    await Future.delayed(const Duration(milliseconds: 700));
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
        _mismatchesSinceLastMatch = 0;
        _secondsSinceLastMatch = 0;
        _blinkingCardIndices.remove(_firstSelectedIndex);
        _blinkingCardIndices.remove(_secondSelectedIndex);
      });

      if (_matches == _pairCount) {
        // Player correctly matched ALL pairs in the current level!
        // Auto-submit on finding all pairs
        setState(() {
          _firstSelectedIndex = null;
          _secondSelectedIndex = null;
          _checking = false;
        });

        _onSubmitPressed();
        return;
      }
    }
    // Mismatch
    else {
      setState(() {
        firstCard.revealed = false;
        secondCard.revealed = false;
        _mismatches++;
        _mismatchesSinceLastMatch++;
      });

      if (_mismatchesSinceLastMatch >= kPairFinderHintTriggerMismatches &&
          _blinkingCardIndices.isEmpty) {
        _triggerDynamicHint();
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
  // SUBMIT BUTTON ACTION (Submit -> Next Level Flow for all 7 levels)
  // Following SAME ending logic/comments & "Well Done" / "Not Completed" pattern
  // ============================================================
  void _onSubmitPressed() {
    if (_allMatched) {
      // Successfully matched all pairs in current level!
      _recordPerformance();

      if (_currentLevel < 7) {
        _timer?.cancel();
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        // Directly auto-advance to next level without obstructing "Well Done" message
        _advanceLevel();
      } else {
        // Completed Level 7!
        _timer?.cancel();
        setState(() => _gameFinished = true);

        _playVoiceGuidance('Great job! You completed all 7 levels!');
        _showGameCompletedDialog(context);
      }
    } else {
      // Patient submitted without matching all pairs (Not Completed)
      _playVoiceGuidance('Try again! Find and match all pairs.');
      _showNotCompletedDialog();
    }
  }

  void _advanceLevel() {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    if (_nextAdaptedLevel != null) {
      _currentLevel = max(_currentLevel + 1, _nextAdaptedLevel!).clamp(1, 7);
      _currentTargetSeconds = (_nextAdaptedTimer ?? 60).clamp(15, 60);
    } else if (_currentLevel < 7) {
      _currentLevel++;
    } else {
      _currentLevel = 1;
    }
    _startNewGame();
  }

  void _recordPerformance() {
    final completionTimeSeconds = max(1.0, (_currentTargetSeconds - _seconds).toDouble());
    final totalTasks = _pairCount;
    final correctAnswers = _matches;
    final wrongAnswers = _mismatches;
    final isSuccess = _allMatched;
    final isTimeout = _seconds <= 0 && !isSuccess;

    final levelMetrics = LevelPerformanceMetrics(
      level: _currentLevel,
      difficulty: _currentLevel,
      score: (correctAnswers / max(1, correctAnswers + wrongAnswers)) * 100.0,
      accuracy: (correctAnswers / max(1, totalTasks)) * 100.0,
      correctAnswers: correctAnswers,
      wrongAnswers: wrongAnswers,
      totalTasks: totalTasks,
      completionTime: completionTimeSeconds,
      allowedTimerDuration: _currentTargetSeconds.toDouble(),
      remainingTime: max(0.0, _seconds.toDouble()),
      timeUtilization: (completionTimeSeconds / max(1, _currentTargetSeconds)).clamp(0.0, 1.0),
      attempts: 1,
      isSuccess: isSuccess,
      isTimeout: isTimeout,
      hintUsed: _hintUsedInLevel,
      hintCount: _hintCountInLevel,
      completedWithHint: isSuccess && _hintUsedInLevel,
    );

    if (_adaptiveSession != null) {
      final adaptation = CognitiveAdaptiveEngine.instance.recordLevelCompleted(
        session: _adaptiveSession!,
        levelMetrics: levelMetrics,
        maxLevels: 7,
      );

      _nextAdaptedLevel = adaptation.nextLevel;
      _nextAdaptedTimer = adaptation.nextTimer.round();
    }

    final score = levelMetrics.score / 100.0;
    final performance = score >= 0.7
        ? 'Good'
        : score >= 0.4
        ? 'Average'
        : 'Poor';
    final averageReaction = _reactionGapsMs.isEmpty
        ? 0
        : _reactionGapsMs.reduce((a, b) => a + b) / _reactionGapsMs.length;
    _consecutivePoorRounds = score < 0.35 ? _consecutivePoorRounds + 1 : 0;
    final exhausted =
        _consecutivePoorRounds >= 3 ||
        (averageReaction > 4500 &&
            _mismatches >= min(max(_matches * 2, 2), 20));
    final action = _learning.completeRound(
      level: _currentLevel,
      targetSeconds: _currentTargetSeconds,
      score: score,
    );
    PairFinderPerformanceStore.add(
      PairFinderRoundResult(
        level: _currentLevel,
        score: score,
        performance: performance,
        timestamp: DateTime.now(),
        action: action,
        exhausted: exhausted,
      ),
    );
  }

  // ============================================================
  // FEEDBACK DIALOGS (Matching Object Focus style)
  // ============================================================
  void _showNotCompletedDialog() {
    const accent = Color(0xFFFFB82E);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.volume_up, color: accent, size: 30),
                    onPressed: () => _playVoiceGuidance(
                      'Not Completed! Find and match all pairs before submitting.',
                    ),
                    tooltip: 'Voice over',
                  ),
                ],
              ),
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.refresh_rounded,
                  size: 52,
                  color: accent,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Not Completed',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: accent,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'You have not matched all pairs yet.\nMatched $_matches of $_pairCount pairs.\nTake your time and keep matching!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  height: 1.35,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          actions: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Try Again',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      _navigateToMemoryGames();
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Color(0xFF7A97FF),
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Back to Games',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7A97FF),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showTimeoutDialog() {
    const accent = Color(0xFFE53935);

    _playVoiceGuidance('Time Out! Time is up. Returning to memory games.');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.timer_off_rounded,
                  size: 52,
                  color: accent,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Time Out!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: accent,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Time is up for this level.\nLet\'s return to memory games to try again later.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  height: 1.35,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          actions: [
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  _navigateToMemoryGames();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF19D3F3),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Back to Games',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showGameCompletedDialog(BuildContext context) {
    const accent = Color(0xFF4CAF50);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.volume_up, color: accent, size: 30),
                    onPressed: () => _playVoiceGuidance(
                      'Congratulations! You completed all 7 levels of Pair Finder!',
                    ),
                    tooltip: 'Voice over',
                  ),
                ],
              ),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.military_tech_rounded,
                  size: 64,
                  color: accent,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Congratulations!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: accent,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'You completed all 7 levels of Pair Finder!\nYour memory is sharp and strong.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  height: 1.4,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          actions: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      _currentLevel = 1;
                      _currentTargetSeconds = 60;
                      _startNewGame();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Play Again',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      _navigateToMemoryGames();
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Color(0xFF7A97FF),
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Back to Games',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7A97FF),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // BACK NAVIGATION TO MEMORY GAMES
  // ============================================================
  void _navigateToMemoryGames() {
    _timer?.cancel();
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const GamesMemoryScreen()),
      );
    }
  }

  // ============================================================
  // TESTING HOOKS
  // ============================================================
  @visibleForTesting
  List<MemoryCard> get cards => _cards;

  @visibleForTesting
  bool get hintUsedInLevel => _hintUsedInLevel;

  @visibleForTesting
  int get hintCountInLevel => _hintCountInLevel;

  @visibleForTesting
  Set<int> get blinkingCardIndices => _blinkingCardIndices;

  @visibleForTesting
  void simulateTriggerHint() => _triggerDynamicHint();

  @visibleForTesting
  void simulateMatchAll() {
    setState(() {
      for (final card in _cards) {
        card.matched = true;
        card.revealed = true;
      }
      _matches = _pairCount;
      _gameFinished = false; // Player still needs to press Submit!
    });
  }

  @visibleForTesting
  void simulateSubmit() {
    _onSubmitPressed();
  }

  @visibleForTesting
  void simulateTap(int index) {
    _handleCardTap(index);
  }

  // ============================================================
  // MAIN BUILD
  // ============================================================
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth > 600;

    final String levelSubtext = 'Level $_levelNumber • $_cardCount Cards';

    return Scaffold(
      backgroundColor: const Color(0xFF2B2525),
      body: SafeArea(
        child: Center(
          child: Container(
            width: isTablet ? 500 : double.infinity,
            margin: isTablet
                ? const EdgeInsets.symmetric(vertical: 20)
                : EdgeInsets.zero,
            decoration: BoxDecoration(
              color: const Color(0xFFF7FAF8),
              borderRadius: BorderRadius.circular(isTablet ? 30 : 0),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  // 1. Header (Back Button + Logo + Time + Speaker)
                  Row(
                    children: [
                      // Back Button using existing UI style returning to memory_games
                      IconButton(
                        key: const Key('pair_finder_back_button'),
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.black87,
                          size: 28,
                        ),
                        onPressed: _navigateToMemoryGames,
                        tooltip: 'Back to Memory Games',
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: _navigateToMemoryGames,
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/logo.jpg',
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const CircleAvatar(
                                  radius: 25,
                                  backgroundColor: Color(0xFF005F46),
                                  child: Icon(
                                    Icons.grid_view_rounded,
                                    color: Colors.white,
                                    size: 26,
                                  ),
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _getTimeString(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      IconButton(
                        key: const Key('pair_finder_speaker_button_header'),
                        icon: const Icon(
                          Icons.volume_up,
                          color: Colors.black87,
                          size: 28,
                        ),
                        onPressed: () => _playVoiceGuidance(),
                        tooltip: 'Speaker',
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // 2. Instruction Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7A97FF),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Pair Finder — $levelSubtext\n'
                            '${_allMatched ? "★ All Pairs Matched! Press Submit" : "Match all pairs of pictures"}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.25,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.volume_up,
                            color: Colors.white,
                            size: 26,
                          ),
                          onPressed: () => _playVoiceGuidance(),
                          tooltip: 'Voice over',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // 3. Responsive Card Grid
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 3.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: _buildCardGrid(isTablet),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 4. Timer Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF5D4037),
                            width: 3.0,
                          ),
                        ),
                        child: Center(
                          child: Container(
                            width: 3.0,
                            height: 12,
                            decoration: BoxDecoration(
                              color: const Color(0xFF5D4037),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Timer : $_seconds',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // 5. Bottom Controls (Submit + Speaker)
                  Row(
                    children: [
                      // Submit Button (Yellow, checkmark icon)
                      Expanded(
                        child: SizedBox(
                          height: 54,
                          child: ElevatedButton(
                            key: const Key('pair_finder_submit_button'),
                            onPressed: _onSubmitPressed,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFB82E),
                              elevation: 2,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  color: Colors.white,
                                  size: 22,
                                ),
                                SizedBox(width: 6),
                                Flexible(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      'Submit',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
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

                      const SizedBox(width: 10),

                      // Speaker Button (Yellow square)
                      SizedBox(
                        width: 54,
                        height: 54,
                        child: ElevatedButton(
                          key: const Key('pair_finder_speaker_button'),
                          onPressed: () => _playVoiceGuidance(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFB82E),
                            elevation: 2,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Icon(
                            Icons.volume_up,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // RESPONSIVE CARD GRID
  // Levels 1-2: 2x2 grid (4 cards)
  // Levels 3-5: 2x3 grid (6 cards)
  // Levels 6-7: 2x4 grid (8 cards)
  // ============================================================
  Widget _buildCardGrid(bool isTablet) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const double spacing = 12.0;
        const int crossAxisCount = 2; // 2 columns
        final int itemCount = _cards.length; // 4, 6, or 8 cards
        final int rows = (itemCount / crossAxisCount).ceil(); // 2, 3, or 4 rows

        final double availableWidth =
            constraints.maxWidth - (spacing * (crossAxisCount - 1));
        final double cardWidth = availableWidth / crossAxisCount;

        final double availableHeight =
            constraints.maxHeight - (spacing * (rows - 1));
        final double cardHeight = availableHeight / rows;

        final double childAspectRatio = (cardHeight > 0)
            ? (cardWidth / cardHeight)
            : 1.0;

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
    final bool isBlinking = _blinkingCardIndices.contains(index);

    final cardWidget = GestureDetector(
      onTap: () => _handleCardTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isFaceUp ? Colors.white : const Color(0xFFE2E4E2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isBlinking
                ? const Color(0xFFFFB82E)
                : (isFaceUp
                    ? (card.matched
                        ? const Color(0xFF2E7D5B)
                        : const Color(0xFFF72585))
                    : const Color(0xFFCACFCB)),
            width: isBlinking ? 3.5 : 3.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isBlinking
                  ? const Color(0xFFFFB82E).withValues(alpha: 0.35)
                  : Colors.black.withValues(alpha: 0.08),
              blurRadius: isBlinking ? 10 : 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(13),
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

    return _PulsingHintCard(
      isBlinking: isBlinking,
      child: cardWidget,
    );
  }

  // Card Back: Landscape illustration matching existing game with "Tap to Flip" text
  Widget _buildCardBack(BoxConstraints constraints) {
    return Stack(
      children: [
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.all(4.0),
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

        // Text overlay for test assertions and elderly accessibility
        Positioned(
          bottom: 4,
          left: 0,
          right: 0,
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Tap to Flip',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.4,
                  ),
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
    final double imgSize = (maxHeight * 0.4).clamp(16.0, 80.0);
    final double fontSize = (maxHeight * 0.14).clamp(9.0, 14.0);

    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Food Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  card.imagePath,
                  width: imgSize,
                  height: imgSize,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    if (card.fallbackImagePath != null) {
                      return Image.asset(
                        card.fallbackImagePath!,
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
                      );
                    }
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

              const SizedBox(height: 2),

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
              if (card.matched && maxHeight >= 40) ...[
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: const Color(0xFF2E7D5B),
                      size: (fontSize * 0.9).clamp(10.0, 14.0),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      'Matched',
                      style: TextStyle(
                        fontSize: (fontSize * 0.85).clamp(8.0, 11.0),
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2E7D5B),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

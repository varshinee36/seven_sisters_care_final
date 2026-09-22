import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../localization/app_localizations.dart';
import '../../models/cognitive_game_performance.dart';
import '../../services/cognitive_adaptive_engine.dart';
import 'memory_hunt_answer_view.dart';
import 'memory_hunt_data.dart';
import 'memory_hunt_feedback_dialog.dart';
import 'memory_hunt_memorize_view.dart';
import 'memory_hunt_ready_view.dart';

/// Memory Hunt game flow across 5 progressive levels.
///
/// Flow: Memorize (with 30s countdown timer) → Get Ready (auto 6s) → Answer (with countdown timer max 60s) → Next Level
enum MemoryHuntStep { memorize, ready, answer }

class MemoryHuntScreen extends StatefulWidget {
  const MemoryHuntScreen({super.key});

  @override
  State<MemoryHuntScreen> createState() => _MemoryHuntScreenState();
}

class _MemoryHuntScreenState extends State<MemoryHuntScreen> {
  // Configurable dynamic hint thresholds
  static const int kMemoryHuntHintTriggerSeconds = 20;
  static const int kMemoryHuntHintTriggerAttempts = 2;
  static const int kMemoryHuntHintDisplayDurationSeconds = 5;

  MemoryHuntStep _step = MemoryHuntStep.memorize;

  Timer? _stepTimer;

  int _currentLevel = 1;
  int _currentTargetSeconds = 60;
  int _memorizeTargetSeconds = 30;
  int _memorizeSeconds = 30;
  int _answerSeconds = 60;

  bool _gameFinished = false;
  AdaptiveSessionState? _adaptiveSession;
  int? _nextAdaptedLevel;
  int? _nextAdaptedTimer;
  DateTime? _levelStartTime;

  // Dynamic hint state tracking
  int _attemptsInLevel = 0;
  bool _hintUsedInLevel = false;
  int _hintCountInLevel = 0;
  bool _hintDisplayed = false;
  String? _activeHintText;

  final Set<String> _selectedIds = {};

  MemoryHuntLevelData get _currentLevelData =>
      MemoryHuntCatalog.levels[(_currentLevel - 1).clamp(0, MemoryHuntCatalog.levels.length - 1)];

  @override
  void initState() {
    super.initState();
    _initAdaptiveSession();
  }

  Future<void> _initAdaptiveSession() async {
    final entry = await CognitiveAdaptiveEngine.instance
        .determineEntryLevelAndTimer(targetGameId: 'memory_hunt', maxLevels: 5);

    _currentLevel = entry.startingLevel.clamp(1, 5);
    _currentTargetSeconds = entry.startingTimer.round().clamp(15, 60);
    _memorizeTargetSeconds = (_currentTargetSeconds * 0.5).round().clamp(10, 60);

    _adaptiveSession = CognitiveAdaptiveEngine.instance.startSession(
      patientId: 'patient_001',
      gameId: 'memory_hunt',
      gameName: 'Memory Hunt',
      startingLevel: _currentLevel,
      startingTimer: _currentTargetSeconds.toDouble(),
    );

    _startMemorizeStep();
  }

  @override
  void dispose() {
    _stepTimer?.cancel();
    if (_adaptiveSession != null) {
      CognitiveAdaptiveEngine.instance.endSession(_adaptiveSession!);
    }
    super.dispose();
  }

  void _cancelStepTimer() {
    _stepTimer?.cancel();
    _stepTimer = null;
  }

  void _startMemorizeStep() {
    _cancelStepTimer();
    setState(() {
      _step = MemoryHuntStep.memorize;
      _memorizeSeconds = _memorizeTargetSeconds;
      _gameFinished = false;
    });

    _stepTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _gameFinished) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_memorizeSeconds > 0) {
          _memorizeSeconds--;
        } else {
          timer.cancel();
          _startReadyStep();
        }
      });
    });
  }

  void _startReadyStep() {
    _cancelStepTimer();
    setState(() {
      _step = MemoryHuntStep.ready;
    });

    int readySeconds = 6;
    _stepTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _gameFinished) {
        timer.cancel();
        return;
      }
      setState(() {
        if (readySeconds > 0) {
          readySeconds--;
        } else {
          timer.cancel();
          _startAnswerStep();
        }
      });
    });
  }

  void _startAnswerStep() {
    _cancelStepTimer();
    setState(() {
      _step = MemoryHuntStep.answer;
      _answerSeconds = _currentTargetSeconds.clamp(15, 60);
      _levelStartTime = DateTime.now();
      _attemptsInLevel = 0;
      _hintUsedInLevel = false;
      _hintCountInLevel = 0;
      _hintDisplayed = false;
      _activeHintText = null;
    });

    _stepTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _gameFinished) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_answerSeconds > 0) {
          _answerSeconds--;

          // Adaptive struggle detection on prolonged search or timer getting close to expiration:
          final elapsedSeconds = _currentTargetSeconds - _answerSeconds;
          if (!_hintDisplayed &&
              (elapsedSeconds >= kMemoryHuntHintTriggerSeconds || _answerSeconds <= 15)) {
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
    if (_hintDisplayed || _gameFinished || !mounted) return;
    if (_currentLevelData.hints.isEmpty) return;

    final hintIndex = _hintCountInLevel % _currentLevelData.hints.length;
    final hint = _currentLevelData.getLocalizedHint(context, hintIndex);

    setState(() {
      _hintUsedInLevel = true;
      _hintCountInLevel++;
      _hintDisplayed = true;
      _activeHintText = hint;
    });

    playVoiceGuidance('Gentle Clue: $hint');
  }

  void _onTimerTimeout() {
    if (_gameFinished || !mounted) return;
    _cancelStepTimer();
    setState(() {
      _gameFinished = true;
    });

    final targetIds = _currentLevelData.targetIds;
    final correctCount = _selectedIds.where((id) => targetIds.contains(id)).length;
    final wrongCount = _selectedIds.where((id) => !targetIds.contains(id)).length;

    final metrics = LevelPerformanceMetrics(
      level: _currentLevel,
      difficulty: _currentLevel,
      score: (correctCount / max(1, targetIds.length)) * 100.0,
      accuracy: (correctCount / max(1, targetIds.length)) * 100.0,
      correctAnswers: correctCount,
      wrongAnswers: wrongCount,
      totalTasks: targetIds.length,
      completionTime: _currentTargetSeconds.toDouble(),
      allowedTimerDuration: _currentTargetSeconds.toDouble(),
      remainingTime: 0.0,
      timeUtilization: 1.0,
      attempts: _attemptsInLevel + 1,
      isSuccess: false,
      isTimeout: true,
      hintUsed: _hintUsedInLevel,
      hintCount: _hintCountInLevel,
      completedWithHint: false,
    );

    if (_adaptiveSession != null) {
      CognitiveAdaptiveEngine.instance.recordLevelCompleted(
        session: _adaptiveSession!,
        levelMetrics: metrics,
        maxLevels: 5,
      );
    }

    _showTimeoutDialog();
  }

  String _getDefaultVoiceGuidance() {
    switch (_step) {
      case MemoryHuntStep.memorize:
        return context.loc.pleaseRememberObjectsCarefully(_currentLevelData.targetCount);
      case MemoryHuntStep.ready:
        return context.loc.getReadyBreathe;
      case MemoryHuntStep.answer:
        return context.loc.selectObjectsGuidance(
          _currentLevelData.targetCount,
          0,
        );
    }
  }

  void playVoiceGuidance([String? customMessage]) {
    final text = customMessage ?? _getDefaultVoiceGuidance();
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.volume_up, color: Colors.white, size: 26),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
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

  void _onSubmitPressed() {
    _cancelStepTimer();
    final targetIds = _currentLevelData.targetIds;
    final isCorrect = _selectedIds.length == targetIds.length &&
        _selectedIds.containsAll(targetIds);

    final now = DateTime.now();
    final completionTimeSeconds = _levelStartTime != null
        ? now.difference(_levelStartTime!).inSeconds.toDouble().clamp(1.0, 300.0)
        : 15.0;

    final correctCount = _selectedIds.where((id) => targetIds.contains(id)).length;
    final wrongCount = _selectedIds.where((id) => !targetIds.contains(id)).length;
    final totalTasks = targetIds.length;
    final currentAttempts = _attemptsInLevel + 1;

    final metrics = LevelPerformanceMetrics(
      level: _currentLevel,
      difficulty: _currentLevel,
      score: (correctCount / max(1, totalTasks)) * 100.0,
      accuracy: (correctCount / max(1, totalTasks)) * 100.0,
      correctAnswers: correctCount,
      wrongAnswers: wrongCount,
      totalTasks: totalTasks,
      completionTime: completionTimeSeconds,
      allowedTimerDuration: _currentTargetSeconds.toDouble(),
      remainingTime: max(0.0, _currentTargetSeconds.toDouble() - completionTimeSeconds),
      timeUtilization: (completionTimeSeconds / max(1, _currentTargetSeconds)).clamp(0.0, 1.0),
      attempts: currentAttempts,
      isSuccess: isCorrect,
      isTimeout: false,
      hintUsed: _hintUsedInLevel,
      hintCount: _hintCountInLevel,
      completedWithHint: isCorrect && _hintUsedInLevel,
    );

    if (_adaptiveSession != null) {
      final adaptation = CognitiveAdaptiveEngine.instance.recordLevelCompleted(
        session: _adaptiveSession!,
        levelMetrics: metrics,
        maxLevels: 5,
      );
      _nextAdaptedLevel = adaptation.nextLevel;
      _nextAdaptedTimer = adaptation.nextTimer.round().clamp(15, 60);
    }

    if (isCorrect) {
      if (_currentLevel < 5) {
        // Auto-advance directly without showing obstructing "Well Done" message
        _advanceLevel();
      } else {
        // Final level completed
        if (_adaptiveSession != null) {
          CognitiveAdaptiveEngine.instance.endSession(_adaptiveSession!);
        }
        playVoiceGuidance(context.loc.allLevelsCompletedGuidance);
        MemoryHuntFeedbackDialog.showGameCompleted(
          context,
          onSpeaker: () => playVoiceGuidance(context.loc.allLevelsCompletedGuidance),
          onPlayAgain: () {
            setState(() {
              _currentLevel = 1;
              _selectedIds.clear();
            });
            _startMemorizeStep();
          },
          onExit: () {
            Navigator.of(context).pop();
          },
        );
      }
    } else {
      _attemptsInLevel++;
      if (!_hintDisplayed && _attemptsInLevel >= kMemoryHuntHintTriggerAttempts) {
        _triggerDynamicHint();
      }

      final targetLabels = _currentLevelData.getLocalizedTargetLabels(context);

      playVoiceGuidance('Wrong Answer! Let\'s try again.');

      MemoryHuntFeedbackDialog.showWrongAnswer(
        context,
        answers: targetLabels,
        onSpeaker: () => playVoiceGuidance('Wrong Answer! The correct objects were: ${targetLabels.join(", ")}'),
        onBackToGames: () {
          if (Navigator.canPop(context)) {
            Navigator.of(context).pop();
          }
        },
        onRetry: () {
          setState(() {
            _selectedIds.clear();
          });
          _startMemorizeStep();
        },
      );
    }
  }

  void _showTimeoutDialog() {
    const accent = Color(0xFFE53935);

    playVoiceGuidance('Time Out! Time is up. Returning to memory games.');

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
                  if (Navigator.canPop(context)) {
                    Navigator.of(context).pop();
                  }
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

  void _advanceLevel() {
    final nextLevel = _nextAdaptedLevel != null
        ? max(_currentLevel + 1, _nextAdaptedLevel!).clamp(1, 5)
        : (_currentLevel < 5 ? _currentLevel + 1 : 5);

    if (nextLevel <= 5 && _currentLevel < 5) {
      setState(() {
        _currentLevel = nextLevel;
        if (_nextAdaptedTimer != null) {
          _currentTargetSeconds = _nextAdaptedTimer!.clamp(15, 60);
          _memorizeTargetSeconds = (_currentTargetSeconds * 0.5).round().clamp(10, 60);
        }
        _selectedIds.clear();
      });
      _startMemorizeStep();
    } else {
      if (_adaptiveSession != null) {
        CognitiveAdaptiveEngine.instance.endSession(_adaptiveSession!);
      }
      playVoiceGuidance(context.loc.allLevelsCompletedGuidance);

      MemoryHuntFeedbackDialog.showGameCompleted(
        context,
        onSpeaker: () => playVoiceGuidance(context.loc.allLevelsCompletedGuidance),
        onPlayAgain: () {
          setState(() {
            _currentLevel = 1;
            _selectedIds.clear();
          });
          _startMemorizeStep();
        },
        onExit: () {
          Navigator.of(context).pop();
        },
      );
    }
  }

  void _toggleSelection(String id) {
    if (_step != MemoryHuntStep.answer || _gameFinished) return;
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });

    // Auto-submit when all target objects are found correctly
    final targetIds = _currentLevelData.targetIds;
    if (_selectedIds.length == targetIds.length && _selectedIds.containsAll(targetIds)) {
      _onSubmitPressed();
    }
  }

  // Testing hooks
  @visibleForTesting
  bool get hintUsedInLevel => _hintUsedInLevel;

  @visibleForTesting
  int get hintCountInLevel => _hintCountInLevel;

  @visibleForTesting
  String? get activeHintText => _activeHintText;

  @visibleForTesting
  int get attemptsInLevel => _attemptsInLevel;

  @visibleForTesting
  void simulateTriggerHint() => _triggerDynamicHint();

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
              child: _buildStepContent(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_step) {
      case MemoryHuntStep.memorize:
        return MemoryHuntMemorizeView(
          level: _currentLevel,
          seconds: _memorizeSeconds,
          items: _currentLevelData.memorizeItems,
          onSpeaker: () => playVoiceGuidance(
              context.loc.pleaseRememberObjectsCarefully(_currentLevelData.targetCount)),
        );
      case MemoryHuntStep.ready:
        return MemoryHuntReadyView(
          onSpeaker: () => playVoiceGuidance(context.loc.getReadyBreathe),
        );
      case MemoryHuntStep.answer:
        return MemoryHuntAnswerView(
          level: _currentLevel,
          targetCount: _currentLevelData.targetCount,
          seconds: _answerSeconds,
          items: _currentLevelData.answerItems,
          selectedIds: _selectedIds,
          onToggle: _toggleSelection,
          onSubmit: _onSubmitPressed,
          hintText: _activeHintText,
          onHintSpeaker: _activeHintText != null
              ? () => playVoiceGuidance('Gentle Clue: $_activeHintText')
              : null,
          onSpeaker: () => playVoiceGuidance(
              context.loc.selectObjectsGuidance(_currentLevelData.targetCount, 0)),
        );
    }
  }
}

import 'dart:async';

import 'package:flutter/material.dart';

import 'memory_hunt_answer_view.dart';
import 'memory_hunt_data.dart';
import 'memory_hunt_feedback_dialog.dart';
import 'memory_hunt_memorize_view.dart';
import 'memory_hunt_ready_view.dart';

/// Memory Hunt game flow across 5 progressive levels.
///
/// Flow: Memorize (hidden 30s) → Get Ready (auto 6s) → Answer → Feedback / Hint → Next Level
///
/// Levels:
/// Level 1: 3 objects (Apple, Book, Ball)
/// Level 2: 5 objects (Clock, Flower, House, Tree, Sun)
/// Level 3: 7 objects (Star, Bird, Fish, Hat, Key, Chair, Boat)
/// Level 4: 8 objects (Train, Umbrella, Camera, Guitar, Shoe, Phone, Bicycle, Lamp)
/// Level 5: 10 objects (Apple, Clock, Sun, Tree, Star, Camera, Guitar, Umbrella, Bird, Train)
enum MemoryHuntStep { memorize, ready, answer }

class MemoryHuntScreen extends StatefulWidget {
  const MemoryHuntScreen({super.key});

  @override
  State<MemoryHuntScreen> createState() => _MemoryHuntScreenState();
}

class _MemoryHuntScreenState extends State<MemoryHuntScreen> {
  MemoryHuntStep _step = MemoryHuntStep.memorize;

  /// Hidden memorize duration.
  static const Duration _memorizeDuration = Duration(seconds: 30);

  /// Get Ready breathing duration.
  static const Duration _readyDuration = Duration(seconds: 6);

  Timer? _stepTimer;

  /// Active level index (1 through 5).
  int _currentLevel = 1;

  /// Hints used for the active level (max 3 per level).
  int _hintsUsed = 0;

  final Set<String> _selectedIds = {};

  MemoryHuntLevelData get _currentLevelData =>
      MemoryHuntCatalog.levels[_currentLevel - 1];

  int get _hintsRemaining => (3 - _hintsUsed).clamp(0, 3);

  @override
  void initState() {
    super.initState();
    _startStepTimer();
  }

  @override
  void dispose() {
    _stepTimer?.cancel();
    super.dispose();
  }

  void _cancelStepTimer() {
    _stepTimer?.cancel();
    _stepTimer = null;
  }

  void _startStepTimer() {
    _cancelStepTimer();

    if (_step == MemoryHuntStep.memorize) {
      _stepTimer = Timer(_memorizeDuration, () {
        if (!mounted) return;
        setState(() => _step = MemoryHuntStep.ready);
        _startStepTimer();
      });
    } else if (_step == MemoryHuntStep.ready) {
      _stepTimer = Timer(_readyDuration, () {
        if (!mounted) return;
        setState(() => _step = MemoryHuntStep.answer);
        _cancelStepTimer();
      });
    }
  }

  String _getDefaultVoiceGuidance() {
    switch (_step) {
      case MemoryHuntStep.memorize:
        return 'Please remember these ${_currentLevelData.targetCount} objects carefully.';
      case MemoryHuntStep.ready:
        return 'Get ready! Take a deep breath.';
      case MemoryHuntStep.answer:
        return 'Select the ${_currentLevelData.targetCount} objects you saw earlier. You have $_hintsRemaining hints remaining.';
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

  void _onHintPressed() {
    if (_hintsRemaining > 0) {
      setState(() {
        _hintsUsed++;
      });
      final hintIndex = _hintsUsed - 1;
      final hintText = _currentLevelData.hints[hintIndex];

      playVoiceGuidance('Hint $_hintsUsed: $hintText');

      MemoryHuntFeedbackDialog.showHint(
        context,
        title: 'Hint $_hintsUsed of 3',
        message: hintText,
        onSpeaker: () => playVoiceGuidance('Hint $_hintsUsed: $hintText'),
      );
    } else {
      playVoiceGuidance('You have used all 3 hints for this level.');
      MemoryHuntFeedbackDialog.showHint(
        context,
        title: 'No Hints Remaining',
        message:
            'You have used all 3 hints for Level $_currentLevel. Try your best to select the matching objects!',
        onSpeaker: () =>
            playVoiceGuidance('You have used all 3 hints for this level.'),
      );
    }
  }

  void _onSubmitPressed() {
    final targetIds = _currentLevelData.targetIds;
    final isCorrect = _selectedIds.length == targetIds.length &&
        _selectedIds.containsAll(targetIds);

    if (isCorrect) {
      playVoiceGuidance('Well done! You remembered correctly.');
      MemoryHuntFeedbackDialog.showSuccess(
        context,
        message: _currentLevel < 5
            ? 'You found all ${_currentLevelData.targetCount} objects for Level $_currentLevel!'
            : 'You found all 10 objects for the final level!',
        onSpeaker: () =>
            playVoiceGuidance('Well done! You remembered correctly.'),
        onContinue: _advanceLevel,
      );
    } else {
      // Patient entered a wrong answer
      if (_hintsRemaining > 0) {
        // Prompt them to use a hint until the hint limit finishes
        playVoiceGuidance(
            'Try again! Use a hint to help you. You have $_hintsRemaining hints remaining.');

        MemoryHuntFeedbackDialog.showTryAgainUseHint(
          context,
          hintsRemaining: _hintsRemaining,
          onSpeaker: () => playVoiceGuidance(
              'Try again! Use a hint to help you. You have $_hintsRemaining hints remaining.'),
          onUseHint: () {
            _onHintPressed();
          },
          onTryAgain: () {
            // Dismiss dialog and let the patient adjust their selections
          },
        );
      } else {
        // All 3 hints have been used and patient entered wrong answer
        final targetLabels =
            _currentLevelData.memorizeItems.map((e) => e.label).toList();

        playVoiceGuidance(
            'All hints have finished. The correct objects were: ${targetLabels.join(', ')}');

        MemoryHuntFeedbackDialog.showFailure(
          context,
          answers: targetLabels,
          onSpeaker: () => playVoiceGuidance(
              'All hints finished. The correct objects were: ${targetLabels.join(', ')}'),
          onRetry: () {
            setState(() {
              _selectedIds.clear();
              _hintsUsed = 0;
              _step = MemoryHuntStep.memorize;
            });
            _startStepTimer();
          },
          onContinue: _advanceLevel,
        );
      }
    }
  }

  void _advanceLevel() {
    if (_currentLevel < 5) {
      setState(() {
        _currentLevel++;
        _hintsUsed = 0;
        _selectedIds.clear();
        _step = MemoryHuntStep.memorize;
      });
      _startStepTimer();
    } else {
      // Reached completion of all 5 levels!
      playVoiceGuidance(
          'Congratulations! You completed all 5 levels of Memory Hunt!');

      MemoryHuntFeedbackDialog.showGameCompleted(
        context,
        onSpeaker: () => playVoiceGuidance(
            'Congratulations! You completed all 5 levels of Memory Hunt!'),
        onPlayAgain: () {
          setState(() {
            _currentLevel = 1;
            _hintsUsed = 0;
            _selectedIds.clear();
            _step = MemoryHuntStep.memorize;
          });
          _startStepTimer();
        },
        onExit: () {
          Navigator.of(context).pop();
        },
      );
    }
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
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
          items: _currentLevelData.memorizeItems,
          onSpeaker: () => playVoiceGuidance(
              'Please remember these ${_currentLevelData.targetCount} objects.'),
        );
      case MemoryHuntStep.ready:
        return MemoryHuntReadyView(
          onSpeaker: () => playVoiceGuidance('Get ready! Take a deep breath.'),
        );
      case MemoryHuntStep.answer:
        return MemoryHuntAnswerView(
          level: _currentLevel,
          targetCount: _currentLevelData.targetCount,
          hintsRemaining: _hintsRemaining,
          items: _currentLevelData.answerItems,
          selectedIds: _selectedIds,
          onToggle: _toggleSelection,
          onHint: _onHintPressed,
          onSubmit: _onSubmitPressed,
          onSpeaker: () => playVoiceGuidance(
              'Select the ${_currentLevelData.targetCount} objects you saw earlier. You have $_hintsRemaining hints remaining.'),
        );
    }
  }
}

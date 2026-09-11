import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/cognitive_game_performance.dart';
import 'analytics_service.dart';

/// Lightweight Q-Learning Reinforcement Learning (RL) AI Adaptive Engine
/// for Cognitive Games in Seven Sisters Care.
class CognitiveAdaptiveEngine {
  static final CognitiveAdaptiveEngine instance = CognitiveAdaptiveEngine._internal();
  CognitiveAdaptiveEngine._internal() {
    _initQTable();
  }

  // --- Q-LEARNING HYPERPARAMETERS ---
  static const double _alpha = 0.2; // Learning rate
  static const double _gamma = 0.4; // Discount factor
  static const double _epsilon = 0.10; // Exploration rate
  static const double _timerStepSeconds = 3.0; // Gradual timer adjustment step

  final Random _random = Random();
  final Map<PerformanceState, Map<AdaptiveAction, double>> _qTable = {};

  // Global observable store for caregiver analytics dashboard
  static final ValueNotifier<List<GamePerformanceRecord>> latestPerformanceRecords =
      ValueNotifier<List<GamePerformanceRecord>>([]);

  void _initQTable() {
    for (final state in PerformanceState.values) {
      _qTable[state] = {};
      for (final action in AdaptiveAction.values) {
        _qTable[state]![action] = _initialQValue(state, action);
      }
    }
  }

  double _initialQValue(PerformanceState state, AdaptiveAction action) {
    switch (state) {
      case PerformanceState.highPerformance:
        if (action == AdaptiveAction.increaseDifficultyReduceTimer) return 0.6;
        if (action == AdaptiveAction.increaseDifficultyMaintainTimer) return 0.4;
        if (action == AdaptiveAction.maintainDifficultyMaintainTimer) return 0.1;
        return -0.2;

      case PerformanceState.goodPerformance:
        if (action == AdaptiveAction.increaseDifficultyMaintainTimer) return 0.5;
        if (action == AdaptiveAction.maintainDifficultyMaintainTimer) return 0.4;
        if (action == AdaptiveAction.increaseDifficultyReduceTimer) return 0.2;
        return 0.0;

      case PerformanceState.challenging:
        if (action == AdaptiveAction.maintainDifficultyIncreaseTimer) return 0.5;
        if (action == AdaptiveAction.maintainDifficultyMaintainTimer) return 0.3;
        if (action == AdaptiveAction.decreaseDifficultyIncreaseTimer) return 0.2;
        return -0.3;

      case PerformanceState.lowPerformance:
        if (action == AdaptiveAction.decreaseDifficultyIncreaseTimer) return 0.6;
        if (action == AdaptiveAction.maintainDifficultyIncreaseTimer) return 0.3;
        return -0.4;
    }
  }

  // ============================================================
  // PERSISTENT GAME STORAGE (SharedPreferences)
  // ============================================================

  static const String _prefixGamePerf = 'cognitive_game_perf_';
  static const String _keyLastPlayedGame = 'cognitive_last_played_game_id';

  /// Saves the final game performance record for a particular game.
  Future<void> saveGamePerformanceRecord(GamePerformanceRecord record) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_prefixGamePerf${record.gameId}', record.encode());
      await prefs.setString(_keyLastPlayedGame, record.gameId);

      // Update global observable store for caregiver dashboard
      final current = List<GamePerformanceRecord>.from(latestPerformanceRecords.value);
      current.removeWhere((r) => r.gameId == record.gameId);
      current.insert(0, record);
      latestPerformanceRecords.value = current;
    } catch (e) {
      debugPrint('Error saving game performance record: $e');
    }
  }

  /// Retrieves the stored final performance record for a particular game.
  Future<GamePerformanceRecord?> getGamePerformanceRecord(String gameId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('$_prefixGamePerf$gameId');
      if (raw != null && raw.isNotEmpty) {
        return GamePerformanceRecord.decode(raw);
      }
    } catch (e) {
      debugPrint('Error retrieving game performance record for $gameId: $e');
    }
    return null;
  }

  /// Retrieves the record of the last played cognitive game.
  Future<GamePerformanceRecord?> getLastPlayedGameRecord() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastGameId = prefs.getString(_keyLastPlayedGame);
      if (lastGameId != null && lastGameId.isNotEmpty) {
        return await getGamePerformanceRecord(lastGameId);
      }
    } catch (e) {
      debugPrint('Error retrieving last played game record: $e');
    }
    return null;
  }

  // ============================================================
  // ENTRY LEVEL & STARTING TIMER DETERMINATION
  // ============================================================

  /// Determines the starting level and starting timer for a game session.
  ///
  /// Requirements:
  /// - First session of a game: timer = 60s, level = 1.
  /// - Return to SAME game: starting timer = stored lastTimerValue (never reset to 60s!), entry level mapped from previous performance.
  /// - Entry into a DIFFERENT game: starting level determined GRADUALLY & CONSERVATIVELY from previous game score (max level 2 or 3). Starting timer = target game's stored timer or 60s if new.
  Future<({int startingLevel, double startingTimer})> determineEntryLevelAndTimer({
    required String targetGameId,
    int maxLevels = 7,
  }) async {
    final targetRecord = await getGamePerformanceRecord(targetGameId);
    final lastPlayedRecord = await getLastPlayedGameRecord();

    // 1. SAME GAME RETURN: Player has played this particular game before
    if (targetRecord != null) {
      final prevScore = targetRecord.finalPerformanceScore;
      final savedTimer = targetRecord.lastTimerValue > 0 ? targetRecord.lastTimerValue : 60.0;

      int entryLevel = 1;
      if (prevScore >= 85.0) {
        entryLevel = 4;
      } else if (prevScore >= 70.0) {
        entryLevel = 3;
      } else if (prevScore >= 40.0) {
        entryLevel = 2;
      } else {
        entryLevel = 1;
      }
      entryLevel = entryLevel.clamp(1, maxLevels);

      return (startingLevel: entryLevel, startingTimer: savedTimer.clamp(15.0, 60.0));
    }

    // 2. DIFFERENT GAME ENTRY: Player hasn't played target game, but played a previous game
    if (lastPlayedRecord != null && lastPlayedRecord.gameId != targetGameId) {
      final prevScore = lastPlayedRecord.finalPerformanceScore;

      // Conservative starting-level mapping for elderly dementia patients (never jump to level 4 or 5!)
      int conservativeLevel = 1;
      if (prevScore >= 80.0) {
        conservativeLevel = 3; // Capped at Level 3 max for new game entry
      } else if (prevScore >= 50.0) {
        conservativeLevel = 2;
      } else {
        conservativeLevel = 1;
      }
      conservativeLevel = conservativeLevel.clamp(1, maxLevels);

      // Target game is new -> initial timer = 60.0s
      return (startingLevel: conservativeLevel, startingTimer: 60.0);
    }

    // 3. FIRST-TIME EVER PLAY OF ANY GAME
    return (startingLevel: 1, startingTimer: 60.0);
  }

  // ============================================================
  // REINFORCEMENT LEARNING ENGINE (Q-Learning)
  // ============================================================

  /// Selects an adaptive action using Epsilon-Greedy strategy.
  AdaptiveAction selectAction(PerformanceState state) {
    final actions = _qTable[state]!;

    // Epsilon exploration
    if (_random.nextDouble() < _epsilon) {
      final all = AdaptiveAction.values.toList()..shuffle(_random);
      return all.first;
    }

    // Exploitation: Select action with maximum Q-value
    var bestAction = AdaptiveAction.maintainDifficultyMaintainTimer;
    var bestValue = actions[bestAction]!;

    for (final entry in actions.entries) {
      if (entry.value > bestValue) {
        bestValue = entry.value;
        bestAction = entry.key;
      }
    }
    return bestAction;
  }

  /// Internal RL Reward signal calculation (NOT shown to patient).
  double computeReward(LevelPerformanceMetrics metrics, AdaptiveAction action) {
    if (metrics.isTimeout || !metrics.isSuccess) {
      return -0.8;
    }

    final acc = metrics.accuracy;
    final util = metrics.timeUtilization;

    if (acc >= 85.0 && util <= 0.85) {
      return 1.0; // Optimal appropriate challenge met
    } else if (acc >= 70.0) {
      return 0.6;
    } else if (acc >= 50.0) {
      return 0.2;
    } else {
      return -0.4;
    }
  }

  /// Updates Q-Table value using standard Q-Learning formula:
  /// Q(s, a) <- Q(s, a) + alpha * [ r + gamma * max_a'(Q(s', a')) - Q(s, a) ]
  void updateQValues(
    PerformanceState state,
    AdaptiveAction action,
    double reward,
    PerformanceState nextState,
  ) {
    final currentQ = _qTable[state]![action]!;
    final nextMaxQ = _qTable[nextState]!.values.reduce(max);

    final updatedQ = currentQ + _alpha * (reward + _gamma * nextMaxQ - currentQ);
    _qTable[state]![action] = updatedQ;
  }

  // ============================================================
  // SESSION LIFECYCLE & LEVEL ADAPTATION
  // ============================================================

  /// Starts a new active gameplay session.
  AdaptiveSessionState startSession({
    required String patientId,
    required String gameId,
    required String gameName,
    required int startingLevel,
    required double startingTimer,
  }) {
    return AdaptiveSessionState(
      patientId: patientId,
      gameId: gameId,
      gameName: gameName,
      currentLevel: startingLevel,
      currentDifficulty: startingLevel,
      currentTimer: startingTimer,
    );
  }

  /// Evaluates level completion metrics, updates cumulative session metrics,
  /// runs Q-Learning RL engine step, and determines next level & timer.
  ({int nextLevel, double nextTimer, AdaptiveAction action, double reward})
      recordLevelCompleted({
    required AdaptiveSessionState session,
    required LevelPerformanceMetrics levelMetrics,
    int maxLevels = 7,
  }) {
    // 1. Record metrics and update cumulative performance
    session.levelHistory.add(levelMetrics);
    final currentState = session.cumulativePerformance.performanceState;
    session.cumulativePerformance.addLevelMetrics(levelMetrics);

    // 2. Select action via Q-Learning
    AdaptiveAction action = selectAction(currentState);

    // Override action for specific edge cases (e.g. timeout or near-timeout)
    if (levelMetrics.isTimeout) {
      action = AdaptiveAction.decreaseDifficultyIncreaseTimer;
    } else if (levelMetrics.timeUtilization >= 0.90) {
      // Finished near the end of timer -> gradually increase timer
      if (action == AdaptiveAction.increaseDifficultyReduceTimer) {
        action = AdaptiveAction.increaseDifficultyMaintainTimer;
      } else if (action == AdaptiveAction.maintainDifficultyMaintainTimer) {
        action = AdaptiveAction.maintainDifficultyIncreaseTimer;
      }
    }

    // 3. Compute reward and update Q-table
    final reward = computeReward(levelMetrics, action);
    final nextState = session.cumulativePerformance.performanceState;
    updateQValues(currentState, action, reward, nextState);

    // 4. Determine next level and next timer gradually
    int nextLevel = session.currentLevel;
    double nextTimer = session.currentTimer;

    switch (action) {
      case AdaptiveAction.increaseDifficultyReduceTimer:
        nextLevel = min(maxLevels, session.currentLevel + 1);
        nextTimer = (session.currentTimer - _timerStepSeconds).clamp(15.0, 60.0);
        break;

      case AdaptiveAction.increaseDifficultyMaintainTimer:
        nextLevel = min(maxLevels, session.currentLevel + 1);
        nextTimer = session.currentTimer.clamp(15.0, 60.0);
        break;

      case AdaptiveAction.maintainDifficultyMaintainTimer:
        nextLevel = session.currentLevel;
        nextTimer = session.currentTimer.clamp(15.0, 60.0);
        break;

      case AdaptiveAction.maintainDifficultyIncreaseTimer:
        nextLevel = session.currentLevel;
        nextTimer = (session.currentTimer + _timerStepSeconds).clamp(15.0, 60.0);
        break;

      case AdaptiveAction.decreaseDifficultyIncreaseTimer:
        nextLevel = max(1, session.currentLevel - 1);
        nextTimer = (session.currentTimer + _timerStepSeconds).clamp(15.0, 60.0);
        break;
    }

    // On successful level completion, ensure progression always advances to higher level (e.g. Level 2 -> Level 3)
    if (levelMetrics.isSuccess && session.currentLevel < maxLevels) {
      nextLevel = min(maxLevels, max(session.currentLevel + 1, nextLevel));
    }

    // Update active session state
    session.currentLevel = nextLevel;
    session.currentDifficulty = nextLevel;
    session.currentTimer = nextTimer.clamp(15.0, 60.0);
    session.lastAction = action;
    session.lastReward = reward;

    return (
      nextLevel: nextLevel,
      nextTimer: nextTimer,
      action: action,
      reward: reward,
    );
  }

  /// Concludes the session, calculates cumulative final performance,
  /// saves particular-game record locally, and dispatches to MongoDB via AnalyticsService.
  Future<GamePerformanceRecord> endSession(AdaptiveSessionState session) async {
    final finalScore = session.cumulativePerformance.cumulativeScore.clamp(0.0, 100.0);
    final finalLevel = session.currentLevel;
    final lastTimer = session.currentTimer;

    final record = GamePerformanceRecord(
      patientId: session.patientId,
      gameId: session.gameId,
      gameName: session.gameName,
      finalPerformanceScore: finalScore,
      finalLevelReached: finalLevel,
      lastTimerValue: lastTimer,
      timestamp: DateTime.now(),
    );

    await saveGamePerformanceRecord(record);

    // Save into MongoDB Atlas via FastAPI AnalyticsService
    final mongoPayload = {
      'patient_id': session.patientId,
      'game_id': session.gameId,
      'game_name': session.gameName,
      'final_performance_score': finalScore,
      'cumulative_accuracy': session.cumulativePerformance.cumulativeAccuracy,
      'cumulative_correct_answers': session.cumulativePerformance.totalCorrectAnswers,
      'cumulative_wrong_answers': session.cumulativePerformance.totalWrongAnswers,
      'average_completion_time': session.cumulativePerformance.averageCompletionTime,
      'final_level_reached': finalLevel,
      'last_timer_used': lastTimer.round(),
      'current_difficulty': session.currentLevel >= 4
          ? 'Hard'
          : (session.currentLevel >= 2 ? 'Medium' : 'Easy'),
      'adaptive_action': _formatAdaptiveAction(session.lastAction),
      'rl_state': _formatPerformanceState(session.cumulativePerformance.performanceState),
      'timestamp': DateTime.now().toUtc().toIso8601String(),
    };

    try {
      await AnalyticsService.instance.recordGamePerformance(mongoPayload);
    } catch (e) {
      debugPrint('Error recording game performance to MongoDB: $e');
    }

    return record;
  }

  String _formatAdaptiveAction(AdaptiveAction? action) {
    switch (action) {
      case AdaptiveAction.increaseDifficultyReduceTimer:
        return 'Increase Difficulty + Reduce Timer';
      case AdaptiveAction.increaseDifficultyMaintainTimer:
        return 'Increase Difficulty + Maintain Timer';
      case AdaptiveAction.maintainDifficultyMaintainTimer:
        return 'Maintain Difficulty + Maintain Timer';
      case AdaptiveAction.maintainDifficultyIncreaseTimer:
        return 'Maintain Difficulty + Increase Timer';
      case AdaptiveAction.decreaseDifficultyIncreaseTimer:
        return 'Decrease Difficulty + Increase Timer';
      case null:
        return 'Maintain Difficulty + Maintain Timer';
    }
  }

  String _formatPerformanceState(PerformanceState state) {
    switch (state) {
      case PerformanceState.highPerformance:
        return 'High Performance';
      case PerformanceState.goodPerformance:
        return 'Good Performance';
      case PerformanceState.challenging:
        return 'Challenging';
      case PerformanceState.lowPerformance:
        return 'Low Performance';
    }
  }
}

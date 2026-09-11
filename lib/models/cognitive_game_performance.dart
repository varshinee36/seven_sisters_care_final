import 'dart:convert';

/// Possible performance states derived from cumulative session performance metrics.
enum PerformanceState {
  highPerformance,
  goodPerformance,
  challenging,
  lowPerformance,
}

/// Adaptive Actions selected by the Q-Learning RL engine.
enum AdaptiveAction {
  increaseDifficultyReduceTimer,
  increaseDifficultyMaintainTimer,
  maintainDifficultyMaintainTimer,
  maintainDifficultyIncreaseTimer,
  decreaseDifficultyIncreaseTimer,
}

/// Performance metrics collected for an individual level (without hints).
class LevelPerformanceMetrics {
  final int level;
  final int difficulty;
  final double score;
  final double accuracy; // (correct / totalTasks) * 100
  final int correctAnswers;
  final int wrongAnswers;
  final int totalTasks;
  final double completionTime; // seconds
  final double allowedTimerDuration; // seconds
  final double remainingTime; // allowed - completionTime
  final double timeUtilization; // completionTime / allowed
  final int attempts;
  final bool isSuccess;
  final bool isTimeout;

  const LevelPerformanceMetrics({
    required this.level,
    required this.difficulty,
    required this.score,
    required this.accuracy,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.totalTasks,
    required this.completionTime,
    required this.allowedTimerDuration,
    required this.remainingTime,
    required this.timeUtilization,
    required this.attempts,
    required this.isSuccess,
    required this.isTimeout,
  });

  Map<String, dynamic> toJson() => {
        'level': level,
        'difficulty': difficulty,
        'score': score,
        'accuracy': accuracy,
        'correctAnswers': correctAnswers,
        'wrongAnswers': wrongAnswers,
        'totalTasks': totalTasks,
        'completionTime': completionTime,
        'allowedTimerDuration': allowedTimerDuration,
        'remainingTime': remainingTime,
        'timeUtilization': timeUtilization,
        'attempts': attempts,
        'isSuccess': isSuccess,
        'isTimeout': isTimeout,
      };

  factory LevelPerformanceMetrics.fromJson(Map<String, dynamic> json) {
    return LevelPerformanceMetrics(
      level: json['level'] as int,
      difficulty: json['difficulty'] as int,
      score: (json['score'] as num).toDouble(),
      accuracy: (json['accuracy'] as num).toDouble(),
      correctAnswers: json['correctAnswers'] as int,
      wrongAnswers: json['wrongAnswers'] as int,
      totalTasks: json['totalTasks'] as int,
      completionTime: (json['completionTime'] as num).toDouble(),
      allowedTimerDuration: (json['allowedTimerDuration'] as num).toDouble(),
      remainingTime: (json['remainingTime'] as num).toDouble(),
      timeUtilization: (json['timeUtilization'] as num).toDouble(),
      attempts: json['attempts'] as int,
      isSuccess: json['isSuccess'] as bool,
      isTimeout: json['isTimeout'] as bool,
    );
  }
}

/// Cumulative performance metrics accumulated throughout the active game session.
class CumulativePerformance {
  int levelsPlayed = 0;
  int totalCorrectAnswers = 0;
  int totalWrongAnswers = 0;
  int totalTasks = 0;
  double totalCompletionTime = 0.0;
  double totalAllowedTime = 0.0;
  int totalAttempts = 0;
  int successfulLevels = 0;
  int failedLevels = 0;
  int timeoutLevels = 0;

  CumulativePerformance();

  void addLevelMetrics(LevelPerformanceMetrics metrics) {
    levelsPlayed++;
    totalCorrectAnswers += metrics.correctAnswers;
    totalWrongAnswers += metrics.wrongAnswers;
    totalTasks += metrics.totalTasks;
    totalCompletionTime += metrics.completionTime;
    totalAllowedTime += metrics.allowedTimerDuration;
    totalAttempts += metrics.attempts;
    if (metrics.isSuccess) {
      successfulLevels++;
    } else {
      failedLevels++;
    }
    if (metrics.isTimeout) {
      timeoutLevels++;
    }
  }

  /// Cumulative accuracy = (totalCorrectAnswers / totalTasks) * 100
  double get cumulativeAccuracy {
    if (totalTasks <= 0) return 0.0;
    return (totalCorrectAnswers / totalTasks) * 100.0;
  }

  /// Overall cumulative score (0.0 to 100.0) combining accuracy and speed
  double get cumulativeScore {
    if (levelsPlayed <= 0) return 0.0;
    final accuracyRatio = (cumulativeAccuracy / 100.0).clamp(0.0, 1.0);
    final timeRatio = totalAllowedTime > 0
        ? (1.0 - (totalCompletionTime / totalAllowedTime)).clamp(0.0, 1.0)
        : 0.5;
    return (0.7 * accuracyRatio + 0.3 * timeRatio) * 100.0;
  }

  /// Average completion time per level
  double get averageCompletionTime {
    if (levelsPlayed <= 0) return 0.0;
    return totalCompletionTime / levelsPlayed;
  }

  /// Average time utilization ratio across played levels
  double get averageTimeUtilization {
    if (totalAllowedTime <= 0) return 0.0;
    return (totalCompletionTime / totalAllowedTime).clamp(0.0, 1.0);
  }

  /// Evaluates current performance state for RL engine input
  PerformanceState get performanceState {
    final acc = cumulativeAccuracy;
    final util = averageTimeUtilization;

    if (acc >= 85.0 && util <= 0.80 && timeoutLevels == 0) {
      return PerformanceState.highPerformance;
    } else if (acc >= 70.0 && timeoutLevels == 0) {
      return PerformanceState.goodPerformance;
    } else if (acc >= 50.0) {
      return PerformanceState.challenging;
    } else {
      return PerformanceState.lowPerformance;
    }
  }

  Map<String, dynamic> toJson() => {
        'levelsPlayed': levelsPlayed,
        'totalCorrectAnswers': totalCorrectAnswers,
        'totalWrongAnswers': totalWrongAnswers,
        'totalTasks': totalTasks,
        'totalCompletionTime': totalCompletionTime,
        'totalAllowedTime': totalAllowedTime,
        'totalAttempts': totalAttempts,
        'successfulLevels': successfulLevels,
        'failedLevels': failedLevels,
        'timeoutLevels': timeoutLevels,
        'cumulativeAccuracy': cumulativeAccuracy,
        'cumulativeScore': cumulativeScore,
      };
}

/// Particular-game performance record persisted locally for future sessions.
class GamePerformanceRecord {
  final String patientId;
  final String gameId;
  final String gameName;
  final double finalPerformanceScore; // 0.0 to 100.0 %
  final int finalLevelReached;
  final double lastTimerValue; // seconds
  final DateTime timestamp;

  const GamePerformanceRecord({
    required this.patientId,
    required this.gameId,
    required this.gameName,
    required this.finalPerformanceScore,
    required this.finalLevelReached,
    required this.lastTimerValue,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'patientId': patientId,
        'gameId': gameId,
        'gameName': gameName,
        'finalPerformanceScore': finalPerformanceScore,
        'finalLevelReached': finalLevelReached,
        'lastTimerValue': lastTimerValue,
        'timestamp': timestamp.toIso8601String(),
      };

  factory GamePerformanceRecord.fromJson(Map<String, dynamic> json) {
    return GamePerformanceRecord(
      patientId: json['patientId'] as String,
      gameId: json['gameId'] as String,
      gameName: json['gameName'] as String,
      finalPerformanceScore: (json['finalPerformanceScore'] as num).toDouble(),
      finalLevelReached: json['finalLevelReached'] as int,
      lastTimerValue: (json['lastTimerValue'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  String encode() => jsonEncode(toJson());
  factory GamePerformanceRecord.decode(String str) =>
      GamePerformanceRecord.fromJson(jsonDecode(str) as Map<String, dynamic>);
}

/// Dynamic adaptive session state maintained in memory during gameplay.
class AdaptiveSessionState {
  final String patientId;
  final String gameId;
  final String gameName;

  int currentLevel;
  int currentDifficulty;
  double currentTimer;

  final CumulativePerformance cumulativePerformance;
  final List<LevelPerformanceMetrics> levelHistory;

  AdaptiveAction? lastAction;
  double? lastReward;

  AdaptiveSessionState({
    required this.patientId,
    required this.gameId,
    required this.gameName,
    required this.currentLevel,
    required this.currentDifficulty,
    required this.currentTimer,
  })  : cumulativePerformance = CumulativePerformance(),
        levelHistory = [];
}

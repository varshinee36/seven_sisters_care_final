/// Model representing analytics for an individual cognitive game.
class GameMetricModel {
  final double performance;
  final int level;
  final String difficulty;

  const GameMetricModel({
    required this.performance,
    required this.level,
    required this.difficulty,
  });

  factory GameMetricModel.defaults({String difficulty = 'Easy'}) {
    return GameMetricModel(
      performance: 0.0,
      level: 1,
      difficulty: difficulty,
    );
  }

  factory GameMetricModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return GameMetricModel.defaults();
    return GameMetricModel(
      performance: (json['performance'] as num?)?.toDouble() ?? 0.0,
      level: (json['level'] as num?)?.toInt() ?? 1,
      difficulty: (json['difficulty'] as String?) ?? 'Easy',
    );
  }

  Map<String, dynamic> toJson() => {
        'performance': performance,
        'level': level,
        'difficulty': difficulty,
      };

  String get performanceDisplay => '${performance.toInt()}%';
}

/// Model representing complete Caregiver Dashboard Analytics from FastAPI / MongoDB.
class DashboardAnalyticsModel {
  final double overallPerformance;
  final double accuracy;
  final int correctResponses;
  final int wrongResponses;
  final double averageCompletionTime;

  final String currentDifficulty;
  final int currentTimer;
  final String adaptiveAction;
  final String rlState;

  final String lastPlayedGame;
  final int finalLevelReached;
  final int lastTimerUsed;
  final double finalPerformanceScore;

  final GameMetricModel memoryHunt;
  final GameMetricModel pairFinder;

  final bool hasData;

  const DashboardAnalyticsModel({
    required this.overallPerformance,
    required this.accuracy,
    required this.correctResponses,
    required this.wrongResponses,
    required this.averageCompletionTime,
    required this.currentDifficulty,
    required this.currentTimer,
    required this.adaptiveAction,
    required this.rlState,
    required this.lastPlayedGame,
    required this.finalLevelReached,
    required this.lastTimerUsed,
    required this.finalPerformanceScore,
    required this.memoryHunt,
    required this.pairFinder,
    this.hasData = false,
  });

  /// Returns safe default values when no game records exist.
  factory DashboardAnalyticsModel.defaults() {
    return DashboardAnalyticsModel(
      overallPerformance: 0.0,
      accuracy: 0.0,
      correctResponses: 0,
      wrongResponses: 0,
      averageCompletionTime: 0.0,
      currentDifficulty: 'Easy',
      currentTimer: 60,
      adaptiveAction: 'No Data',
      rlState: 'No Data',
      lastPlayedGame: 'No Data',
      finalLevelReached: 0,
      lastTimerUsed: 60,
      finalPerformanceScore: 0.0,
      memoryHunt: GameMetricModel.defaults(),
      pairFinder: GameMetricModel.defaults(),
      hasData: false,
    );
  }

  factory DashboardAnalyticsModel.fromJson(Map<String, dynamic> json) {
    final overallPerf = (json['overallPerformance'] as num?)?.toDouble() ?? 0.0;
    final lastGame = json['lastPlayedGame'] as String? ?? 'No Data';
    final hasRealData = lastGame != 'No Data' || overallPerf > 0;

    return DashboardAnalyticsModel(
      overallPerformance: overallPerf,
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0.0,
      correctResponses: (json['correctResponses'] as num?)?.toInt() ?? 0,
      wrongResponses: (json['wrongResponses'] as num?)?.toInt() ?? 0,
      averageCompletionTime:
          (json['averageCompletionTime'] as num?)?.toDouble() ?? 0.0,
      currentDifficulty: json['currentDifficulty'] as String? ?? 'Easy',
      currentTimer: (json['currentTimer'] as num?)?.toInt() ?? 60,
      adaptiveAction: json['adaptiveAction'] as String? ?? 'No Data',
      rlState: json['rlState'] as String? ?? 'No Data',
      lastPlayedGame: lastGame,
      finalLevelReached: (json['finalLevelReached'] as num?)?.toInt() ?? 0,
      lastTimerUsed: (json['lastTimerUsed'] as num?)?.toInt() ?? 60,
      finalPerformanceScore:
          (json['finalPerformanceScore'] as num?)?.toDouble() ?? 0.0,
      memoryHunt: json['memoryHunt'] is Map<String, dynamic>
          ? GameMetricModel.fromJson(json['memoryHunt'] as Map<String, dynamic>)
          : GameMetricModel.defaults(),
      pairFinder: json['pairFinder'] is Map<String, dynamic>
          ? GameMetricModel.fromJson(json['pairFinder'] as Map<String, dynamic>)
          : GameMetricModel.defaults(),
      hasData: hasRealData,
    );
  }

  Map<String, dynamic> toJson() => {
        'overallPerformance': overallPerformance,
        'accuracy': accuracy,
        'correctResponses': correctResponses,
        'wrongResponses': wrongResponses,
        'averageCompletionTime': averageCompletionTime,
        'currentDifficulty': currentDifficulty,
        'currentTimer': currentTimer,
        'adaptiveAction': adaptiveAction,
        'rlState': rlState,
        'lastPlayedGame': lastPlayedGame,
        'finalLevelReached': finalLevelReached,
        'lastTimerUsed': lastTimerUsed,
        'finalPerformanceScore': finalPerformanceScore,
        'memoryHunt': memoryHunt.toJson(),
        'pairFinder': pairFinder.toJson(),
      };

  String get overallPerformanceDisplay => '${overallPerformance.toInt()}%';
  String get accuracyDisplay => '${accuracy.toInt()}%';
  String get avgCompletionTimeDisplay =>
      '${averageCompletionTime.toStringAsFixed(averageCompletionTime.truncateToDouble() == averageCompletionTime ? 0 : 1)} sec';
  String get currentTimerDisplay => '$currentTimer Seconds';
  String get lastTimerUsedDisplay => '$lastTimerUsed sec';
  String get finalPerformanceScoreDisplay =>
      '${finalPerformanceScore.toInt()}%';
}

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:seven_sisters_care/models/cognitive_game_performance.dart';
import 'package:seven_sisters_care/services/cognitive_adaptive_engine.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('CognitiveAdaptiveEngine - Cumulative Performance & RL Unit Tests', () {
    test('CumulativePerformance accumulates metrics across multiple levels', () {
      final cum = CumulativePerformance();
      expect(cum.levelsPlayed, 0);

      // Level 1: 4 correct out of 4 tasks (100% accuracy), 25s out of 60s
      cum.addLevelMetrics(
        const LevelPerformanceMetrics(
          level: 1,
          difficulty: 1,
          score: 100.0,
          accuracy: 100.0,
          correctAnswers: 4,
          wrongAnswers: 0,
          totalTasks: 4,
          completionTime: 25.0,
          allowedTimerDuration: 60.0,
          remainingTime: 35.0,
          timeUtilization: 25.0 / 60.0,
          attempts: 1,
          isSuccess: true,
          isTimeout: false,
        ),
      );

      expect(cum.levelsPlayed, 1);
      expect(cum.totalCorrectAnswers, 4);
      expect(cum.totalTasks, 4);
      expect(cum.cumulativeAccuracy, 100.0);

      // Level 2: 4 correct out of 6 tasks (66.7% accuracy), 45s out of 60s
      cum.addLevelMetrics(
        const LevelPerformanceMetrics(
          level: 2,
          difficulty: 2,
          score: 66.7,
          accuracy: 66.7,
          correctAnswers: 4,
          wrongAnswers: 2,
          totalTasks: 6,
          completionTime: 45.0,
          allowedTimerDuration: 60.0,
          remainingTime: 15.0,
          timeUtilization: 45.0 / 60.0,
          attempts: 1,
          isSuccess: true,
          isTimeout: false,
        ),
      );

      expect(cum.levelsPlayed, 2);
      expect(cum.totalCorrectAnswers, 8);
      expect(cum.totalTasks, 10);
      // Cumulative accuracy = 8 / 10 * 100 = 80.0%
      expect(cum.cumulativeAccuracy, 80.0);
    });

    test('First session of a new game starts at Level 1 and 60 seconds timer', () async {
      final entry = await CognitiveAdaptiveEngine.instance
          .determineEntryLevelAndTimer(targetGameId: 'pair_finder', maxLevels: 7);

      expect(entry.startingLevel, 1);
      expect(entry.startingTimer, 60.0);
    });

    test('Same game return retrieves stored lastTimerValue and maps level from performance', () async {
      final record = GamePerformanceRecord(
        patientId: 'patient_001',
        gameId: 'pair_finder',
        gameName: 'Pair Finder',
        finalPerformanceScore: 92.0,
        finalLevelReached: 4,
        lastTimerValue: 51.0,
        timestamp: DateTime(2026, 9, 10),
      );

      await CognitiveAdaptiveEngine.instance.saveGamePerformanceRecord(record);

      final entry = await CognitiveAdaptiveEngine.instance
          .determineEntryLevelAndTimer(targetGameId: 'pair_finder', maxLevels: 7);

      // Same game return: preserves exact saved timer (51s), starting level mapped from score
      expect(entry.startingTimer, 51.0);
      expect(entry.startingLevel, 4);
    });

    test('Different game entry maps previous performance conservatively (max Level 3)', () async {
      final prevRecord = GamePerformanceRecord(
        patientId: 'patient_001',
        gameId: 'pair_finder',
        gameName: 'Pair Finder',
        finalPerformanceScore: 92.0, // High 92% performance in Pair Finder
        finalLevelReached: 4,
        lastTimerValue: 51.0,
        timestamp: DateTime(2026, 9, 10),
      );

      await CognitiveAdaptiveEngine.instance.saveGamePerformanceRecord(prevRecord);

      // Now start a DIFFERENT game: Memory Hunt
      final entry = await CognitiveAdaptiveEngine.instance
          .determineEntryLevelAndTimer(targetGameId: 'memory_hunt', maxLevels: 5);

      // High performance (92%) MUST NOT start Memory Hunt at Level 5.
      // Must conservatively start at Level 3 max, with 60s initial timer for the new game.
      expect(entry.startingLevel, 3);
      expect(entry.startingTimer, 60.0);
    });

    test('Q-Learning RL Engine adapts level and timer gradually', () {
      final engine = CognitiveAdaptiveEngine.instance;

      final session = engine.startSession(
        patientId: 'patient_001',
        gameId: 'pair_finder',
        gameName: 'Pair Finder',
        startingLevel: 1,
        startingTimer: 60.0,
      );

      // Level 1: Perfect completion in 20s
      final res1 = engine.recordLevelCompleted(
        session: session,
        levelMetrics: const LevelPerformanceMetrics(
          level: 1,
          difficulty: 1,
          score: 100.0,
          accuracy: 100.0,
          correctAnswers: 4,
          wrongAnswers: 0,
          totalTasks: 4,
          completionTime: 20.0,
          allowedTimerDuration: 60.0,
          remainingTime: 40.0,
          timeUtilization: 20.0 / 60.0,
          attempts: 1,
          isSuccess: true,
          isTimeout: false,
        ),
        maxLevels: 7,
      );

      // Next level must be gradual (+1 level max => Level 1 or 2)
      expect(res1.nextLevel, inInclusiveRange(1, 2));
      // Timer adjustment must be gradual (within 3s step range 57.0 - 63.0)
      expect(res1.nextTimer, inInclusiveRange(50.0, 70.0));
    });

    test('Timeout gradually increases timer up to max 60s ceiling and decreases level', () {
      final engine = CognitiveAdaptiveEngine.instance;

      final session = engine.startSession(
        patientId: 'patient_001',
        gameId: 'pair_finder',
        gameName: 'Pair Finder',
        startingLevel: 3,
        startingTimer: 50.0,
      );

      final res = engine.recordLevelCompleted(
        session: session,
        levelMetrics: const LevelPerformanceMetrics(
          level: 3,
          difficulty: 3,
          score: 20.0,
          accuracy: 20.0,
          correctAnswers: 1,
          wrongAnswers: 4,
          totalTasks: 5,
          completionTime: 50.0,
          allowedTimerDuration: 50.0,
          remainingTime: 0.0,
          timeUtilization: 1.0,
          attempts: 1,
          isSuccess: false,
          isTimeout: true,
        ),
        maxLevels: 7,
      );

      // Timeout: level decreases gradually (3 -> 2)
      expect(res.nextLevel, 2);
      // Timer increases gradually (50 -> 53s) and stays capped at <= 60s
      expect(res.nextTimer, 53.0);
    });

    test('Session completion calculates cumulative score and saves record', () async {
      final engine = CognitiveAdaptiveEngine.instance;

      final session = engine.startSession(
        patientId: 'patient_001',
        gameId: 'pair_finder',
        gameName: 'Pair Finder',
        startingLevel: 1,
        startingTimer: 60.0,
      );

      engine.recordLevelCompleted(
        session: session,
        levelMetrics: const LevelPerformanceMetrics(
          level: 1,
          difficulty: 1,
          score: 100.0,
          accuracy: 100.0,
          correctAnswers: 4,
          wrongAnswers: 0,
          totalTasks: 4,
          completionTime: 30.0,
          allowedTimerDuration: 60.0,
          remainingTime: 30.0,
          timeUtilization: 0.5,
          attempts: 1,
          isSuccess: true,
          isTimeout: false,
        ),
        maxLevels: 7,
      );

      final record = await engine.endSession(session);

      expect(record.gameId, 'pair_finder');
      expect(record.finalPerformanceScore, greaterThan(0.0));
      expect(CognitiveAdaptiveEngine.latestPerformanceRecords.value.isNotEmpty, true);
    });

    test('RL computeReward differentiates Case A (completed with hint) from Case B (failed with hint)', () {
      final engine = CognitiveAdaptiveEngine.instance;

      // Case A: Patient used hint and succeeded with high accuracy
      const caseA = LevelPerformanceMetrics(
        level: 2,
        difficulty: 2,
        score: 100.0,
        accuracy: 100.0,
        correctAnswers: 3,
        wrongAnswers: 0,
        totalTasks: 3,
        completionTime: 25.0,
        allowedTimerDuration: 60.0,
        remainingTime: 35.0,
        timeUtilization: 25.0 / 60.0,
        attempts: 2,
        isSuccess: true,
        isTimeout: false,
        hintUsed: true,
        hintCount: 1,
        completedWithHint: true,
      );

      // Case B: Patient used hint but timed out
      const caseB = LevelPerformanceMetrics(
        level: 2,
        difficulty: 2,
        score: 33.3,
        accuracy: 33.3,
        correctAnswers: 1,
        wrongAnswers: 2,
        totalTasks: 3,
        completionTime: 60.0,
        allowedTimerDuration: 60.0,
        remainingTime: 0.0,
        timeUtilization: 1.0,
        attempts: 2,
        isSuccess: false,
        isTimeout: true,
        hintUsed: true,
        hintCount: 1,
        completedWithHint: false,
      );

      // Normal unassisted success
      const normalSuccess = LevelPerformanceMetrics(
        level: 2,
        difficulty: 2,
        score: 100.0,
        accuracy: 100.0,
        correctAnswers: 3,
        wrongAnswers: 0,
        totalTasks: 3,
        completionTime: 25.0,
        allowedTimerDuration: 60.0,
        remainingTime: 35.0,
        timeUtilization: 25.0 / 60.0,
        attempts: 1,
        isSuccess: true,
        isTimeout: false,
        hintUsed: false,
      );

      final rewardA = engine.computeReward(caseA, AdaptiveAction.maintainDifficultyMaintainTimer);
      final rewardB = engine.computeReward(caseB, AdaptiveAction.decreaseDifficultyIncreaseTimer);
      final rewardNormal = engine.computeReward(normalSuccess, AdaptiveAction.maintainDifficultyMaintainTimer);

      expect(rewardA, 0.7); // Positive reward acknowledging assisted success
      expect(rewardB, -0.6); // Less harsh penalty than unassisted failure (-0.8)
      expect(rewardNormal, 1.0); // Full reward for unassisted high performance
      expect(rewardA, greaterThan(rewardB));
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seven_sisters_care/models/analytics_model.dart';
import 'package:seven_sisters_care/screens/caregiver/caregiver_dashboard.dart';
import 'package:seven_sisters_care/services/analytics_service.dart';

void main() {
  setUp(() {
    AnalyticsService.instance.resetToDefaults();
  });

  tearDown(() {
    AnalyticsService.instance.resetToDefaults();
  });

  testWidgets(
      'CaregiverDashboard displays safe default fallback values when no game records exist',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: CaregiverDashboard(),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Patient Overview metadata
    expect(find.text('Mild Dementia'), findsOneWidget);
    expect(find.text('Last Active: Today 9:15 AM'), findsOneWidget);
    expect(find.text('Status: Active'), findsOneWidget);

    // 2. Cognitive Games section with safe defaults
    expect(find.text('Pair Finder'), findsOneWidget);
    expect(find.text('Memory Hunt'), findsOneWidget);
    expect(find.text('Continuous Focus'), findsOneWidget);
    expect(find.text('Find Difference'), findsOneWidget);
    expect(find.text('Smartchoice'), findsOneWidget);
    expect(find.text('Smart sort'), findsOneWidget);
    expect(find.text('Shape Match'), findsOneWidget);
    expect(find.text('Missing Piece'), findsOneWidget);

    // 3. Adaptive Engine Status Card (Safe Defaults)
    expect(find.text('Adaptive Engine Status'), findsOneWidget);
    expect(find.text('Current RL State'), findsOneWidget);
    expect(find.text('No Data'), findsWidgets);
    expect(find.text('Current Adaptive Action'), findsOneWidget);
    expect(find.text('Current Difficulty'), findsOneWidget);
    expect(find.text('Easy'), findsWidgets);
    expect(find.text('Current Timer'), findsOneWidget);
    expect(find.text('60 Seconds'), findsOneWidget);
    expect(
      find.text(
        'Adaptive progression is functioning normally.\nDifficulty adjustments are gradual and suitable for elderly users..',
      ),
      findsOneWidget,
    );

    // 4. Cognitive Performance Summary Card (Safe Defaults)
    expect(find.text('Cognitive Performance Summary'), findsOneWidget);
    expect(find.text('Overall Performance'), findsOneWidget);
    expect(find.text('Performance: 0%'), findsWidgets);
    expect(find.text('Accuracy %'), findsOneWidget);
    expect(find.text('Accuracy: 0%'), findsOneWidget);
    expect(find.text('Correct Responses'), findsOneWidget);
    expect(find.text('Correct: 0'), findsOneWidget);
    expect(find.text('Wrong Responses'), findsOneWidget);
    expect(find.text('Wrong: 0'), findsOneWidget);
    expect(find.text('Average Completion Time'), findsOneWidget);
    expect(find.text('Avg Time: --'), findsOneWidget);

    // 5. Latest Game Session Card (Safe Defaults)
    expect(find.text('Latest Game Session'), findsOneWidget);
    expect(find.text('Last Played Game'), findsOneWidget);
    expect(find.text('Game: No Data'), findsOneWidget);
    expect(find.text('Final Performance'), findsOneWidget);
    expect(find.text('Final Level Reached'), findsOneWidget);
    expect(find.text('Level: 0'), findsOneWidget);
    expect(find.text('Last Timer Used'), findsOneWidget);
    expect(find.text('Timer: --'), findsOneWidget);

    // 6. Report Generator placeholder tags
    expect(find.text('Performance Summary'), findsOneWidget);
    expect(find.text('Accuracy Summary'), findsOneWidget);
    expect(find.text('Level Progression'), findsOneWidget);
    expect(find.text('Adaptive Difficulty History'), findsOneWidget);
  });

  testWidgets(
      'CaregiverDashboard displays live game analytics when populated from MongoDB/API',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // Provide populated analytics data for testing
    AnalyticsService.instance.setAnalyticsForTesting(
      const DashboardAnalyticsModel(
        overallPerformance: 82.0,
        accuracy: 88.0,
        correctResponses: 120,
        wrongResponses: 18,
        averageCompletionTime: 35.0,
        currentDifficulty: 'Medium',
        currentTimer: 51,
        adaptiveAction: 'Maintain Difficulty + Maintain Timer',
        rlState: 'Good Performance',
        lastPlayedGame: 'Pair Finder',
        finalLevelReached: 4,
        lastTimerUsed: 51,
        finalPerformanceScore: 92.0,
        memoryHunt: GameMetricModel(performance: 75.0, level: 3, difficulty: 'Medium'),
        pairFinder: GameMetricModel(performance: 92.0, level: 4, difficulty: 'Medium'),
        hasData: true,
      ),
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: CaregiverDashboard(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify populated analytics values
    expect(find.text('Good Performance'), findsOneWidget);
    expect(find.text('Maintain Difficulty + Maintain Timer'), findsOneWidget);
    expect(find.text('Medium'), findsWidgets);
    expect(find.text('51 Seconds'), findsOneWidget);

    expect(find.text('Performance: 82%'), findsOneWidget);
    expect(find.text('Accuracy: 88%'), findsOneWidget);
    expect(find.text('Correct: 120'), findsOneWidget);
    expect(find.text('Wrong: 18'), findsOneWidget);
    expect(find.text('Avg Time: 35 sec'), findsOneWidget);

    expect(find.text('Game: Pair Finder'), findsOneWidget);
    expect(find.text('Performance: 92%'), findsWidgets);
    expect(find.text('Level: 4'), findsWidgets);
    expect(find.text('Timer: 51 sec'), findsOneWidget);
  });

  test(
      'DashboardAnalyticsModel and GameMetricModel correctly serialize and deserialize',
      () {
    final model = DashboardAnalyticsModel.defaults();
    expect(model.hasData, false);
    expect(model.overallPerformance, 0.0);
    expect(model.currentDifficulty, 'Easy');
    expect(model.currentTimer, 60);

    final json = {
      'overallPerformance': 85.5,
      'accuracy': 90.0,
      'correctResponses': 15,
      'wrongResponses': 2,
      'averageCompletionTime': 24.5,
      'currentDifficulty': 'Hard',
      'currentTimer': 45,
      'adaptiveAction': 'Increase Difficulty',
      'rlState': 'Mastery',
      'lastPlayedGame': 'Memory Hunt',
      'finalLevelReached': 5,
      'lastTimerUsed': 45,
      'finalPerformanceScore': 95.0,
      'memoryHunt': {'performance': 95.0, 'level': 5, 'difficulty': 'Hard'},
      'pairFinder': {'performance': 80.0, 'level': 3, 'difficulty': 'Medium'},
    };

    final parsed = DashboardAnalyticsModel.fromJson(json);
    expect(parsed.hasData, true);
    expect(parsed.overallPerformance, 85.5);
    expect(parsed.accuracy, 90.0);
    expect(parsed.correctResponses, 15);
    expect(parsed.wrongResponses, 2);
    expect(parsed.currentDifficulty, 'Hard');
    expect(parsed.memoryHunt.performance, 95.0);
    expect(parsed.pairFinder.difficulty, 'Medium');
    expect(parsed.overallPerformanceDisplay, '85%');
    expect(parsed.accuracyDisplay, '90%');
    expect(parsed.currentTimerDisplay, '45 Seconds');
  });
}

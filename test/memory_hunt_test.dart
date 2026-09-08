import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seven_sisters_care/screens/patient/memory_hunt_data.dart';
import 'package:seven_sisters_care/screens/patient/memory_hunt_screen.dart';

void main() {
  group('Memory Hunt Levels & Data Tests', () {
    test('Verify 5 levels with exact requested object counts', () {
      expect(MemoryHuntCatalog.levels.length, 5);

      // Level 1: 3 images
      expect(MemoryHuntCatalog.levels[0].levelNumber, 1);
      expect(MemoryHuntCatalog.levels[0].memorizeItems.length, 3);
      expect(MemoryHuntCatalog.levels[0].targetIds.length, 3);
      expect(MemoryHuntCatalog.levels[0].hints.length, 3);

      // Level 2: 5 images
      expect(MemoryHuntCatalog.levels[1].levelNumber, 2);
      expect(MemoryHuntCatalog.levels[1].memorizeItems.length, 5);
      expect(MemoryHuntCatalog.levels[1].targetIds.length, 5);
      expect(MemoryHuntCatalog.levels[1].hints.length, 3);

      // Level 3: 7 images
      expect(MemoryHuntCatalog.levels[2].levelNumber, 3);
      expect(MemoryHuntCatalog.levels[2].memorizeItems.length, 7);
      expect(MemoryHuntCatalog.levels[2].targetIds.length, 7);
      expect(MemoryHuntCatalog.levels[2].hints.length, 3);

      // Level 4: 8 images
      expect(MemoryHuntCatalog.levels[3].levelNumber, 4);
      expect(MemoryHuntCatalog.levels[3].memorizeItems.length, 8);
      expect(MemoryHuntCatalog.levels[3].targetIds.length, 8);
      expect(MemoryHuntCatalog.levels[3].hints.length, 3);

      // Level 5: 10 images
      expect(MemoryHuntCatalog.levels[4].levelNumber, 5);
      expect(MemoryHuntCatalog.levels[4].memorizeItems.length, 10);
      expect(MemoryHuntCatalog.levels[4].targetIds.length, 10);
      expect(MemoryHuntCatalog.levels[4].hints.length, 3);
    });

    test('All answer items contain target items plus distractors', () {
      for (final level in MemoryHuntCatalog.levels) {
        expect(level.answerItems.length, greaterThan(level.memorizeItems.length));
        final answerIds = level.answerItems.map((e) => e.id).toSet();
        expect(answerIds.containsAll(level.targetIds), isTrue);
      }
    });
  });

  group('Memory Hunt Game Widget Tests', () {
    testWidgets('Starts in Memorize step at Level 1 with 3 objects',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MemoryHuntScreen(),
        ),
      );

      expect(find.text('Memory Hunt'), findsWidgets);
      expect(find.text('Level 1 of 5'), findsOneWidget);
      expect(find.text('Please remember these 3 objects'), findsOneWidget);

      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('Advances through Ready to Answer view and submits wrong answer',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MemoryHuntScreen(),
        ),
      );

      // Fast-forward memorize step (30s)
      await tester.pump(const Duration(seconds: 30));
      await tester.pump(const Duration(milliseconds: 100));

      // In Ready step
      expect(find.text('Get Ready'), findsOneWidget);

      // Fast-forward ready step (6s)
      await tester.pump(const Duration(seconds: 6));
      await tester.pump(const Duration(milliseconds: 100));

      // Now in Answer step
      expect(find.textContaining('Select the 3 objects you saw earlier'), findsOneWidget);
      expect(find.text('Hint (3)'), findsOneWidget);
      expect(find.text('Submit'), findsOneWidget);

      // Submit with no selection (wrong answer)
      await tester.tap(find.text('Submit'));
      await tester.pump(const Duration(milliseconds: 400));

      // Verifies "Try Again!" dialog appears because hints remaining is 3
      expect(find.text('Try Again!'), findsOneWidget);
      expect(find.textContaining('You have 3 hints remaining'), findsWidgets);
      expect(find.text('Use Hint (3 left)'), findsOneWidget);

      // Tap "Use Hint (3 left)"
      await tester.tap(find.text('Use Hint (3 left)'));
      await tester.pump(const Duration(milliseconds: 400));

      // Hint 1 dialog should appear
      expect(find.text('Hint 1 of 3'), findsOneWidget);
      expect(find.text('Got It'), findsOneWidget);

      // Dismiss hint dialog
      await tester.tap(find.text('Got It'));
      await tester.pump(const Duration(milliseconds: 400));

      // Let SnackBar clear
      await tester.pump(const Duration(seconds: 4));

      // Now hints remaining should be 2
      expect(find.text('Hint (2)'), findsOneWidget);
    });

    testWidgets('Exhausting 3 hints then wrong answer shows Failure dialog',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MemoryHuntScreen(),
        ),
      );

      // Advance to answer view (30s + 6s)
      await tester.pump(const Duration(seconds: 36));
      await tester.pump(const Duration(milliseconds: 100));

      // Use Hint 1
      await tester.tap(find.text('Hint (3)'));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(find.text('Got It'));
      await tester.pump(const Duration(milliseconds: 400));
      ScaffoldMessenger.of(tester.element(find.byType(Scaffold))).clearSnackBars();
      await tester.pump(const Duration(milliseconds: 400));

      // Use Hint 2
      await tester.tap(find.text('Hint (2)'));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(find.text('Got It'));
      await tester.pump(const Duration(milliseconds: 400));
      ScaffoldMessenger.of(tester.element(find.byType(Scaffold))).clearSnackBars();
      await tester.pump(const Duration(milliseconds: 400));

      // Use Hint 3
      await tester.tap(find.text('Hint (1)'));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(find.text('Got It'));
      await tester.pump(const Duration(milliseconds: 400));
      ScaffoldMessenger.of(tester.element(find.byType(Scaffold))).clearSnackBars();
      await tester.pump(const Duration(milliseconds: 400));

      // 0 hints remaining
      expect(find.text('Hint (0)'), findsOneWidget);

      // Submit wrong answer
      await tester.tap(find.text('Submit'));
      await tester.pump(const Duration(milliseconds: 400));

      // Failure dialog appears because 0 hints left
      expect(find.text('Good Try!'), findsOneWidget);
      expect(find.textContaining('All 3 hints have finished for this level.'), findsOneWidget);
      expect(find.text('Retry Level'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);

      await tester.pump(const Duration(seconds: 4));
    });

    testWidgets('Correct answer advances to Level 2 (5 objects)',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MemoryHuntScreen(),
        ),
      );

      // Advance to answer view
      await tester.pump(const Duration(seconds: 36));
      await tester.pump(const Duration(milliseconds: 100));

      // Select the 3 correct objects: Apple, Book, Ball
      await tester.tap(find.text('Apple'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.text('Book'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.text('Ball'));
      await tester.pump(const Duration(milliseconds: 100));

      // Submit
      await tester.tap(find.text('Submit'));
      await tester.pump(const Duration(milliseconds: 400));

      // Success dialog appears
      expect(find.text('Well Done!'), findsOneWidget);
      expect(find.text('Next Level'), findsOneWidget);

      // Tap Next Level
      await tester.tap(find.text('Next Level'));
      await tester.pump(const Duration(milliseconds: 400));

      // Now at Level 2 of 5 with 5 objects!
      expect(find.text('Level 2 of 5'), findsOneWidget);
      expect(find.text('Please remember these 5 objects'), findsOneWidget);

      await tester.pump(const Duration(seconds: 4));
    });
  });
}

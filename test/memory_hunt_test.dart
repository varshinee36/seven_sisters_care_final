import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:seven_sisters_care/screens/patient/memory_hunt_data.dart';
import 'package:seven_sisters_care/screens/patient/memory_hunt_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Memory Hunt Levels & Data Tests', () {
    test('Verify 5 levels with exact requested object counts', () {
      expect(MemoryHuntCatalog.levels.length, 5);

      // Level 1: 3 images
      expect(MemoryHuntCatalog.levels[0].levelNumber, 1);
      expect(MemoryHuntCatalog.levels[0].memorizeItems.length, 3);
      expect(MemoryHuntCatalog.levels[0].targetIds.length, 3);

      // Level 2: 5 images
      expect(MemoryHuntCatalog.levels[1].levelNumber, 2);
      expect(MemoryHuntCatalog.levels[1].memorizeItems.length, 5);
      expect(MemoryHuntCatalog.levels[1].targetIds.length, 5);

      // Level 3: 7 images
      expect(MemoryHuntCatalog.levels[2].levelNumber, 3);
      expect(MemoryHuntCatalog.levels[2].memorizeItems.length, 7);
      expect(MemoryHuntCatalog.levels[2].targetIds.length, 7);

      // Level 4: 8 images
      expect(MemoryHuntCatalog.levels[3].levelNumber, 4);
      expect(MemoryHuntCatalog.levels[3].memorizeItems.length, 8);
      expect(MemoryHuntCatalog.levels[3].targetIds.length, 8);

      // Level 5: 10 images
      expect(MemoryHuntCatalog.levels[4].levelNumber, 5);
      expect(MemoryHuntCatalog.levels[4].memorizeItems.length, 10);
      expect(MemoryHuntCatalog.levels[4].targetIds.length, 10);
    });

    test('All answer items contain target items plus distractors', () {
      for (final level in MemoryHuntCatalog.levels) {
        expect(level.answerItems.length, greaterThan(level.memorizeItems.length));
        final answerIds = level.answerItems.map((e) => e.id).toSet();
        expect(answerIds.containsAll(level.targetIds), isTrue);
      }
    });
  });

  group('Memory Hunt Game Widget Tests (No Hints & Timer Adaptive Engine)', () {
    testWidgets('Starts in Memorize step with countdown timer and no hints button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MemoryHuntScreen(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Memory Hunt'), findsWidgets);
      expect(find.textContaining('Level'), findsWidgets);
      expect(find.textContaining('Please remember'), findsOneWidget);
      expect(find.textContaining('Timer :'), findsWidgets);
      expect(find.textContaining('Hint'), findsNothing);
    });

    testWidgets('Advances from Memorize to Answer view when timer completes',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MemoryHuntScreen(),
        ),
      );
      await tester.pump();

      // Fast-forward memorization timer (30s) + ready step (6s)
      await tester.pump(const Duration(seconds: 31));
      await tester.pump(const Duration(seconds: 7));
      await tester.pump(const Duration(milliseconds: 200));

      // Now in Answer view without hints
      expect(find.textContaining('Select the'), findsOneWidget);
      expect(find.text('Submit'), findsOneWidget);
      expect(find.textContaining('Hint'), findsNothing);
      expect(find.textContaining('Timer :'), findsWidgets);
    });

    testWidgets('Submitting wrong answer shows Wrong Answer dialog with Back to Games button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MemoryHuntScreen(),
        ),
      );
      await tester.pump();

      // Fast-forward memorization timer + ready step
      await tester.pump(const Duration(seconds: 31));
      await tester.pump(const Duration(seconds: 7));
      await tester.pump(const Duration(milliseconds: 200));

      // Submit with no items selected (0/3 correct)
      await tester.tap(find.text('Submit'));
      await tester.pump(const Duration(milliseconds: 500));

      // Shows Wrong Answer dialog with Back to Games button
      expect(find.text('Wrong Answer!'), findsOneWidget);
      expect(find.text('Back to Games'), findsOneWidget);
    });

    testWidgets('Correct target selections auto-submits and auto-advances to next higher level',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MemoryHuntScreen(),
        ),
      );
      await tester.pump();

      // Fast-forward memorization timer + ready step
      await tester.pump(const Duration(seconds: 31));
      await tester.pump(const Duration(seconds: 7));
      await tester.pump(const Duration(milliseconds: 200));

      // Select target items for Level 1: Apple, Book, Ball -> Auto submits on 3rd correct item!
      await tester.tap(find.text('Apple'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.text('Book'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.text('Ball'));
      await tester.pump(const Duration(milliseconds: 500));

      // Auto-advanced directly to Level 2 (5 objects) without intermediate Well Done popup
      expect(find.text('Level 2 of 5'), findsOneWidget);
      expect(find.text('Please remember these 5 objects'), findsOneWidget);
    });
  });
}

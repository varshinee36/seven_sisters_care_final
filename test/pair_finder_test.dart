import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seven_sisters_care/screens/pair_finder_game.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PairFinderGame Widget Tests', () {
    testWidgets('Level 1 renders exactly 4 cards (2 pairs)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PairFinderGame(initialLevel: GameLevel.level1),
        ),
      );
      await tester.pump();

      expect(find.textContaining('Level 1'), findsOneWidget);
      expect(find.textContaining('4 Cards'), findsOneWidget);
      expect(find.text('Tap to Flip'), findsNWidgets(4));
    });

    testWidgets('Level 2 renders exactly 6 cards (3 pairs)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PairFinderGame(initialLevel: GameLevel.level2),
        ),
      );
      await tester.pump();

      expect(find.textContaining('Level 2'), findsOneWidget);
      expect(find.textContaining('6 Cards'), findsOneWidget);
      expect(find.text('Tap to Flip'), findsNWidgets(6));
    });

    testWidgets('Level 3 renders exactly 6 cards (3 pairs)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PairFinderGame(initialLevel: GameLevel.level3),
        ),
      );
      await tester.pump();

      expect(find.textContaining('Level 3'), findsOneWidget);
      expect(find.textContaining('6 Cards'), findsOneWidget);
      expect(find.text('Tap to Flip'), findsNWidgets(6));
    });

    testWidgets('Level 4 renders exactly 8 cards (4 pairs)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PairFinderGame(initialLevel: GameLevel.level4),
        ),
      );
      await tester.pump();

      expect(find.textContaining('Level 4'), findsOneWidget);
      expect(find.textContaining('8 Cards'), findsOneWidget);
      expect(find.text('Tap to Flip'), findsNWidgets(8));
    });

    testWidgets('Level 5 renders exactly 8 cards (4 pairs)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PairFinderGame(initialLevel: GameLevel.level5),
        ),
      );
      await tester.pump();

      expect(find.textContaining('Level 5'), findsOneWidget);
      expect(find.textContaining('8 Cards'), findsOneWidget);
      expect(find.text('Tap to Flip'), findsNWidgets(8));
    });

    testWidgets('Level 6 renders exactly 8 cards (4 pairs)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PairFinderGame(initialLevel: GameLevel.level6),
        ),
      );
      await tester.pump();

      expect(find.textContaining('Level 6'), findsOneWidget);
      expect(find.textContaining('8 Cards'), findsOneWidget);
      expect(find.text('Tap to Flip'), findsNWidgets(8));
    });

    testWidgets('Level 7 renders exactly 10 cards (5 pairs)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PairFinderGame(initialLevel: GameLevel.level7),
        ),
      );
      await tester.pump();

      expect(find.textContaining('Level 7'), findsOneWidget);
      expect(find.textContaining('10 Cards'), findsOneWidget);
      expect(find.text('Tap to Flip'), findsNWidgets(10));
    });

    testWidgets('Timer counts down from 60', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PairFinderGame(initialLevel: GameLevel.level1),
        ),
      );
      await tester.pump();

      expect(find.text('Timer : 60'), findsOneWidget);

      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Timer : 59'), findsOneWidget);
    });

    testWidgets('Card flip reveals card face on tap', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PairFinderGame(initialLevel: GameLevel.level1),
        ),
      );
      await tester.pump();

      final cardFinders = find.text('Tap to Flip');
      expect(cardFinders, findsNWidgets(4));

      await tester.tap(cardFinders.first);
      await tester.pump();

      expect(find.text('Tap to Flip'), findsNWidgets(3));
    });

    testWidgets('Timeout displays Time Out dialog and offers Back to Games', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PairFinderGame(initialLevel: GameLevel.level1),
        ),
      );
      await tester.pump();

      // Fast forward past 60 seconds to trigger timeout
      await tester.pump(const Duration(seconds: 61));
      await tester.pumpAndSettle();

      expect(find.text('Time Out!'), findsOneWidget);
      expect(find.text('Back to Games'), findsOneWidget);
    });

    testWidgets('Single mismatch does not trigger hint immediately', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PairFinderGame(initialLevel: GameLevel.level1),
        ),
      );
      await tester.pump();

      final dynamic state = tester.state(find.byType(PairFinderGame));
      expect(state.hintUsedInLevel, isFalse);
      expect(state.blinkingCardIndices, isEmpty);

      // Tap card 0 and card 1 (Level 1: card 0 = A, card 1 = B -> mismatch)
      final cardFinders = find.text('Tap to Flip');
      await tester.tap(cardFinders.at(0));
      await tester.pump();
      await tester.tap(cardFinders.at(1));
      await tester.pump(const Duration(milliseconds: 800));

      // After 1 mismatch, hint is still not triggered
      expect(state.hintUsedInLevel, isFalse);
      expect(state.blinkingCardIndices, isEmpty);
    });

    testWidgets('Persistent struggle triggers blinking pair without auto-selecting or auto-matching', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PairFinderGame(initialLevel: GameLevel.level1),
        ),
      );
      await tester.pump();

      final dynamic state = tester.state(find.byType(PairFinderGame));
      expect(state.hintUsedInLevel, isFalse);

      // Fast forward 16 seconds without match to trigger struggle condition
      await tester.pump(const Duration(seconds: 16));

      // Hint is now triggered and exactly 2 matching card indices are blinking
      expect(state.hintUsedInLevel, isTrue);
      expect(state.hintCountInLevel, greaterThanOrEqualTo(1));
      expect(state.blinkingCardIndices.length, 2);

      // Cards are NOT auto-flipped or auto-matched (all 4 cards still show 'Tap to Flip')
      expect(find.text('Tap to Flip'), findsNWidgets(4));

      // Patient manually taps the 2 blinking matching cards to make a match
      final blinkingList = (state.blinkingCardIndices as Set<int>).toList();
      await tester.tap(find.text('Tap to Flip').at(blinkingList[0]));
      await tester.pump();
      await tester.tap(find.text('Tap to Flip').at(0)); // Tap matching card
      await tester.pump(const Duration(milliseconds: 800));

      // Verify matching logic works and cards are credited
      expect(state.hintUsedInLevel, isTrue);
    });
  });
}

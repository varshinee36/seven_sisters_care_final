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
  });
}

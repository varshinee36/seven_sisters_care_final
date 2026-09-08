import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seven_sisters_care/screens/pair_finder_game.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PairFinderGame Widget Tests', () {
    testWidgets('Level 1 renders exactly 4 cards in 2x2 layout', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PairFinderGame(initialLevel: GameLevel.level1),
        ),
      );
      await tester.pump();

      // Check header info
      expect(find.textContaining('Level 1'), findsOneWidget);
      expect(find.textContaining('4 Cards'), findsOneWidget);

      // Verify 4 cards are rendered with "Tap to Flip" back
      expect(find.text('Tap to Flip'), findsNWidgets(4));
    });

    testWidgets('Level 2 renders exactly 6 cards in 2x3 layout', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PairFinderGame(initialLevel: GameLevel.level2),
        ),
      );
      await tester.pump();

      // Check header info
      expect(find.textContaining('Level 2'), findsOneWidget);
      expect(find.textContaining('6 Cards'), findsOneWidget);

      // Verify 6 cards are rendered with "Tap to Flip" back
      expect(find.text('Tap to Flip'), findsNWidgets(6));
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

      // Tap first card
      final cardFinders = find.text('Tap to Flip');
      expect(cardFinders, findsNWidgets(4));

      await tester.tap(cardFinders.first);
      await tester.pump();

      // After flipping 1 card, exactly 3 should remain face down
      expect(find.text('Tap to Flip'), findsNWidgets(3));
    });
  });
}

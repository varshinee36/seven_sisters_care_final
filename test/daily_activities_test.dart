import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seven_sisters_care/screens/patient/activites_screen.dart';
import 'package:seven_sisters_care/screens/patient/activities/music_activity_screen.dart';
import 'package:seven_sisters_care/screens/patient/activities/reading_activity_screen.dart';
import 'package:seven_sisters_care/screens/patient/activities/family_recognition_activity_screen.dart';
import 'package:seven_sisters_care/screens/patient/activities/emotion_recognition_activity_screen.dart';
import 'package:seven_sisters_care/screens/patient/activities/daily_routine_recall_activity_screen.dart';

void main() {
  testWidgets('ActivitesScreen renders Daily Engaging Activity cards',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ActivitesScreen(),
      ),
    );

    expect(find.text("Activities"), findsOneWidget);
    expect(find.text("Reading"), findsOneWidget);
    expect(find.text("Family\nPicture"), findsOneWidget);
    expect(find.text("Music"), findsOneWidget);

    final listFinder = find.byType(ListView);
    await tester.drag(listFinder, const Offset(0, -300));
    await tester.pumpAndSettle();

    expect(find.text("Daily Routine\nRecall"), findsOneWidget);
  });

  testWidgets('MusicActivityScreen renders player and playlist items',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MusicActivityScreen(),
      ),
    );

    expect(find.text("Listening to Music"), findsOneWidget);
    expect(find.text("Bihu Spring Rhythms"), findsWidgets);
    expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
  });

  testWidgets('ReadingActivityScreen renders passage and answer questions flow',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ReadingActivityScreen(),
      ),
    );

    expect(find.text("Reading Activity"), findsOneWidget);
    expect(find.text("A Peaceful Morning in Assam's Tea Gardens"), findsOneWidget);
    expect(find.text("Answer Questions"), findsOneWidget);
  });

  testWidgets('FamilyRecognitionActivityScreen renders voice prompt and photo choices',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: FamilyRecognitionActivityScreen(),
      ),
    );

    expect(find.text("Family Recognition"), findsOneWidget);
    expect(find.text("Maya Barua"), findsOneWidget);
    expect(find.text("Rahul Barua"), findsOneWidget);
  });

  testWidgets('EmotionRecognitionActivityScreen renders portrait and emotion choices',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: EmotionRecognitionActivityScreen(),
      ),
    );

    expect(find.text("Emotion Recognition"), findsOneWidget);
    expect(find.text("Happy"), findsOneWidget);
    expect(find.text("Sad"), findsOneWidget);
  });

  testWidgets('DailyRoutineRecallActivityScreen renders shuffled routine cards',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: DailyRoutineRecallActivityScreen(),
      ),
    );

    expect(find.text("Daily Routine Recall"), findsOneWidget);
    expect(find.text("Check Sequence"), findsNothing); // Disabled until 4 selected
  });
}

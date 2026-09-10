import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seven_sisters_care/screens/patient/patient_reminders_screen.dart';
import 'package:seven_sisters_care/services/reminder_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ReminderService Unit Tests', () {
    test('Initial sample reminders are loaded', () {
      final service = ReminderService.instance;
      expect(service.reminders.isNotEmpty, isTrue);
      expect(service.reminders.any((r) => r.label.contains('Hydration')), isTrue);
      expect(service.reminders.any((r) => r.label.contains('Lunch')), isTrue);
      expect(service.reminders.any((r) => r.label.contains('Walking')), isTrue);
    });

    test('Toggling reminder completion updates status', () {
      final service = ReminderService.instance;
      final lunch = service.reminders.firstWhere((r) => r.label == 'Lunch');
      final initialStatus = lunch.status;

      service.toggleStatus(lunch.id);
      final updatedLunch = service.reminders.firstWhere((r) => r.id == lunch.id);
      expect(updatedLunch.status != initialStatus, isTrue);

      // Revert back
      service.toggleStatus(lunch.id);
    });

    test('Snooze increments snooze count up to 3 times, then alerts', () {
      final service = ReminderService.instance;
      const testReminder = Reminder(
        id: 'test-snooze-reminder',
        type: ReminderType.medicine,
        label: 'Test Snooze Med',
        time: TimeOfDay(hour: 9, minute: 0),
        status: ReminderStatus.pending,
      );

      service.addReminder(testReminder);
      service.triggerAlert(testReminder.id);
      expect(service.activeAlert?.id, testReminder.id);

      // Snooze 1
      service.snoozeReminder(testReminder.id);
      var current = service.reminders.firstWhere((r) => r.id == testReminder.id);
      expect(current.snoozeCount, 1);
      expect(current.snoozeUntil != null, isTrue);

      // Snooze 2
      service.snoozeReminder(testReminder.id);
      current = service.reminders.firstWhere((r) => r.id == testReminder.id);
      expect(current.snoozeCount, 2);

      // Snooze 3 (max snooze reached -> status becomes alerted)
      service.snoozeReminder(testReminder.id);
      current = service.reminders.firstWhere((r) => r.id == testReminder.id);
      expect(current.snoozeCount, 3);
      expect(current.status, ReminderStatus.alerted);

      // Acknowledge resolves the alert
      service.acknowledgeReminder(testReminder.id);
      current = service.reminders.firstWhere((r) => r.id == testReminder.id);
      expect(current.status, ReminderStatus.completed);
      expect(service.activeAlert, isNull);

      service.deleteReminder(testReminder.id);
    });
  });

  group('PatientRemindersScreen Widget Tests', () {
    testWidgets('Renders top bar, header and authentic reminder cards from mockup', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: PatientRemindersScreen(),
        ),
      );
      await tester.pump();

      // Verify Header "Todays Remainders" matching user image
      expect(find.text('Todays Remainders'), findsOneWidget);

      // Verify speaker icon exists
      expect(find.byIcon(Icons.volume_up_rounded), findsWidgets);

      // Verify authentic reminder items from uploaded image
      expect(find.text('Hydration'), findsOneWidget);
      expect(find.text('Lunch'), findsOneWidget);
      expect(find.text('Walking'), findsOneWidget);

      // Verify Back button exists
      expect(find.text('Back'), findsOneWidget);
    });

    testWidgets('Tapping card toggles status between Pending and Completed', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: PatientRemindersScreen(),
        ),
      );
      await tester.pump();

      final lunchCard = find.text('Lunch');
      expect(lunchCard, findsOneWidget);

      // Tap to toggle status
      await tester.tap(lunchCard);
      await tester.pump();

      // Verify snackbar feedback
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('Tapping speaker icon displays audio announcement snackbar', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: PatientRemindersScreen(),
        ),
      );
      await tester.pump();

      final firstSpeaker = find.byIcon(Icons.volume_up_rounded).first;
      await tester.tap(firstSpeaker);
      await tester.pump();

      expect(find.textContaining('Reminder:'), findsOneWidget);
    });
  });
}

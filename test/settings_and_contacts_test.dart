import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seven_sisters_care/screens/caregiver/caregiver_dashboard.dart';
import 'package:seven_sisters_care/screens/patient/patient_home_screen.dart';
import 'package:seven_sisters_care/screens/patient/patient_settings_screen.dart';
import 'package:seven_sisters_care/services/app_settings_service.dart';
import 'package:seven_sisters_care/services/family_contacts_service.dart';

void main() {
  setUp(() {
    AppSettingsService.instance.setTheme('System');
    AppSettingsService.instance.setFontSize('Medium');
    FamilyContactsService.instance.resetToDefaults();
  });

  group('AppSettingsService Tests', () {
    test('Initial defaults are System and Medium', () {
      final settings = AppSettingsService.instance;
      expect(settings.themeName, 'System');
      expect(settings.themeMode, ThemeMode.system);
      expect(settings.fontSizeName, 'Medium');
      expect(settings.fontScale, 1.0);
    });

    test('setFontSize updates scale factor correctly', () {
      final settings = AppSettingsService.instance;

      settings.setFontSize('Small');
      expect(settings.fontSizeName, 'Small');
      expect(settings.fontScale, 0.85);

      settings.setFontSize('Large');
      expect(settings.fontSizeName, 'Large');
      expect(settings.fontScale, 1.25);

      settings.setFontSize('Medium');
      expect(settings.fontSizeName, 'Medium');
      expect(settings.fontScale, 1.0);
    });

    test('setTheme updates theme mode correctly', () {
      final settings = AppSettingsService.instance;

      settings.setTheme('Dark');
      expect(settings.themeName, 'Dark');
      expect(settings.themeMode, ThemeMode.dark);

      settings.setTheme('Light');
      expect(settings.themeName, 'Light');
      expect(settings.themeMode, ThemeMode.light);

      settings.setTheme('System');
      expect(settings.themeName, 'System');
      expect(settings.themeMode, ThemeMode.system);
    });
  });

  group('FamilyContactsService Tests', () {
    test('Default family contacts exist', () {
      final contacts = FamilyContactsService.instance.contacts;
      expect(contacts.length, 3);
      expect(contacts.any((c) => c.name == 'Rahul' && c.relationship == 'Son'), isTrue);
      expect(contacts.any((c) => c.name == 'Priya' && c.relationship == 'Daughter'), isTrue);
    });

    test('Adding and deleting contacts works properly', () {
      final service = FamilyContactsService.instance;
      final initialCount = service.contacts.length;

      service.addContact(
        name: 'Aman',
        relationship: 'Son',
        phoneNumber: '+91 9123456780',
      );

      expect(service.contacts.length, initialCount + 1);
      final added = service.contacts.firstWhere((c) => c.name == 'Aman');
      expect(added.relationship, 'Son');
      expect(added.phoneNumber, '+91 9123456780');

      service.deleteContact(added.id);
      expect(service.contacts.length, initialCount);
    });
  });

  group('PatientSettingsScreen Widget Tests', () {
    testWidgets('Tapping font sizes and themes updates AppSettingsService',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: PatientSettingsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Theme options are visible
      expect(find.text('Theme'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
      expect(find.text('System'), findsOneWidget);

      // Tap Dark theme
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();
      expect(AppSettingsService.instance.themeMode, ThemeMode.dark);

      // Verify Font Size options
      expect(find.text('Font Size'), findsOneWidget);
      expect(find.text('Small'), findsOneWidget);
      expect(find.text('Medium (Default)'), findsOneWidget);
      expect(find.text('Large'), findsOneWidget);

      // Tap Large font size
      await tester.tap(find.text('Large'));
      await tester.pumpAndSettle();
      expect(AppSettingsService.instance.fontSizeName, 'Large');
      expect(AppSettingsService.instance.fontScale, 1.25);

      // Tap Small font size
      await tester.tap(find.text('Small'));
      await tester.pumpAndSettle();
      expect(AppSettingsService.instance.fontSizeName, 'Small');
      expect(AppSettingsService.instance.fontScale, 0.85);

      // Verify Quick Access Apps are visible
      expect(find.text('Quick Access Apps'), findsOneWidget);
      expect(find.text('YouTube'), findsOneWidget);
      expect(find.text('WhatsApp'), findsOneWidget);
      expect(find.text('Instagram'), findsOneWidget);
      expect(find.text('Google Contacts'), findsOneWidget);
      expect(find.text('Phone Dialer'), findsOneWidget);

      // Tap YouTube
      await tester.tap(find.text('YouTube'));
      await tester.pump();
      expect(find.textContaining('YouTube'), findsWidgets);
    });
  });

  group('Caregiver and Patient Family Contacts Integration Test', () {
    testWidgets('Caregiver adds contact and Patient can view and call from Family sheet',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // 1. Caregiver opens Dashboard
      await tester.pumpWidget(
        const MaterialApp(
          home: CaregiverDashboard(),
        ),
      );
      await tester.pumpAndSettle();

      // Open Family & Emergency Contacts from Caregiver Dashboard settings
      expect(find.text('Family & Emergency Contacts'), findsOneWidget);
      await tester.tap(find.text('Family & Emergency Contacts'));
      await tester.pumpAndSettle();

      // Add a new family member (e.g. Son: "Arjun")
      expect(find.text('Add Family Contact (Son, Daughter...)'), findsOneWidget);
      await tester.tap(find.text('Add Family Contact (Son, Daughter...)'));
      await tester.pumpAndSettle();

      // Enter Contact details in form
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Contact Name'), 'Arjun');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Relationship'), 'Son');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Phone Number'), '+91 9988776655');

      await tester.tap(find.text('Save Contact'));
      await tester.pumpAndSettle();

      // Verify Arjun is now present in service
      expect(
        FamilyContactsService.instance.contacts
            .any((c) => c.name == 'Arjun' && c.relationship == 'Son'),
        isTrue,
      );

      // Close dialog
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // 2. Now test Patient Home Screen
      await tester.pumpWidget(
        const MaterialApp(
          home: PatientHomeScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Family card
      await tester.tap(find.text('Family'));
      await tester.pumpAndSettle();

      // Verify Arjun (Son) appears in Patient's Family & Care sheet
      expect(find.text('Arjun (Son)'), findsOneWidget);
      expect(find.text('+91 9988776655'), findsOneWidget);

      // Verify Call button exists for Arjun, ensure it is scrolled into view and tap to call
      final callButton = find.byTooltip('Call Arjun');
      expect(callButton, findsOneWidget);

      await tester.ensureVisible(callButton);
      await tester.pumpAndSettle();

      await tester.tap(callButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.textContaining('Calling Arjun (Son)'), findsOneWidget);
    });
  });
}


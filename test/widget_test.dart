import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:seven_sisters_care/localization/app_localizations.dart';
import 'package:seven_sisters_care/services/language_service.dart';
import 'package:seven_sisters_care/providers/language_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Localization Offline Tests', () {
    test('English dictionary translations', () {
      final loc = AppLocalizations(const Locale('en'));
      expect(loc.appTitle, 'Seven Sisters Care');
      expect(loc.welcome, 'Welcome');
      expect(loc.medicineReminder, 'Medicine Reminder');
      expect(loc.save, 'Save');
      expect(loc.cancel, 'Cancel');
      expect(loc.games, 'Games');
    });

    test('Hindi dictionary translations', () {
      final loc = AppLocalizations(const Locale('hi'));
      expect(loc.welcome, 'स्वागत है');
      expect(loc.medicineReminder, 'दवा अनुस्मारक');
      expect(loc.save, 'सहेजें');
      expect(loc.cancel, 'रद्द करें');
      expect(loc.games, 'खेल');
      expect(loc.reminders, 'अनुस्मारक');
    });

    test('Assamese dictionary translations', () {
      final loc = AppLocalizations(const Locale('as'));
      expect(loc.welcome, 'স্বাগতম');
      expect(loc.medicineReminder, 'ঔষধ সোঁৱৰণী');
      expect(loc.save, 'সংৰক্ষণ কৰক');
      expect(loc.cancel, 'বাতিল কৰক');
      expect(loc.games, 'খেলসমূহ');
      expect(loc.reminders, 'সোঁৱৰণী');
    });

    test('Bengali dictionary translations', () {
      final loc = AppLocalizations(const Locale('bn'));
      expect(loc.welcome, 'স্বাগতম');
      expect(loc.medicineReminder, 'ওষুধ অনুস্মারক');
      expect(loc.save, 'সংরক্ষণ করুন');
      expect(loc.cancel, 'বাতিল');
      expect(loc.games, 'খেলাধুলা');
      expect(loc.reminders, 'অনুস্মারক');
    });
  });

  group('LanguageProvider and Persistence Tests', () {
    testWidgets('LanguageProvider switches locale dynamically and persists',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final service = LanguageService.instance;
      await service.init();
      final provider = LanguageProvider(service);

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: provider,
          child: Consumer<LanguageProvider>(
            builder: (context, lang, _) {
              final loc = AppLocalizations(lang.currentLocale);
              return MaterialApp(
                locale: lang.currentLocale,
                home: Scaffold(
                  body: Column(
                    children: [
                      Text(loc.welcome),
                      Text(loc.medicineReminder),
                      Text(loc.games),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );

      // Initially English
      expect(find.text('Welcome'), findsOneWidget);
      expect(find.text('Medicine Reminder'), findsOneWidget);
      expect(find.text('Games'), findsOneWidget);

      // Switch to Hindi
      await provider.setLanguage('hi');
      await tester.pumpAndSettle();

      expect(find.text('स्वागत है'), findsOneWidget);
      expect(find.text('दवा अनुस्मारक'), findsOneWidget);
      expect(find.text('खेल'), findsOneWidget);

      // Switch to Assamese
      await provider.setLanguage('as');
      await tester.pumpAndSettle();

      expect(find.text('স্বাগতম'), findsOneWidget);
      expect(find.text('ঔষধ সোঁৱৰণী'), findsOneWidget);
      expect(find.text('খেলসমূহ'), findsOneWidget);

      // Switch to Bengali
      await provider.setLanguage('bn');
      await tester.pumpAndSettle();

      expect(find.text('স্বাগতম'), findsOneWidget);
      expect(find.text('ওষুধ অনুস্মারক'), findsOneWidget);
      expect(find.text('খেলাধুলা'), findsOneWidget);

      // Verify SharedPreferences persisted the code
      expect(service.getSavedLanguage(), 'bn');
    });
  });
}

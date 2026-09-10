import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seven_sisters_care/localization/app_localizations.dart';
import 'package:seven_sisters_care/localization/as.dart';
import 'package:seven_sisters_care/localization/bn.dart';
import 'package:seven_sisters_care/localization/en.dart';
import 'package:seven_sisters_care/localization/hi.dart';

void main() {
  group('Static Localization Dictionary Integrity Tests', () {
    test('All 4 dictionaries contain identical key sets', () {
      final enKeys = enDict.keys.toSet();
      final hiKeys = hiDict.keys.toSet();
      final asKeys = asDict.keys.toSet();
      final bnKeys = bnDict.keys.toSet();

      final missingInHi = enKeys.difference(hiKeys);
      final extraInHi = hiKeys.difference(enKeys);
      expect(missingInHi, isEmpty, reason: 'Keys missing in Hindi dictionary');
      expect(extraInHi, isEmpty, reason: 'Extra keys in Hindi dictionary');

      final missingInAs = enKeys.difference(asKeys);
      final extraInAs = asKeys.difference(enKeys);
      expect(missingInAs, isEmpty, reason: 'Keys missing in Assamese dictionary');
      expect(extraInAs, isEmpty, reason: 'Extra keys in Assamese dictionary');

      final missingInBn = enKeys.difference(bnKeys);
      final extraInBn = bnKeys.difference(enKeys);
      expect(missingInBn, isEmpty, reason: 'Keys missing in Bengali dictionary');
      expect(extraInBn, isEmpty, reason: 'Extra keys in Bengali dictionary');
    });

    test('All game domains and sub-games exist in all 4 languages', () {
      final gameKeys = [
        'games',
        'memory',
        'attention',
        'executivePlanning',
        'perceptualMotor',
        'memoryGames',
        'attentionGames',
        'executiveGames',
        'perceptualMotorGames',
        'pairFinder',
        'memoryHunt',
        'objectFocus',
        'findDifferences',
        'dailyTaskOrdering',
        'activitySequencing',
        'shapeMatching',
        'dragAndPlace',
        'startPlaying',
        'close',
        'back',
      ];

      for (final key in gameKeys) {
        expect(enDict.containsKey(key), isTrue, reason: '$key in EN');
        expect(hiDict.containsKey(key), isTrue, reason: '$key in HI');
        expect(asDict.containsKey(key), isTrue, reason: '$key in AS');
        expect(bnDict.containsKey(key), isTrue, reason: '$key in BN');
      }
    });

    test('All Memory Hunt catalog items exist in all 4 languages', () {
      final itemKeys = [
        'item_apple',
        'item_book',
        'item_ball',
        'item_cup',
        'item_car',
        'item_dog',
        'item_clock',
        'item_flower',
        'item_house',
        'item_tree',
        'item_sun',
        'item_star',
        'item_bird',
        'item_fish',
        'item_hat',
        'item_key',
        'item_chair',
        'item_boat',
        'item_train',
        'item_umbrella',
        'item_camera',
        'item_guitar',
        'item_shoe',
        'item_phone',
        'item_bicycle',
        'item_lamp',
      ];

      for (final key in itemKeys) {
        expect(enDict.containsKey(key), isTrue);
        expect(hiDict.containsKey(key), isTrue);
        expect(asDict.containsKey(key), isTrue);
        expect(bnDict.containsKey(key), isTrue);
      }
    });

    test('All 15 level hints exist in all 4 languages', () {
      for (int level = 1; level <= 5; level++) {
        for (int hint = 1; hint <= 3; hint++) {
          final key = 'hint_${level}_$hint';
          expect(enDict.containsKey(key), isTrue);
          expect(hiDict.containsKey(key), isTrue);
          expect(asDict.containsKey(key), isTrue);
          expect(bnDict.containsKey(key), isTrue);
        }
      }
    });

    test('All activities screen keys exist in all 4 languages', () {
      final activityKeys = [
        'activitySelectVoice',
        'reading',
        'readingRecall',
        'readingRecallDesc',
        'familyPicture',
        'familyPictureRecognition',
        'familyPictureRecognitionDesc',
        'music',
        'musicSingingMemory',
        'musicSingingMemoryDesc',
        'dailyRoutineRecall',
        'dailyRoutineRecallTitle',
        'dailyRoutineRecallDesc',
      ];

      for (final key in activityKeys) {
        expect(enDict.containsKey(key), isTrue);
        expect(hiDict.containsKey(key), isTrue);
        expect(asDict.containsKey(key), isTrue);
        expect(bnDict.containsKey(key), isTrue);
      }
    });
  });

  group('AppLocalizations translation method tests', () {
    test('AppLocalizations resolves language-specific strings correctly', () {
      final locEn = AppLocalizations(const Locale('en'));
      final locHi = AppLocalizations(const Locale('hi'));
      final locAs = AppLocalizations(const Locale('as'));
      final locBn = AppLocalizations(const Locale('bn'));

      expect(locEn.memoryHunt, 'Memory Hunt');
      expect(locHi.memoryHunt, 'मेमोरी हंट');
      expect(locAs.memoryHunt, 'মেম’ৰী হাণ্ট');
      expect(locBn.memoryHunt, 'মেমরি হান্ট');

      expect(locEn.levelXOf5(1), 'Level 1 of 5');
      expect(locHi.levelXOf5(1), 'स्तर 1 / 5');
      expect(locAs.levelXOf5(1), 'স্তৰ 1 / ৫');
      expect(locBn.levelXOf5(1), 'লেভেল 1 / ৫');

      expect(locEn.getItemLabel('apple'), 'Apple');
      expect(locHi.getItemLabel('apple'), 'सेब');
      expect(locAs.getItemLabel('apple'), 'আপেল');
      expect(locBn.getItemLabel('apple'), 'আপেল');

      expect(locEn.getLevelHint(1, 0), contains('Book'));
      expect(locHi.getLevelHint(1, 0), contains('किताब'));
      expect(locAs.getLevelHint(1, 0), contains('কিতাপ'));
      expect(locBn.getLevelHint(1, 0), contains('বই'));

      expect(locEn.activities, 'Activities');
      expect(locHi.activities, 'गतिविधियाँ');
      expect(locAs.activities, 'কাৰ্য্যকলাপ');
      expect(locBn.activities, 'ক্রিয়াকলাপ');
    });
  });
}

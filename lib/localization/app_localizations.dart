import 'package:flutter/material.dart';
import 'en.dart';
import 'hi.dart';
import 'as.dart';
import 'bn.dart';

/// AppLocalizations handles static offline translations for Seven Sisters Care.
/// Supports English ('en'), Hindi ('hi'), Assamese ('as'), and Bengali ('bn').
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('en'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('hi'),
    Locale('as'),
    Locale('bn'),
  ];

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': enDict,
    'hi': hiDict,
    'as': asDict,
    'bn': bnDict,
  };

  /// Returns translated string for [key], falling back to English, then [key].
  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }

  // --- Convenience Getters ---

  // App General
  String get appTitle => translate('appTitle');
  String get appSubtitle => translate('appSubtitle');
  String get welcome => translate('welcome');
  String get save => translate('save');
  String get cancel => translate('cancel');
  String get close => translate('close');
  String get back => translate('back');
  String get done => translate('done');
  String get submit => translate('submit');
  String get next => translate('next');
  String get or => translate('or');
  String get yes => translate('yes');
  String get no => translate('no');
  String get success => translate('success');
  String get error => translate('error');
  String get loading => translate('loading');
  String get pleaseWait => translate('pleaseWait');

  // Auth & Roles
  String get login => translate('login');
  String get signUp => translate('signUp');
  String get createAccount => translate('createAccount');
  String get username => translate('username');
  String get enterUsername => translate('enterUsername');
  String get password => translate('password');
  String get enterPassword => translate('enterPassword');
  String get confirmPassword => translate('confirmPassword');
  String get dontHaveAccount => translate('dontHaveAccount');
  String get alreadyHaveAccount => translate('alreadyHaveAccount');
  String get pleaseEnterUsername => translate('pleaseEnterUsername');
  String get pleaseEnterPassword => translate('pleaseEnterPassword');
  String get loginSuccessful => translate('loginSuccessful');
  String get loginFailed => translate('loginFailed');
  String get connectionError => translate('connectionError');
  String get chooseYourRole => translate('chooseYourRole');
  String get patient => translate('patient');
  String get continueAsPatient => translate('continueAsPatient');
  String get caregiver => translate('caregiver');
  String get continueAsCaregiver => translate('continueAsCaregiver');

  // Registration
  String get setupProfile => translate('setupProfile');
  String get patientDetails => translate('patientDetails');
  String get patientName => translate('patientName');
  String get enterName => translate('enterName');
  String get dateOfBirth => translate('dateOfBirth');
  String get gender => translate('gender');
  String get male => translate('male');
  String get female => translate('female');
  String get preferredLanguage => translate('preferredLanguage');
  String get readingPreference => translate('readingPreference');
  String get dementiaStage => translate('dementiaStage');
  String get mild => translate('mild');
  String get moderate => translate('moderate');
  String get severe => translate('severe');
  String get pleaseEnterPatientName => translate('pleaseEnterPatientName');
  String get pleaseSelectDob => translate('pleaseSelectDob');

  // Caregiver
  String get caregiverDetails => translate('caregiverDetails');
  String get caregiverName => translate('caregiverName');
  String get relationshipToPatient => translate('relationshipToPatient');
  String get phoneNumber => translate('phoneNumber');
  String get relationshipSon => translate('relationshipSon');
  String get relationshipDaughter => translate('relationshipDaughter');
  String get relationshipGrandson => translate('relationshipGrandson');
  String get relationshipGranddaughter =>
      translate('relationshipGranddaughter');
  String get relationshipSpouse => translate('relationshipSpouse');
  String get relationshipOther => translate('relationshipOther');
  String get pleaseEnterCaregiverName => translate('pleaseEnterCaregiverName');
  String get nameMinChars => translate('nameMinChars');
  String get pleaseEnterPhone => translate('pleaseEnterPhone');
  String get validPhoneRequired => translate('validPhoneRequired');
  String get passwordMinChars => translate('passwordMinChars');
  String get passwordsDoNotMatch => translate('passwordsDoNotMatch');
  String get registrationSuccess => translate('registrationSuccess');
  String get registrationFailed => translate('registrationFailed');

  // Dashboard
  String get charge => translate('charge');
  String get games => translate('games');
  String get activities => translate('activities');
  String get reminders => translate('reminders');
  String get family => translate('family');
  String get talkToAssistant => translate('talkToAssistant');
  String get voiceGuideFor => translate('voiceGuideFor');
  String get voiceOver => translate('voiceOver');

  // Reminders
  String get todaysReminders => translate('todaysReminders');
  String get morningMedication => translate('morningMedication');
  String get gardenStroll => translate('gardenStroll');
  String get nutritiousLunch => translate('nutritiousLunch');
  String get brainHealthMemory => translate('brainHealthMemory');
  String get eveningMedicine => translate('eveningMedicine');
  String get medicineReminder => translate('medicineReminder');
  String get hydrationReminder => translate('hydrationReminder');
  String get doctorAppointment => translate('doctorAppointment');
  String get drinkWater => translate('drinkWater');
  String get takeMedicine => translate('takeMedicine');
  String get completed => translate('completed');
  String get pending => translate('pending');

  // Family
  String get myFamilyAndCare => translate('myFamilyAndCare');
  String get noFamilyContacts => translate('noFamilyContacts');
  String get call => translate('call');
  String get calling => translate('calling');

  // Voice Companion
  String get voiceCompanion => translate('voiceCompanion');
  String get voiceListeningPrompt => translate('voiceListeningPrompt');
  String get voiceNews => translate('voiceNews');
  String get voiceMusic => translate('voiceMusic');
  String get voiceMedications => translate('voiceMedications');
  String get voiceCallFamily => translate('voiceCallFamily');
  String get processing => translate('processing');

  // Settings
  String get settings => translate('settings');
  String get theme => translate('theme');
  String get light => translate('light');
  String get lightDesc => translate('lightDesc');
  String get dark => translate('dark');
  String get darkDesc => translate('darkDesc');
  String get system => translate('system');
  String get systemDesc => translate('systemDesc');
  String get fontSize => translate('fontSize');
  String get small => translate('small');
  String get smallDesc => translate('smallDesc');
  String get medium => translate('medium');
  String get mediumDesc => translate('mediumDesc');
  String get large => translate('large');
  String get largeDesc => translate('largeDesc');
  String get quickAccessApps => translate('quickAccessApps');
  String get language => translate('language');
  String get languageSubtitle => translate('languageSubtitle');
  String get english => translate('english');
  String get hindi => translate('hindi');
  String get assamese => translate('assamese');
  String get bengali => translate('bengali');
  String get logout => translate('logout');
  String get logoutConfirmation => translate('logoutConfirmation');

  // Games & Activities
  String get memory => translate('memory');
  String get attention => translate('attention');
  String get executivePlanning => translate('executivePlanning');
  String get perceptualMotor => translate('perceptualMotor');
  String get memoryGames => translate('memoryGames');
  String get attentionGames => translate('attentionGames');
  String get executiveGames => translate('executiveGames');
  String get perceptualMotorGames => translate('perceptualMotorGames');
  String get beginActivity => translate('beginActivity');
  String get sessionStarted => translate('sessionStarted');
  String get startPlaying => translate('startPlaying');

  // Games Detail & Dialogs
  String get memoryHunt => translate('memoryHunt');
  String get memoryHuntDesc => translate('memoryHuntDesc');
  String get pairFinder => translate('pairFinder');
  String get pairFinderDesc => translate('pairFinderDesc');
  String get pairFinderDialogDesc => translate('pairFinderDialogDesc');
  String get continuousFocus => translate('continuousFocus');
  String get continuousFocusDesc => translate('continuousFocusDesc');
  String get objectFocus => translate('objectFocus');
  String get findDifferences => translate('findDifferences');
  String get findDifferencesDesc => translate('findDifferencesDesc');
  String get executivePlan => translate('executivePlan');
  String get executivePlanDesc => translate('executivePlanDesc');
  String get dailyTaskOrdering => translate('dailyTaskOrdering');
  String get dailyTaskOrderingDesc => translate('dailyTaskOrderingDesc');
  String get activitySequencing => translate('activitySequencing');
  String get activitySequencingDesc => translate('activitySequencingDesc');
  String get shapeMatching => translate('shapeMatching');
  String get shapeMatchingDesc => translate('shapeMatchingDesc');
  String get dragAndPlace => translate('dragAndPlace');
  String get dragAndPlaceDesc => translate('dragAndPlaceDesc');

  // Pair Finder Tutorial & Game Extras
  String get watchBeforePlay => translate('watchBeforePlay');
  String get howToPlay => translate('howToPlay');
  String get tutorialVideoNote => translate('tutorialVideoNote');
  String get elderlyPairTip => translate('elderlyPairTip');
  String get startPairFinder => translate('startPairFinder');
  String get gameStartsAuto => translate('gameStartsAuto');
  String get playLevelAgain => translate('playLevelAgain');
  String get startNextLevel => translate('startNextLevel');
  String get backToGames => translate('backToGames');

  // Memory Hunt UI & Flow
  String get getReady => translate('getReady');
  String get getReadyBreathe => translate('getReadyBreathe');
  String get hint => translate('hint');
  String get gotIt => translate('gotIt');
  String get noHintsRemaining => translate('noHintsRemaining');
  String get usedAll3Hints => translate('usedAll3Hints');
  String get tryAgainExclamation => translate('tryAgainExclamation');
  String get tryAgain => translate('tryAgain');
  String get wellDoneExclamation => translate('wellDoneExclamation');
  String get youRememberedCorrectly => translate('youRememberedCorrectly');
  String get wellDoneGuidance => translate('wellDoneGuidance');
  String get foundAllFinalObjects => translate('foundAllFinalObjects');
  String get nextLevel => translate('nextLevel');
  String get goodTryExclamation => translate('goodTryExclamation');
  String get allHintsFinishedForLevel => translate('allHintsFinishedForLevel');
  String get retryLevel => translate('retryLevel');
  String get continueText => translate('continueText');
  String get congratulationsExclamation => translate('congratulationsExclamation');
  String get allLevelsCompleted => translate('allLevelsCompleted');
  String get allLevelsCompletedGuidance => translate('allLevelsCompletedGuidance');
  String get playAgain => translate('playAgain');
  String get answers => translate('answers');
  String get correctObjectsWere => translate('correctObjectsWere');

  // Memory Hunt Parameterized Helpers
  String levelXOf5(int level) =>
      translate('levelXOf5').replaceAll('{level}', '$level');

  String pleaseRememberObjects(int count) =>
      translate('pleaseRememberObjects').replaceAll('{count}', '$count');

  String pleaseRememberObjectsCarefully(int count) =>
      translate('pleaseRememberObjectsCarefully').replaceAll('{count}', '$count');

  String selectObjectsSawEarlier(int targetCount, int selectedCount) =>
      translate('selectObjectsSawEarlier')
          .replaceAll('{targetCount}', '$targetCount')
          .replaceAll('{selectedCount}', '$selectedCount');

  String selectObjectsGuidance(int targetCount, int hintsRemaining) =>
      translate('selectObjectsGuidance')
          .replaceAll('{targetCount}', '$targetCount')
          .replaceAll('{hintsRemaining}', '$hintsRemaining');

  String hintWithCount(int count) =>
      translate('hintWithCount').replaceAll('{count}', '$count');

  String hintXOf3(int index) =>
      translate('hintXOf3').replaceAll('{index}', '$index');

  String allHintsUsedForLevel(int level) =>
      translate('allHintsUsedForLevel').replaceAll('{level}', '$level');

  String tryAgainPrompt(int hintsRemaining) =>
      translate('tryAgainPrompt')
          .replaceAll('{hintsRemaining}', '$hintsRemaining')
          .replaceAll('{s}', hintsRemaining == 1 ? '' : 's');

  String tryAgainGuidance(int hintsRemaining) =>
      translate('tryAgainGuidance').replaceAll('{hintsRemaining}', '$hintsRemaining');

  String useHintWithRemaining(int count) =>
      translate('useHintWithRemaining').replaceAll('{count}', '$count');

  String foundAllLevelObjects(int count, int level) =>
      translate('foundAllLevelObjects')
          .replaceAll('{count}', '$count')
          .replaceAll('{level}', '$level');

  String allHintsFinishedGuidance(String answersList) =>
      translate('allHintsFinishedGuidance').replaceAll('{answers}', answersList);

  String getItemLabel(String id) => translate('item_$id');

  String getLevelHint(int level, int hintIndex) =>
      translate('hint_${level}_${hintIndex + 1}');

  // Activities Screen
  String get activitySelectVoice => translate('activitySelectVoice');
  String get reading => translate('reading');
  String get readingRecall => translate('readingRecall');
  String get readingRecallDesc => translate('readingRecallDesc');
  String get familyPicture => translate('familyPicture');
  String get familyPictureRecognition => translate('familyPictureRecognition');
  String get familyPictureRecognitionDesc => translate('familyPictureRecognitionDesc');
  String get music => translate('music');
  String get musicSingingMemory => translate('musicSingingMemory');
  String get musicSingingMemoryDesc => translate('musicSingingMemoryDesc');
  String get dailyRoutineRecall => translate('dailyRoutineRecall');
  String get dailyRoutineRecallTitle => translate('dailyRoutineRecallTitle');
  String get dailyRoutineRecallDesc => translate('dailyRoutineRecallDesc');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'hi', 'as', 'bn'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

/// Helpful extensions for quick localization access in widgets:
/// e.g. `context.loc.welcome` or `context.tr('welcome')`
extension AppLocalizationsX on BuildContext {
  AppLocalizations get loc => AppLocalizations.of(this);
  String tr(String key) => AppLocalizations.of(this).translate(key);
}

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_tr.dart';
import 'app_localizations_en.dart';

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('tr'),
    Locale('en'),
  ];

  // Genel
  String get next;
  String get back;
  String get save;
  String get cancel;
  String get done;
  String get loading;
  String get error;

  // Onboarding - Ağırlık
  String get weightSelectTitle;
  String get weightSelectSubtitle;
  String get unitKg;
  String get unitLb;

  // Onboarding - Boy
  String get heightSelectTitle;
  String get heightSelectSubtitle;
  String get unitCm;
  String get unitFtIn;

  // Onboarding - Cinsiyet
  String get genderSelectTitle;
  String get genderSelectSubtitle;
  String get genderMale;
  String get genderFemale;
  String get genderUndisclosed;

  // Onboarding - Aktivite
  String get activitySelectTitle;
  String get activitySelectSubtitle;
  String get activityLow;
  String get activityMedium;
  String get activityHigh;

  // Onboarding - Hedefler
  String get goalsSelectTitle;
  String get goalsSelectSubtitle;
  String get goalHydration;
  String get goalWeightLoss;
  String get goalSkinHealth;
  String get goalHealthyLifestyle;
  String get goalDigestion;

  // Onboarding - Sebze
  String get veggiesTitle;
  String get veggiesSubtitle;
  String get veggiesRare;
  String get veggiesDaily;
  String get veggiesFrequent;

  // Onboarding - Şekerli içecek
  String get sugaryTitle;
  String get sugarySubtitle;
  String get sugaryAlmostNever;
  String get sugaryRare;
  String get sugaryDaily;
  String get sugaryFrequent;

  // Onboarding - Özet
  String get summaryTitle;
  String get summarySubtitle;
  String get dailyGoalResult;
  String get saveAndStart;

  // BMI
  String get bmiTitle;
  String get bmiUnderweight;
  String get bmiNormal;
  String get bmiOverweight;
  String get bmiObese;

  // Validasyon mesajları
  String get validationWeightRange;
  String get validationHeightRange;
  String get validationRequired;

  // Bilgi mesajları
  String get infoPrivacy;
  String get infoActivity;
  String get infoVeggies;
  String get infoSugary;
  String get infoGoals;

  // Başarı mesajları
  String get successProfileSaved;
  String get successOnboardingComplete;

  // Hata mesajları
  String get errorGeneral;
  String get errorNetwork;
  String get errorSaving;

  // Profil sistemi
  String get profileSettings;
  String get profileEdit;
  String get profileDailyNeed;
  String get profileNotifications;
  String get profileFriends;
  String get profileAchievements;
  String get profileNotificationStatusOn;
  String get profileNotificationStatusOff;
  String get profileFriendsAdd;

  // Su ihtiyacı detay ekranı
  String get waterNeedPersonalAssistant;
  String get waterNeedCalculating;
  String get waterNeedDailyGoal;
  String get waterNeedUpdateInfo;
  String get waterNeedHowCalculated;
  String get waterNeedFormulaExplanation;
  String get waterNeedGoodToKnow;
  String get waterNeedPersonalizedTitle;
  String get waterNeedPersonalizedDesc;
  String get waterNeedDailyUpdateTitle;
  String get waterNeedDailyUpdateDesc;
  String get waterNeedScientificTitle;
  String get waterNeedScientificDesc;

  // Faktörler
  String get factorWeight;
  String get factorAge;
  String get factorGender;
  String get factorActivity;

  // Geçici mesajlar
  String get comingSoonNotifications;
  String get comingSoonFriends;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['tr', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'tr': return AppLocalizationsTr();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue on GitHub with a '
    'reproducible sample app and the gen-l10n configuration that was used.'
  );
}

/// Extension for easy access to localizations
extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

import 'app_localizations.dart';

/// English localization
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  // General
  @override
  String get next => 'Next';
  
  @override
  String get back => 'Back';
  
  @override
  String get save => 'Save';
  
  @override
  String get cancel => 'Cancel';
  
  @override
  String get done => 'Done';
  
  @override
  String get loading => 'Loading...';
  
  @override
  String get error => 'Error';

  // Onboarding - Weight
  @override
  String get weightSelectTitle => 'Select your weight';
  
  @override
  String get weightSelectSubtitle => 'Specify your weight to calculate your water needs';
  
  @override
  String get unitKg => 'kg';
  
  @override
  String get unitLb => 'lb';

  // Onboarding - Height
  @override
  String get heightSelectTitle => 'Select your height';
  
  @override
  String get heightSelectSubtitle => 'Specify your height to calculate your body mass index';
  
  @override
  String get unitCm => 'cm';
  
  @override
  String get unitFtIn => 'ft, in';

  // Onboarding - Gender
  @override
  String get genderSelectTitle => 'Select your gender';
  
  @override
  String get genderSelectSubtitle => 'To calculate your water needs more accurately';
  
  @override
  String get genderMale => 'Male';
  
  @override
  String get genderFemale => 'Female';
  
  @override
  String get genderUndisclosed => 'Prefer not to say';

  // Onboarding - Activity
  @override
  String get activitySelectTitle => 'Select your activity level';
  
  @override
  String get activitySelectSubtitle => 'We\'ll calculate your water needs based on your daily activity level';
  
  @override
  String get activityLow => 'Low (Desk job)';
  
  @override
  String get activityMedium => 'Medium (Active job / 1-3 days sports per week)';
  
  @override
  String get activityHigh => 'High (Heavy job / 3+ days sports per week)';

  // Onboarding - Goals
  @override
  String get goalsSelectTitle => 'Select your goals';
  
  @override
  String get goalsSelectSubtitle => 'For personalized motivation messages and tips (optional)';
  
  @override
  String get goalHydration => 'Drink more water';
  
  @override
  String get goalWeightLoss => 'Lose weight';
  
  @override
  String get goalSkinHealth => 'Improve skin condition';
  
  @override
  String get goalHealthyLifestyle => 'Healthy lifestyle';
  
  @override
  String get goalDigestion => 'Improve digestion';

  // Onboarding - Vegetables
  @override
  String get veggiesTitle => 'Your vegetable and fruit consumption';
  
  @override
  String get veggiesSubtitle => 'Vegetables and fruits provide natural hydration';
  
  @override
  String get veggiesRare => 'Rarely';
  
  @override
  String get veggiesDaily => 'Regularly';
  
  @override
  String get veggiesFrequent => 'Frequently';

  // Onboarding - Sugary drinks
  @override
  String get sugaryTitle => 'Your sugary drink consumption';
  
  @override
  String get sugarySubtitle => 'Sugary drinks cause dehydration and require more water';
  
  @override
  String get sugaryAlmostNever => 'Almost never';
  
  @override
  String get sugaryRare => 'Rarely';
  
  @override
  String get sugaryDaily => 'Regularly';
  
  @override
  String get sugaryFrequent => 'Frequently';

  // Onboarding - Summary
  @override
  String get summaryTitle => 'Your profile is ready!';
  
  @override
  String get summarySubtitle => 'Your personalized daily water goal';
  
  @override
  String get dailyGoalResult => 'Your Daily Water Goal';
  
  @override
  String get saveAndStart => 'Save and Start';

  // BMI
  @override
  String get bmiTitle => 'Body Mass Index (BMI)';
  
  @override
  String get bmiUnderweight => 'Underweight';
  
  @override
  String get bmiNormal => 'Normal';
  
  @override
  String get bmiOverweight => 'Overweight';
  
  @override
  String get bmiObese => 'Obese';

  // Validation messages
  @override
  String get validationWeightRange => 'Weight must be between 30-200 kg';
  
  @override
  String get validationHeightRange => 'Height must be between 120-220 cm';
  
  @override
  String get validationRequired => 'This field is required';

  // Info messages
  @override
  String get infoPrivacy => 'This information is only used to calculate your water needs and is kept confidential.';
  
  @override
  String get infoActivity => 'Your activity level affects your water needs. A more active lifestyle requires more water.';
  
  @override
  String get infoVeggies => 'Vegetables and fruits reduce your daily water needs thanks to their natural water content.';
  
  @override
  String get infoSugary => 'Sugary drinks disrupt your body\'s water balance and require you to drink more water.';
  
  @override
  String get infoGoals => 'We\'ll send you personalized motivation messages and health tips based on your selected goals.';

  // Success messages
  @override
  String get successProfileSaved => 'Your profile has been saved successfully! 🎉';
  
  @override
  String get successOnboardingComplete => 'Onboarding completed';

  // Error messages
  @override
  String get errorGeneral => 'An error occurred';
  
  @override
  String get errorNetwork => 'Internet connection error';
  
  @override
  String get errorSaving => 'Saving error';

  // Profile system
  @override
  String get profileSettings => 'Settings';
  
  @override
  String get profileEdit => 'Edit profile';
  
  @override
  String get profileDailyNeed => 'Daily need';
  
  @override
  String get profileNotifications => 'Notifications';
  
  @override
  String get profileFriends => 'Friends';
  
  @override
  String get profileAchievements => 'Achievements';
  
  @override
  String get profileNotificationStatusOn => 'On';
  
  @override
  String get profileNotificationStatusOff => 'Off';
  
  @override
  String get profileFriendsAdd => 'Add';

  // Water need detail screen
  @override
  String get waterNeedPersonalAssistant => 'Suu — your personal assistant';
  
  @override
  String get waterNeedCalculating => 'Calculating your water needs';
  
  @override
  String get waterNeedDailyGoal => 'Your Daily Water Goal';
  
  @override
  String get waterNeedUpdateInfo => 'Update Information';
  
  @override
  String get waterNeedHowCalculated => 'How is it calculated?';
  
  @override
  String get waterNeedFormulaExplanation => 'This goal is calculated using scientific formulas considering your weight, age, gender and activity level.';
  
  @override
  String get waterNeedGoodToKnow => 'Good to Know';
  
  @override
  String get waterNeedPersonalizedTitle => 'Personalized Calculation';
  
  @override
  String get waterNeedPersonalizedDesc => 'Your goal is calculated based on age, weight, height, gender and activity level.';
  
  @override
  String get waterNeedDailyUpdateTitle => 'Daily Update';
  
  @override
  String get waterNeedDailyUpdateDesc => 'If you update your information, your goal will be automatically recalculated.';
  
  @override
  String get waterNeedScientificTitle => 'Scientific Formula';
  
  @override
  String get waterNeedScientificDesc => 'Calculation is based on recommendations from international health organizations.';

  // Factors
  @override
  String get factorWeight => 'Weight';
  
  @override
  String get factorAge => 'Age';
  
  @override
  String get factorGender => 'Gender';
  
  @override
  String get factorActivity => 'Activity';

  // Temporary messages
  @override
  String get comingSoonNotifications => 'Notifications screen coming soon';
  
  @override
  String get comingSoonFriends => 'Friends feature coming soon';
}

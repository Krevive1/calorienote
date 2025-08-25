import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

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
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('en'),
    Locale('ja'),
    Locale('ko'),
    Locale('zh')
  ];

  /// No description provided for @setupTitle.
  ///
  /// In en, this message translates to:
  /// **'Set your goal'**
  String get setupTitle;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'language'**
  String get language;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @calcCaloriesButton.
  ///
  /// In en, this message translates to:
  /// **'Calculate calories'**
  String get calcCaloriesButton;

  /// No description provided for @calculating.
  ///
  /// In en, this message translates to:
  /// **'Calculating...'**
  String get calculating;

  /// No description provided for @recommendedDailyCaloriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily calorie target'**
  String get recommendedDailyCaloriesTitle;

  /// No description provided for @settingsChangedButton.
  ///
  /// In en, this message translates to:
  /// **'Save settings'**
  String get settingsChangedButton;

  /// No description provided for @settingsChangedSnack.
  ///
  /// In en, this message translates to:
  /// **'Settings have been updated'**
  String get settingsChangedSnack;

  /// No description provided for @calculateFirst.
  ///
  /// In en, this message translates to:
  /// **'Please calculate calories first'**
  String get calculateFirst;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Calorie Note'**
  String get homeTitle;

  /// No description provided for @menuRecord.
  ///
  /// In en, this message translates to:
  /// **'Record Meal'**
  String get menuRecord;

  /// No description provided for @menuRecordList.
  ///
  /// In en, this message translates to:
  /// **'Records'**
  String get menuRecordList;

  /// No description provided for @menuGraph.
  ///
  /// In en, this message translates to:
  /// **'Graph'**
  String get menuGraph;

  /// No description provided for @menuChangeTarget.
  ///
  /// In en, this message translates to:
  /// **'Change Goal'**
  String get menuChangeTarget;

  /// No description provided for @graphTitle.
  ///
  /// In en, this message translates to:
  /// **'Weight & Calorie Graph'**
  String get graphTitle;

  /// No description provided for @loadingData.
  ///
  /// In en, this message translates to:
  /// **'Loading data...'**
  String get loadingData;

  /// No description provided for @noGraphData.
  ///
  /// In en, this message translates to:
  /// **'No data yet'**
  String get noGraphData;

  /// No description provided for @addMealsForGraph.
  ///
  /// In en, this message translates to:
  /// **'Add meal records to see the graph!'**
  String get addMealsForGraph;

  /// No description provided for @span7Days.
  ///
  /// In en, this message translates to:
  /// **'7 days'**
  String get span7Days;

  /// No description provided for @span14Days.
  ///
  /// In en, this message translates to:
  /// **'14 days'**
  String get span14Days;

  /// No description provided for @span31Days.
  ///
  /// In en, this message translates to:
  /// **'31 days'**
  String get span31Days;

  /// No description provided for @spanAll.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get spanAll;

  /// No description provided for @weightTrend.
  ///
  /// In en, this message translates to:
  /// **'Weight trend'**
  String get weightTrend;

  /// No description provided for @calorieTrend.
  ///
  /// In en, this message translates to:
  /// **'Calorie intake trend'**
  String get calorieTrend;

  /// No description provided for @unitKg.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get unitKg;

  /// No description provided for @unitKcal.
  ///
  /// In en, this message translates to:
  /// **'kcal'**
  String get unitKcal;

  /// No description provided for @shareOptionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Share options'**
  String get shareOptionsTitle;

  /// No description provided for @shareAllDataOption.
  ///
  /// In en, this message translates to:
  /// **'Share all data as CSV'**
  String get shareAllDataOption;

  /// No description provided for @shareAllDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share all records as a CSV file'**
  String get shareAllDataSubtitle;

  /// No description provided for @sharePeriodOption.
  ///
  /// In en, this message translates to:
  /// **'Share by period'**
  String get sharePeriodOption;

  /// No description provided for @sharePeriodSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select a date range and share as CSV'**
  String get sharePeriodSubtitle;

  /// No description provided for @shareAppOption.
  ///
  /// In en, this message translates to:
  /// **'Share app'**
  String get shareAppOption;

  /// No description provided for @shareAppSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share app introduction'**
  String get shareAppSubtitle;

  /// No description provided for @shareTooltip.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get shareTooltip;

  /// No description provided for @pastMealsTitle.
  ///
  /// In en, this message translates to:
  /// **'Past meal records'**
  String get pastMealsTitle;

  /// No description provided for @noMealRecords.
  ///
  /// In en, this message translates to:
  /// **'No records yet'**
  String get noMealRecords;

  /// No description provided for @startRecording.
  ///
  /// In en, this message translates to:
  /// **'Start by adding a meal record'**
  String get startRecording;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @kcal.
  ///
  /// In en, this message translates to:
  /// **'kcal'**
  String get kcal;

  /// No description provided for @meals.
  ///
  /// In en, this message translates to:
  /// **'Meals'**
  String get meals;

  /// No description provided for @shareThisDayRecord.
  ///
  /// In en, this message translates to:
  /// **'Share this day\'s record'**
  String get shareThisDayRecord;

  /// No description provided for @helpTitle.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get helpTitle;

  /// No description provided for @howToUse.
  ///
  /// In en, this message translates to:
  /// **'How to use'**
  String get howToUse;

  /// No description provided for @helpSetupDesc.
  ///
  /// In en, this message translates to:
  /// **'On first launch, enter age, height, weight, target weight, and days then calculate calories.'**
  String get helpSetupDesc;

  /// No description provided for @helpMealDesc.
  ///
  /// In en, this message translates to:
  /// **'Enter meal and calories to record. You can also select from examples.'**
  String get helpMealDesc;

  /// No description provided for @exerciseTitle.
  ///
  /// In en, this message translates to:
  /// **'Exercise Records'**
  String get exerciseTitle;

  /// No description provided for @helpExerciseDesc.
  ///
  /// In en, this message translates to:
  /// **'Record exercise and burned calories. You can also select from examples.'**
  String get helpExerciseDesc;

  /// No description provided for @weightTitle.
  ///
  /// In en, this message translates to:
  /// **'Weight Record'**
  String get weightTitle;

  /// No description provided for @helpWeightDesc.
  ///
  /// In en, this message translates to:
  /// **'Record daily weight to track your progress.'**
  String get helpWeightDesc;

  /// No description provided for @helpGraphDesc.
  ///
  /// In en, this message translates to:
  /// **'Check your progress in graphs.'**
  String get helpGraphDesc;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @languageSetting.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSetting;

  /// No description provided for @versionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get versionLabel;

  /// No description provided for @privacyPolicyLabel.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyLabel;

  /// No description provided for @helpLabel.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get helpLabel;

  /// No description provided for @snackMealExampleRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a meal example'**
  String get snackMealExampleRequired;

  /// No description provided for @snackExerciseExampleRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select an exercise example'**
  String get snackExerciseExampleRequired;

  /// No description provided for @snackExerciseLogged.
  ///
  /// In en, this message translates to:
  /// **'Exercise recorded!'**
  String get snackExerciseLogged;

  /// No description provided for @snackExerciseInputRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter exercise name and calories'**
  String get snackExerciseInputRequired;

  /// No description provided for @snackWeightLogged.
  ///
  /// In en, this message translates to:
  /// **'Weight recorded!'**
  String get snackWeightLogged;

  /// No description provided for @snackMealInputRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter meal and calories'**
  String get snackMealInputRequired;

  /// No description provided for @snackMealLogged.
  ///
  /// In en, this message translates to:
  /// **'Meal recorded!'**
  String get snackMealLogged;

  /// No description provided for @snackMealDeleted.
  ///
  /// In en, this message translates to:
  /// **'Meal record deleted'**
  String get snackMealDeleted;

  /// No description provided for @snackExerciseDeleted.
  ///
  /// In en, this message translates to:
  /// **'Exercise record deleted'**
  String get snackExerciseDeleted;

  /// No description provided for @dialogEditMeal.
  ///
  /// In en, this message translates to:
  /// **'Edit meal record'**
  String get dialogEditMeal;

  /// No description provided for @dialogEditExercise.
  ///
  /// In en, this message translates to:
  /// **'Edit exercise record'**
  String get dialogEditExercise;

  /// No description provided for @labelFood.
  ///
  /// In en, this message translates to:
  /// **'Meal'**
  String get labelFood;

  /// No description provided for @labelCalories.
  ///
  /// In en, this message translates to:
  /// **'Calories (kcal)'**
  String get labelCalories;

  /// No description provided for @labelExercise.
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get labelExercise;

  /// No description provided for @labelBurnedCalories.
  ///
  /// In en, this message translates to:
  /// **'Burned calories (kcal)'**
  String get labelBurnedCalories;

  /// No description provided for @btnUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get btnUpdate;

  /// No description provided for @btnCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get btnCancel;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyTitle;

  /// No description provided for @privacyPolicyLastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated: December 2024'**
  String get privacyPolicyLastUpdated;

  /// No description provided for @privacyPolicySection1Title.
  ///
  /// In en, this message translates to:
  /// **'1. Information We Collect'**
  String get privacyPolicySection1Title;

  /// No description provided for @privacyPolicySection1Content.
  ///
  /// In en, this message translates to:
  /// **'This app collects the following information:\n• Meal records (meal content, calories)\n• Exercise records (exercise content, calories burned)\n• Weight records\n• Goal setting information (age, height, weight, target weight, etc.)\n• App usage data'**
  String get privacyPolicySection1Content;

  /// No description provided for @privacyPolicySection2Title.
  ///
  /// In en, this message translates to:
  /// **'2. How We Use Information'**
  String get privacyPolicySection2Title;

  /// No description provided for @privacyPolicySection2Content.
  ///
  /// In en, this message translates to:
  /// **'Collected information is used for the following purposes:\n• Calorie calculation and goal management\n• Progress visualization (graph display)\n• App functionality improvement\n• User support'**
  String get privacyPolicySection2Content;

  /// No description provided for @privacyPolicySection3Title.
  ///
  /// In en, this message translates to:
  /// **'3. Information Sharing'**
  String get privacyPolicySection3Title;

  /// No description provided for @privacyPolicySection3Content.
  ///
  /// In en, this message translates to:
  /// **'We will not provide your personal information to third parties except in the following cases:\n• When you have given consent\n• When required by law\n• When necessary to protect your safety'**
  String get privacyPolicySection3Content;

  /// No description provided for @privacyPolicySection4Title.
  ///
  /// In en, this message translates to:
  /// **'4. Data Storage'**
  String get privacyPolicySection4Title;

  /// No description provided for @privacyPolicySection4Content.
  ///
  /// In en, this message translates to:
  /// **'• Data is stored securely within the device\n• When using cloud sync features, data is stored in encrypted form\n• Saved data is deleted when the app is uninstalled'**
  String get privacyPolicySection4Content;

  /// No description provided for @privacyPolicySection5Title.
  ///
  /// In en, this message translates to:
  /// **'5. About Advertising'**
  String get privacyPolicySection5Title;

  /// No description provided for @privacyPolicySection5Content.
  ///
  /// In en, this message translates to:
  /// **'• This app uses Google AdMob to display advertisements\n• Google AdMob may collect device information for ad delivery\n• Please refer to Google AdMob\'s privacy policy for details'**
  String get privacyPolicySection5Content;

  /// No description provided for @privacyPolicySection6Title.
  ///
  /// In en, this message translates to:
  /// **'6. Contact Us'**
  String get privacyPolicySection6Title;

  /// No description provided for @privacyPolicySection6Content.
  ///
  /// In en, this message translates to:
  /// **'For inquiries regarding this privacy policy, please contact us at:\nEmail: qgsky217@yahoo.co.jp'**
  String get privacyPolicySection6Content;

  /// No description provided for @privacyPolicyNote.
  ///
  /// In en, this message translates to:
  /// **'※This privacy policy may be changed without notice. For important changes, we will notify you within the app.'**
  String get privacyPolicyNote;

  /// No description provided for @faqTitle.
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked Questions'**
  String get faqTitle;

  /// No description provided for @faqCalorieCalc.
  ///
  /// In en, this message translates to:
  /// **'Q: How is calorie calculation performed?'**
  String get faqCalorieCalc;

  /// No description provided for @faqCalorieCalcAnswer.
  ///
  /// In en, this message translates to:
  /// **'A: We use the Harris-Benedict equation to calculate basal metabolic rate, then calculate daily calorie intake considering activity factor and target weight.'**
  String get faqCalorieCalcAnswer;

  /// No description provided for @faqDataStorage.
  ///
  /// In en, this message translates to:
  /// **'Q: Where is data stored?'**
  String get faqDataStorage;

  /// No description provided for @faqDataStorageAnswer.
  ///
  /// In en, this message translates to:
  /// **'A: Data is stored securely within the device. Data is deleted when the app is uninstalled.'**
  String get faqDataStorageAnswer;

  /// No description provided for @faqTargetCalorie.
  ///
  /// In en, this message translates to:
  /// **'Q: Can I change my target calorie?'**
  String get faqTargetCalorie;

  /// No description provided for @faqTargetCalorieAnswer.
  ///
  /// In en, this message translates to:
  /// **'A: You can change target calories from the settings screen.'**
  String get faqTargetCalorieAnswer;

  /// No description provided for @faqPastRecords.
  ///
  /// In en, this message translates to:
  /// **'Q: Can I check past records?'**
  String get faqPastRecords;

  /// No description provided for @faqPastRecordsAnswer.
  ///
  /// In en, this message translates to:
  /// **'A: You can check past records in the records list screen.'**
  String get faqPastRecordsAnswer;

  /// No description provided for @faqExportData.
  ///
  /// In en, this message translates to:
  /// **'Q: Can I export data?'**
  String get faqExportData;

  /// No description provided for @faqExportDataAnswer.
  ///
  /// In en, this message translates to:
  /// **'A: You can export as CSV file using the data sharing feature in settings.'**
  String get faqExportDataAnswer;

  /// No description provided for @calorieCalcTitle.
  ///
  /// In en, this message translates to:
  /// **'About Calorie Calculation'**
  String get calorieCalcTitle;

  /// No description provided for @calorieCalcBasalMetabolism.
  ///
  /// In en, this message translates to:
  /// **'Basal Metabolism Calculation'**
  String get calorieCalcBasalMetabolism;

  /// No description provided for @calorieCalcBasalMetabolismDesc.
  ///
  /// In en, this message translates to:
  /// **'Using Harris-Benedict equation:\nMale: 13.397×weight + 4.799×height - 5.677×age + 88.362\nFemale: 9.247×weight + 3.098×height - 4.33×age + 447.593'**
  String get calorieCalcBasalMetabolismDesc;

  /// No description provided for @calorieCalcActivityFactor.
  ///
  /// In en, this message translates to:
  /// **'Activity Factor'**
  String get calorieCalcActivityFactor;

  /// No description provided for @calorieCalcActivityFactorDesc.
  ///
  /// In en, this message translates to:
  /// **'• Sedentary: 1.2\n• Light exercise: 1.375\n• Moderate exercise: 1.55\n• Heavy exercise: 1.725'**
  String get calorieCalcActivityFactorDesc;

  /// No description provided for @calorieCalcTargetCalorie.
  ///
  /// In en, this message translates to:
  /// **'Target Calorie'**
  String get calorieCalcTargetCalorie;

  /// No description provided for @calorieCalcTargetCalorieDesc.
  ///
  /// In en, this message translates to:
  /// **'Total calorie consumption - calories needed for weight loss + 300kcal (for flexibility)'**
  String get calorieCalcTargetCalorieDesc;

  /// No description provided for @healthManagementTitle.
  ///
  /// In en, this message translates to:
  /// **'Health Management Tips'**
  String get healthManagementTitle;

  /// No description provided for @healthManagementContinuation.
  ///
  /// In en, this message translates to:
  /// **'Continuation Points'**
  String get healthManagementContinuation;

  /// No description provided for @healthManagementContinuationDesc.
  ///
  /// In en, this message translates to:
  /// **'• Develop a habit of daily recording\n• Set realistic goals\n• Check progress regularly'**
  String get healthManagementContinuationDesc;

  /// No description provided for @healthManagementDietTips.
  ///
  /// In en, this message translates to:
  /// **'Diet Tips'**
  String get healthManagementDietTips;

  /// No description provided for @healthManagementDietTipsDesc.
  ///
  /// In en, this message translates to:
  /// **'• Aim for balanced meals\n• Actively consume vegetables\n• Don\'t forget hydration'**
  String get healthManagementDietTipsDesc;

  /// No description provided for @healthManagementExerciseTips.
  ///
  /// In en, this message translates to:
  /// **'Exercise Tips'**
  String get healthManagementExerciseTips;

  /// No description provided for @healthManagementExerciseTipsDesc.
  ///
  /// In en, this message translates to:
  /// **'• Start with manageable exercise\n• Choose exercises that are easy to continue\n• Incorporate exercise into daily life'**
  String get healthManagementExerciseTipsDesc;

  /// No description provided for @contactTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactTitle;

  /// No description provided for @contactDescription.
  ///
  /// In en, this message translates to:
  /// **'If you have trouble using the app, please contact us at:'**
  String get contactDescription;

  /// No description provided for @contactEmail.
  ///
  /// In en, this message translates to:
  /// **'Email: qgsky217@yahoo.co.jp'**
  String get contactEmail;

  /// No description provided for @edit_food_record_title.
  ///
  /// In en, this message translates to:
  /// **'Edit meal record'**
  String get edit_food_record_title;

  /// No description provided for @cancel_button_label.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel_button_label;

  /// No description provided for @update_button_label.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update_button_label;

  /// No description provided for @edit_exercise_record_title.
  ///
  /// In en, this message translates to:
  /// **'Edit exercise record'**
  String get edit_exercise_record_title;

  /// No description provided for @food_record_title.
  ///
  /// In en, this message translates to:
  /// **'Meal content'**
  String get food_record_title;

  /// No description provided for @record_weight_button_label.
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get record_weight_button_label;

  /// No description provided for @select_exercise_example_hint.
  ///
  /// In en, this message translates to:
  /// **'Please select an exercise example'**
  String get select_exercise_example_hint;

  /// No description provided for @add_exercise_example_button_label.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add_exercise_example_button_label;

  /// No description provided for @record_exercise_button_label.
  ///
  /// In en, this message translates to:
  /// **'Record exercise'**
  String get record_exercise_button_label;

  /// No description provided for @select_food_example_hint.
  ///
  /// In en, this message translates to:
  /// **'Please select an example'**
  String get select_food_example_hint;

  /// No description provided for @add_food_example_button_label.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add_food_example_button_label;

  /// No description provided for @save_record_button_label.
  ///
  /// In en, this message translates to:
  /// **'Save record'**
  String get save_record_button_label;

  /// No description provided for @exercises.
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get exercises;

  /// No description provided for @targetCalorieTitle.
  ///
  /// In en, this message translates to:
  /// **'Target Calories'**
  String get targetCalorieTitle;

  /// No description provided for @targetCalorieLabel.
  ///
  /// In en, this message translates to:
  /// **'Target Calories'**
  String get targetCalorieLabel;

  /// No description provided for @targetCalorieSettingTitle.
  ///
  /// In en, this message translates to:
  /// **'Target Calorie Setting'**
  String get targetCalorieSettingTitle;

  /// No description provided for @currentTargetLabel.
  ///
  /// In en, this message translates to:
  /// **'Current Target'**
  String get currentTargetLabel;

  /// No description provided for @dataSharingTitle.
  ///
  /// In en, this message translates to:
  /// **'Data Sharing'**
  String get dataSharingTitle;

  /// No description provided for @dataManagementTitle.
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get dataManagementTitle;

  /// No description provided for @deleteAllDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete All Data'**
  String get deleteAllDataTitle;

  /// No description provided for @deleteAllDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Delete all records and settings to initialize the app'**
  String get deleteAllDataSubtitle;

  /// No description provided for @deleteDataConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Data Deletion Confirmation'**
  String get deleteDataConfirmTitle;

  /// No description provided for @deleteDataConfirmContent.
  ///
  /// In en, this message translates to:
  /// **'All records and settings will be completely deleted.\n\nThis operation cannot be undone.\nAre you sure you want to delete?'**
  String get deleteDataConfirmContent;

  /// No description provided for @deleteDataConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteDataConfirmButton;

  /// No description provided for @deleteDataSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'All data has been deleted. The app has been initialized.'**
  String get deleteDataSuccessMessage;

  /// No description provided for @deleteDataErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while deleting data'**
  String get deleteDataErrorMessage;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// No description provided for @setupDescription.
  ///
  /// In en, this message translates to:
  /// **'Please enter the following information for more accurate calorie calculation'**
  String get setupDescription;

  /// No description provided for @basicInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get basicInfoTitle;

  /// No description provided for @ageLabel.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get ageLabel;

  /// No description provided for @heightLabel.
  ///
  /// In en, this message translates to:
  /// **'Height (cm)'**
  String get heightLabel;

  /// No description provided for @currentWeightLabel.
  ///
  /// In en, this message translates to:
  /// **'Current Weight (kg)'**
  String get currentWeightLabel;

  /// No description provided for @targetWeightLabel.
  ///
  /// In en, this message translates to:
  /// **'Target Weight (kg)'**
  String get targetWeightLabel;

  /// No description provided for @recommendedTargetWeightTitle.
  ///
  /// In en, this message translates to:
  /// **'Recommended Target Weight'**
  String get recommendedTargetWeightTitle;

  /// No description provided for @recommendedTargetWeightDesc.
  ///
  /// In en, this message translates to:
  /// **'5% of body weight per month is recommended (e.g., 57kg for 60kg)'**
  String get recommendedTargetWeightDesc;

  /// No description provided for @recommendedTargetWeightNote.
  ///
  /// In en, this message translates to:
  /// **'※Excessive weight loss can cause hormonal imbalance, muscle loss, and metabolic decline, leading to rebound'**
  String get recommendedTargetWeightNote;

  /// No description provided for @goalDaysLabel.
  ///
  /// In en, this message translates to:
  /// **'Goal Achievement Days'**
  String get goalDaysLabel;

  /// No description provided for @detailedSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Detailed Settings'**
  String get detailedSettingsTitle;

  /// No description provided for @genderLabel.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get genderLabel;

  /// No description provided for @genderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get genderFemale;

  /// No description provided for @genderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get genderMale;

  /// No description provided for @activityLevelLabel.
  ///
  /// In en, this message translates to:
  /// **'Daily Activity Level'**
  String get activityLevelLabel;

  /// No description provided for @activityLevelLow.
  ///
  /// In en, this message translates to:
  /// **'Little exercise'**
  String get activityLevelLow;

  /// No description provided for @activityLevelMedium.
  ///
  /// In en, this message translates to:
  /// **'Moderate exercise'**
  String get activityLevelMedium;

  /// No description provided for @activityLevelHigh.
  ///
  /// In en, this message translates to:
  /// **'High intensity exercise'**
  String get activityLevelHigh;

  /// No description provided for @privacyPolicyLink.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyLink;

  /// No description provided for @todayTargetCalories.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Target Calories'**
  String get todayTargetCalories;

  /// No description provided for @consumedCalories.
  ///
  /// In en, this message translates to:
  /// **'Consumed'**
  String get consumedCalories;

  /// No description provided for @remainingCalories.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remainingCalories;

  /// No description provided for @allFieldsRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter all fields'**
  String get allFieldsRequired;

  /// No description provided for @notificationSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettingsTitle;

  /// No description provided for @notificationSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage app notifications'**
  String get notificationSettingsSubtitle;

  /// No description provided for @healthDataSyncTitle.
  ///
  /// In en, this message translates to:
  /// **'Health Data Sync'**
  String get healthDataSyncTitle;

  /// No description provided for @healthDataSyncSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Data synchronization with other health apps'**
  String get healthDataSyncSubtitle;

  /// No description provided for @appInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'App Information'**
  String get appInfoTitle;

  /// No description provided for @appInfoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Detailed app information'**
  String get appInfoSubtitle;

  /// No description provided for @rewardedAdButtonText.
  ///
  /// In en, this message translates to:
  /// **'Watch ad to unlock special features'**
  String get rewardedAdButtonText;

  /// No description provided for @healthTipsTitle.
  ///
  /// In en, this message translates to:
  /// **'Health Management Tips'**
  String get healthTipsTitle;

  /// No description provided for @healthTipsContent.
  ///
  /// In en, this message translates to:
  /// **'• Record meals daily to make calorie management a habit\n• Be mindful of target calories and aim for balanced meals\n• Check progress in graphs to maintain motivation'**
  String get healthTipsContent;

  /// No description provided for @specialFeatureUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Special features unlocked!'**
  String get specialFeatureUnlocked;

  /// No description provided for @shareDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Share Data'**
  String get shareDataTitle;

  /// No description provided for @shareDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share record data as CSV file'**
  String get shareDataSubtitle;

  /// No description provided for @shareAppTitle.
  ///
  /// In en, this message translates to:
  /// **'Share App'**
  String get shareAppTitle;

  /// No description provided for @todayWeightTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Weight'**
  String get todayWeightTitle;

  /// No description provided for @weightLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weightLabel;

  /// No description provided for @calorieStatusTitle.
  ///
  /// In en, this message translates to:
  /// **'Calorie Status'**
  String get calorieStatusTitle;

  /// No description provided for @targetIntakeTitle.
  ///
  /// In en, this message translates to:
  /// **'Target Intake'**
  String get targetIntakeTitle;

  /// No description provided for @exerciseRemainingTitle.
  ///
  /// In en, this message translates to:
  /// **'Exercise Remaining'**
  String get exerciseRemainingTitle;

  /// No description provided for @exerciseRecordTitle.
  ///
  /// In en, this message translates to:
  /// **'Exercise Record'**
  String get exerciseRecordTitle;

  /// No description provided for @selectExampleHint.
  ///
  /// In en, this message translates to:
  /// **'Select example'**
  String get selectExampleHint;

  /// No description provided for @exerciseNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Exercise Name'**
  String get exerciseNameLabel;

  /// No description provided for @burnedCaloriesLabel.
  ///
  /// In en, this message translates to:
  /// **'Burned Calories'**
  String get burnedCaloriesLabel;

  /// No description provided for @mealRecordTitle.
  ///
  /// In en, this message translates to:
  /// **'Meal Record'**
  String get mealRecordTitle;

  /// No description provided for @selectMealExampleHint.
  ///
  /// In en, this message translates to:
  /// **'Select example'**
  String get selectMealExampleHint;

  /// No description provided for @mealContentLabel.
  ///
  /// In en, this message translates to:
  /// **'Meal Content'**
  String get mealContentLabel;

  /// No description provided for @caloriesLabel.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get caloriesLabel;

  /// No description provided for @mealRecordedMessage.
  ///
  /// In en, this message translates to:
  /// **'Meal recorded'**
  String get mealRecordedMessage;

  /// No description provided for @todayRecordTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Record'**
  String get todayRecordTitle;

  /// No description provided for @mealsTitle.
  ///
  /// In en, this message translates to:
  /// **'Meals'**
  String get mealsTitle;

  /// No description provided for @exerciseRecordedMessage.
  ///
  /// In en, this message translates to:
  /// **'Exercise recorded'**
  String get exerciseRecordedMessage;

  /// No description provided for @exercisesTitle.
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get exercisesTitle;

  /// No description provided for @dummyDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Generate Dummy Data'**
  String get dummyDataTitle;

  /// No description provided for @dummyDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Generate 1 week of random dummy data'**
  String get dummyDataSubtitle;

  /// No description provided for @dummyDataConfirmContent.
  ///
  /// In en, this message translates to:
  /// **'Generate 1 week of random dummy data.\n\nExisting data will be preserved.'**
  String get dummyDataConfirmContent;

  /// No description provided for @generateDummyDataButton.
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get generateDummyDataButton;

  /// No description provided for @dummyDataSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Generated 1 week of dummy data.'**
  String get dummyDataSuccessMessage;

  /// No description provided for @dummyDataErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Error occurred while generating dummy data'**
  String get dummyDataErrorMessage;

  /// No description provided for @snackMealUpdated.
  ///
  /// In en, this message translates to:
  /// **'Meal record updated'**
  String get snackMealUpdated;

  /// No description provided for @snackExerciseUpdated.
  ///
  /// In en, this message translates to:
  /// **'Exercise record updated'**
  String get snackExerciseUpdated;

  /// No description provided for @mealExampleChicken.
  ///
  /// In en, this message translates to:
  /// **'Chicken breast without skin 100g'**
  String get mealExampleChicken;

  /// No description provided for @mealExampleRice.
  ///
  /// In en, this message translates to:
  /// **'White rice 1 cup'**
  String get mealExampleRice;

  /// No description provided for @mealExampleNatto.
  ///
  /// In en, this message translates to:
  /// **'Natto 1 pack'**
  String get mealExampleNatto;

  /// No description provided for @mealExampleEgg.
  ///
  /// In en, this message translates to:
  /// **'Egg 1 piece'**
  String get mealExampleEgg;

  /// No description provided for @mealExampleMilk.
  ///
  /// In en, this message translates to:
  /// **'Milk 200ml'**
  String get mealExampleMilk;

  /// No description provided for @mealExampleBanana.
  ///
  /// In en, this message translates to:
  /// **'Banana 1 piece'**
  String get mealExampleBanana;

  /// No description provided for @mealExampleApple.
  ///
  /// In en, this message translates to:
  /// **'Apple 1 piece'**
  String get mealExampleApple;

  /// No description provided for @mealExampleYogurt.
  ///
  /// In en, this message translates to:
  /// **'Yogurt 100g'**
  String get mealExampleYogurt;

  /// No description provided for @mealExampleSalad.
  ///
  /// In en, this message translates to:
  /// **'Salad (lettuce, tomato)'**
  String get mealExampleSalad;

  /// No description provided for @mealExampleMisoSoup.
  ///
  /// In en, this message translates to:
  /// **'Miso soup 1 bowl'**
  String get mealExampleMisoSoup;

  /// No description provided for @mealExampleGrilledFish.
  ///
  /// In en, this message translates to:
  /// **'Grilled fish 1 piece'**
  String get mealExampleGrilledFish;

  /// No description provided for @mealExampleTofu.
  ///
  /// In en, this message translates to:
  /// **'Tofu 1/2 block'**
  String get mealExampleTofu;

  /// No description provided for @mealExampleBrownRice.
  ///
  /// In en, this message translates to:
  /// **'Brown rice 1 cup'**
  String get mealExampleBrownRice;

  /// No description provided for @mealExampleSweetPotato.
  ///
  /// In en, this message translates to:
  /// **'Sweet potato 1 piece'**
  String get mealExampleSweetPotato;

  /// No description provided for @exerciseExampleWalking.
  ///
  /// In en, this message translates to:
  /// **'Walking 20 minutes'**
  String get exerciseExampleWalking;

  /// No description provided for @exerciseExampleJogging.
  ///
  /// In en, this message translates to:
  /// **'Jogging 10 minutes'**
  String get exerciseExampleJogging;

  /// No description provided for @exerciseExampleStrengthTraining.
  ///
  /// In en, this message translates to:
  /// **'Strength training 20 minutes'**
  String get exerciseExampleStrengthTraining;

  /// No description provided for @exerciseExampleSwimming.
  ///
  /// In en, this message translates to:
  /// **'Swimming 30 minutes'**
  String get exerciseExampleSwimming;

  /// No description provided for @exerciseExampleCycling.
  ///
  /// In en, this message translates to:
  /// **'Cycling 30 minutes'**
  String get exerciseExampleCycling;

  /// No description provided for @exerciseExampleYoga.
  ///
  /// In en, this message translates to:
  /// **'Yoga 30 minutes'**
  String get exerciseExampleYoga;

  /// No description provided for @exerciseExampleStretching.
  ///
  /// In en, this message translates to:
  /// **'Stretching 15 minutes'**
  String get exerciseExampleStretching;

  /// No description provided for @exerciseExampleDancing.
  ///
  /// In en, this message translates to:
  /// **'Dancing 30 minutes'**
  String get exerciseExampleDancing;

  /// No description provided for @exerciseExampleStairs.
  ///
  /// In en, this message translates to:
  /// **'Climbing stairs 10 minutes'**
  String get exerciseExampleStairs;

  /// No description provided for @exerciseExampleRunning.
  ///
  /// In en, this message translates to:
  /// **'Running 15 minutes'**
  String get exerciseExampleRunning;

  /// No description provided for @weightRecordedLabel.
  ///
  /// In en, this message translates to:
  /// **'Recorded'**
  String get weightRecordedLabel;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ja', 'ko', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'ja': return AppLocalizationsJa();
    case 'ko': return AppLocalizationsKo();
    case 'zh': return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}

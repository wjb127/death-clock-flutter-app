import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';

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
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('ja'),
    Locale('ko')
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Life Timer Calculator'**
  String get appTitle;

  /// The subtitle of the application
  ///
  /// In en, this message translates to:
  /// **'Life Timer'**
  String get appSubtitle;

  /// Settings menu title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Instruction to select birthday
  ///
  /// In en, this message translates to:
  /// **'Select your birthday'**
  String get selectBirthday;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Label for remaining life time
  ///
  /// In en, this message translates to:
  /// **'Remaining Life'**
  String get remainingLife;

  /// Label for life progress percentage
  ///
  /// In en, this message translates to:
  /// **'Life Progress'**
  String get lifeProgress;

  /// Time unit: years
  ///
  /// In en, this message translates to:
  /// **'years'**
  String get years;

  /// Time unit: days
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// Time unit: hours
  ///
  /// In en, this message translates to:
  /// **'hours'**
  String get hours;

  /// Time unit: minutes
  ///
  /// In en, this message translates to:
  /// **'minutes'**
  String get minutes;

  /// Time unit: seconds
  ///
  /// In en, this message translates to:
  /// **'seconds'**
  String get seconds;

  /// Daily notifications setting
  ///
  /// In en, this message translates to:
  /// **'3 Daily Notifications (8AM, 1PM, 6PM)'**
  String get dailyNotifications;

  /// Message when notifications are enabled
  ///
  /// In en, this message translates to:
  /// **'Daily notifications set for 8AM, 1PM, and 6PM! 🔔'**
  String get notificationEnabled;

  /// Message when notifications are disabled
  ///
  /// In en, this message translates to:
  /// **'Notifications disabled.'**
  String get notificationDisabled;

  /// Button to share life statistics
  ///
  /// In en, this message translates to:
  /// **'Share Life Stats'**
  String get shareLifeStats;

  /// Button to view another motivational quote
  ///
  /// In en, this message translates to:
  /// **'View Other Quote'**
  String get viewOtherQuote;

  /// Label for birthday
  ///
  /// In en, this message translates to:
  /// **'Birthday'**
  String get birthday;

  /// Message template for sharing
  ///
  /// In en, this message translates to:
  /// **'⏰ Death Clock Life Check Result\n\n📅 Birthday: {birthday}\n⏳ Remaining Life: {remainingTime}\n📊 Life Progress: {progress}%\n💭 \"{quote}\"\n\nWhat\'s your remaining time? Check with Death Clock app!'**
  String shareMessage(
      Object birthday, Object progress, Object quote, Object remainingTime);

  /// Motivational quote 1
  ///
  /// In en, this message translates to:
  /// **'Time is life. Don\'t waste it.'**
  String get quote1;

  /// Motivational quote 2
  ///
  /// In en, this message translates to:
  /// **'Every moment is precious. Live this moment.'**
  String get quote2;

  /// Motivational quote 3
  ///
  /// In en, this message translates to:
  /// **'Those who save time gain life.'**
  String get quote3;

  /// Motivational quote 4
  ///
  /// In en, this message translates to:
  /// **'Don\'t put off until tomorrow what you can do today.'**
  String get quote4;

  /// Motivational quote 5
  ///
  /// In en, this message translates to:
  /// **'Time doesn\'t come back. Focus on the present.'**
  String get quote5;

  /// Notification message 1
  ///
  /// In en, this message translates to:
  /// **'⏰ Check your remaining life and wake up!'**
  String get notificationMessage1;

  /// Notification message 2
  ///
  /// In en, this message translates to:
  /// **'💀 Time doesn\'t wait. Check now!'**
  String get notificationMessage2;

  /// Notification message 3
  ///
  /// In en, this message translates to:
  /// **'⚡ Every moment is precious. Check your remaining time!'**
  String get notificationMessage3;

  /// Notification message 4
  ///
  /// In en, this message translates to:
  /// **'🔥 Life is short. Make today meaningful!'**
  String get notificationMessage4;

  /// Notification message 5
  ///
  /// In en, this message translates to:
  /// **'💎 Time is your most precious asset. Check it!'**
  String get notificationMessage5;

  /// Notification message 6
  ///
  /// In en, this message translates to:
  /// **'🚀 Run towards your goals. Check your remaining time!'**
  String get notificationMessage6;

  /// Notification message 7
  ///
  /// In en, this message translates to:
  /// **'⭐ Cherish today too! Check your life timer'**
  String get notificationMessage7;

  /// Notification message 8
  ///
  /// In en, this message translates to:
  /// **'🎯 First step of time management: Check remaining life'**
  String get notificationMessage8;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'ja', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}

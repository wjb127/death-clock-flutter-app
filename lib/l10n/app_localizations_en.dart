// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Life Timer';

  @override
  String get appSubtitle => 'Life Timer';

  @override
  String get settings => 'Settings';

  @override
  String get selectBirthday => 'Select your birthday';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get remainingLife => 'Remaining Life';

  @override
  String get lifeProgress => 'Life Progress';

  @override
  String get years => ' years';

  @override
  String get days => ' days';

  @override
  String get hours => ' hours';

  @override
  String get minutes => ' min';

  @override
  String get seconds => ' sec';

  @override
  String get dailyNotifications => '3 Daily Notifications (8AM, 1PM, 6PM)';

  @override
  String get notificationEnabled =>
      'Daily notifications set for 8AM, 1PM, and 6PM! 🔔';

  @override
  String get notificationDisabled => 'Notifications disabled.';

  @override
  String get shareLifeStats => 'Share Life Stats';

  @override
  String get viewOtherQuote => 'View Other Quote';

  @override
  String get birthday => 'Birthday';

  @override
  String shareMessage(String birthday, String remainingTime, String progress,
      String quote, String link) {
    return '⏰ My Life Timer\n\n📅 Birthday: $birthday\n⏳ Time left: $remainingTime\n📊 Life progress: $progress%\n💭 \"$quote\"\n\nCheck your own time left 👉 $link';
  }

  @override
  String get quote1 => 'Time is life. Don\'t waste it.';

  @override
  String get quote2 => 'Every moment is precious. Live this moment.';

  @override
  String get quote3 => 'Those who save time gain life.';

  @override
  String get quote4 => 'Don\'t put off until tomorrow what you can do today.';

  @override
  String get quote5 => 'Time doesn\'t come back. Focus on the present.';

  @override
  String get notificationMessage1 => '⏰ Check your remaining life and wake up!';

  @override
  String get notificationMessage2 => '💀 Time doesn\'t wait. Check now!';

  @override
  String get notificationMessage3 =>
      '⚡ Every moment is precious. Check your remaining time!';

  @override
  String get notificationMessage4 => '🔥 Life is short. Make today meaningful!';

  @override
  String get notificationMessage5 =>
      '💎 Time is your most precious asset. Check it!';

  @override
  String get notificationMessage6 =>
      '🚀 Run towards your goals. Check your remaining time!';

  @override
  String get notificationMessage7 =>
      '⭐ Cherish today too! Check your life timer';

  @override
  String get notificationMessage8 =>
      '🎯 First step of time management: Check remaining life';

  @override
  String get change => 'Change';

  @override
  String get showRemainingLife => 'Show remaining time';

  @override
  String get close => 'Close';
}

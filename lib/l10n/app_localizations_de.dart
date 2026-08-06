// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Lebenszeit-Rechner';

  @override
  String get appSubtitle => 'Lebenszeit-Rechner';

  @override
  String get settings => 'Einstellungen';

  @override
  String get selectBirthday => 'Wählen Sie Ihr Geburtsdatum';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get confirm => 'Bestätigen';

  @override
  String get remainingLife => 'Verbleibende Lebenszeit';

  @override
  String get lifeProgress => 'Lebensfortschritt';

  @override
  String get years => 'Jahre';

  @override
  String get days => 'Tage';

  @override
  String get hours => 'Stunden';

  @override
  String get minutes => 'Minuten';

  @override
  String get seconds => 'Sekunden';

  @override
  String get dailyNotifications => 'Tägliche Benachrichtigungen';

  @override
  String get notificationEnabled =>
      'Tägliche Benachrichtigung um 8 Uhr morgens eingestellt! 🔔';

  @override
  String get notificationDisabled => 'Benachrichtigungen deaktiviert.';

  @override
  String get shareLifeStats => 'Lebensstatistiken teilen';

  @override
  String get viewOtherQuote => 'Anderes Zitat anzeigen';

  @override
  String get birthday => 'Geburtstag';

  @override
  String shareMessage(
      Object birthday, Object progress, Object quote, Object remainingTime) {
    return '⏰ Death Clock Lebenszeit-Check Ergebnis\n\n📅 Geburtstag: $birthday\n⏳ Verbleibende Lebenszeit: $remainingTime\n📊 Lebensfortschritt: $progress%\n💭 \"$quote\"\n\nWie viel Zeit bleibt Ihnen? Überprüfen Sie es mit der Death Clock App!';
  }

  @override
  String get quote1 => 'Zeit ist Leben. Verschwende sie nicht.';

  @override
  String get quote2 => 'Jeder Moment ist kostbar. Lebe diesen Moment.';

  @override
  String get quote3 => 'Wer Zeit spart, gewinnt Leben.';

  @override
  String get quote4 => 'Verschiebe nicht auf morgen, was du heute tun kannst.';

  @override
  String get quote5 =>
      'Zeit kommt nicht zurück. Konzentriere dich auf die Gegenwart.';

  @override
  String get notificationMessage1 =>
      '⏰ Überprüfen Sie Ihre verbleibende Lebenszeit und wachen Sie auf!';

  @override
  String get notificationMessage2 =>
      '💀 Die Zeit wartet nicht. Überprüfen Sie jetzt!';

  @override
  String get notificationMessage3 =>
      '⚡ Jeder Moment ist kostbar. Überprüfen Sie Ihre verbleibende Zeit!';

  @override
  String get notificationMessage4 =>
      '🔥 Das Leben ist kurz. Machen Sie heute sinnvoll!';

  @override
  String get notificationMessage5 =>
      '💎 Zeit ist Ihr wertvollstes Gut. Überprüfen Sie es!';

  @override
  String get notificationMessage6 =>
      '🚀 Laufen Sie auf Ihre Ziele zu. Überprüfen Sie Ihre verbleibende Zeit!';

  @override
  String get notificationMessage7 =>
      '⭐ Schätzen Sie auch heute! Gehen Sie zur Lebenszeit-Überprüfung';

  @override
  String get notificationMessage8 =>
      '🎯 Erster Schritt des Zeitmanagements: Verbleibende Lebenszeit überprüfen';
}

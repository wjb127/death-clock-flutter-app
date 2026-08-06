// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => '寿命計算機';

  @override
  String get appSubtitle => '寿命計算機';

  @override
  String get settings => '設定';

  @override
  String get selectBirthday => '誕生日を選択してください';

  @override
  String get cancel => 'キャンセル';

  @override
  String get confirm => '確認';

  @override
  String get remainingLife => '残り寿命';

  @override
  String get lifeProgress => '人生進行率';

  @override
  String get years => '年';

  @override
  String get days => '日';

  @override
  String get hours => '時間';

  @override
  String get minutes => '分';

  @override
  String get seconds => '秒';

  @override
  String get dailyNotifications => '毎日通知';

  @override
  String get notificationEnabled => '毎朝8時に通知が設定されました！🔔';

  @override
  String get notificationDisabled => '通知が無効になりました。';

  @override
  String get shareLifeStats => '寿命をシェア';

  @override
  String get viewOtherQuote => '他の名言を見る';

  @override
  String get birthday => '誕生日';

  @override
  String shareMessage(
      Object birthday, Object progress, Object quote, Object remainingTime) {
    return '⏰ Death Clock 寿命チェック結果\n\n📅 誕生日: $birthday\n⏳ 残り寿命: $remainingTime\n📊 人生進行率: $progress%\n💭 \"$quote\"\n\nあなたの残り時間は？Death Clockアプリで確認してみてください！';
  }

  @override
  String get quote1 => '時間は命である。無駄にするな。';

  @override
  String get quote2 => 'すべての瞬間が貴重だ。今この瞬間を生きろ。';

  @override
  String get quote3 => '時間を節約する者が人生を得る。';

  @override
  String get quote4 => '今日できることを明日に延ばすな。';

  @override
  String get quote5 => '時間は戻らない。現在に集中せよ。';

  @override
  String get notificationMessage1 => '⏰ 残り寿命を確認して目を覚ませ！';

  @override
  String get notificationMessage2 => '💀 時間は待ってくれません。今すぐ確認を！';

  @override
  String get notificationMessage3 => '⚡ すべての瞬間が貴重です。残り時間をチェック！';

  @override
  String get notificationMessage4 => '🔥 人生は短い。今日も意味のある一日を！';

  @override
  String get notificationMessage5 => '💎 時間は最も貴重な資産です。確認してみて！';

  @override
  String get notificationMessage6 => '🚀 目標に向かって走れ。残り時間を確認！';

  @override
  String get notificationMessage7 => '⭐ 今日も大切に！寿命チェックしに行こう';

  @override
  String get notificationMessage8 => '🎯 時間管理の第一歩、残り寿命の確認';
}

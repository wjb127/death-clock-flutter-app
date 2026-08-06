// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => '남은수명계산기';

  @override
  String get appSubtitle => '수명 계산기';

  @override
  String get settings => '설정';

  @override
  String get selectBirthday => '생일을 선택하세요';

  @override
  String get cancel => '취소';

  @override
  String get confirm => '확인';

  @override
  String get remainingLife => '남은 수명';

  @override
  String get lifeProgress => '인생 진행률';

  @override
  String get years => '년';

  @override
  String get days => '일';

  @override
  String get hours => '시간';

  @override
  String get minutes => '분';

  @override
  String get seconds => '초';

  @override
  String get dailyNotifications => '하루 3번 알림 (8시, 13시, 18시)';

  @override
  String get notificationEnabled => '매일 8시, 13시, 18시에 알림이 설정되었습니다! 🔔';

  @override
  String get notificationDisabled => '알림이 해제되었습니다.';

  @override
  String get shareLifeStats => '수명 공유하기';

  @override
  String get viewOtherQuote => '다른 명언 보기';

  @override
  String get birthday => '생일';

  @override
  String shareMessage(
      Object birthday, Object progress, Object quote, Object remainingTime) {
    return '⏰ Death Clock 수명 체크 결과\n\n📅 생일: $birthday\n⏳ 남은 수명: $remainingTime\n📊 인생 진행률: $progress%\n💭 \"$quote\"\n\n당신의 남은 시간은? Death Clock 앱으로 확인해보세요!';
  }

  @override
  String get quote1 => '시간은 생명이다. 낭비하지 마라.';

  @override
  String get quote2 => '매 순간이 소중하다. 지금 이 순간을 살아라.';

  @override
  String get quote3 => '시간을 아끼는 자가 인생을 얻는다.';

  @override
  String get quote4 => '오늘 할 수 있는 일을 내일로 미루지 마라.';

  @override
  String get quote5 => '시간은 돌아오지 않는다. 현재에 집중하라.';

  @override
  String get notificationMessage1 => '⏰ 남은 수명을 확인하고 정신차리세요!';

  @override
  String get notificationMessage2 => '💀 시간은 기다려주지 않습니다. 지금 확인하세요!';

  @override
  String get notificationMessage3 => '⚡ 매 순간이 소중합니다. 남은 시간을 체크하세요!';

  @override
  String get notificationMessage4 => '🔥 인생은 짧습니다. 오늘도 의미있게 보내세요!';

  @override
  String get notificationMessage5 => '💎 시간은 가장 귀한 자산입니다. 확인해보세요!';

  @override
  String get notificationMessage6 => '🚀 목표를 향해 달려가세요. 남은 시간을 확인하세요!';

  @override
  String get notificationMessage7 => '⭐ 오늘 하루도 소중히! 수명 체크하러 가기';

  @override
  String get notificationMessage8 => '🎯 시간 관리의 첫걸음, 남은 수명 확인하기';
}

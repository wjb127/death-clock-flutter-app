// 푸시 알림 서비스
// 하루 3번(아침·점심·저녁) 동기부여 메시지를 기기 로컬 시간 기준으로 보낸다.

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'l10n/app_localizations.dart';

/// 알림을 띄울 시각(기기 로컬 기준 24시간제).
const List<int> kNotificationHours = <int>[8, 13, 18];

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'daily_reminder';
  static const String _channelName = 'Daily Life Reminder';

  // 다국어 동기부여 메시지
  static List<String> getMotivationalMessages(AppLocalizations l10n) {
    return [
      l10n.notificationMessage1,
      l10n.notificationMessage2,
      l10n.notificationMessage3,
      l10n.notificationMessage4,
      l10n.notificationMessage5,
      l10n.notificationMessage6,
      l10n.notificationMessage7,
      l10n.notificationMessage8,
    ];
  }

  // === 초기화 ===
  static Future<void> initialize() async {
    try {
      tz.initializeTimeZones();
      await _configureLocalTimeZone();

      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
        // Ask only when the user enables reminders, after any ad consent UI.
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const InitializationSettings settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(settings);
    } catch (e) {
      debugPrint('알림 서비스 초기화 실패: $e');
      // 초기화 실패해도 앱은 계속 실행
    }
  }

  /// tz.local 을 기기 시간대로 맞춘다.
  ///
  /// ★ 이걸 빠뜨리면 알림이 통째로 엉뚱한 시간에 울린다.
  /// timezone 패키지의 initializeTimeZones()는 tz.local 을 **UTC로** 초기화한다
  /// (timezone/lib/src/env.dart 의 initializeDatabase 가 `_local = _UTC`).
  /// 그 상태로 8시를 예약하면 08:00 UTC = 한국 17시에 울린다.
  /// 실제로 이 앱이 그 상태로 출시돼 있었다.
  static Future<void> _configureLocalTimeZone() async {
    try {
      // flutter_timezone 5.x 는 TimezoneInfo 를 준다. IANA 식별자만 쓴다.
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (e) {
      // 시간대 이름을 못 읽으면 tz.local 은 UTC로 남는다.
      // 그래도 첫 발송 시각은 어긋나지 않는다 — nextInstanceOfTime 이
      // 기기 로컬 DateTime 으로 절대시각을 잡고 변환하기 때문.
      debugPrint('기기 시간대 확인 실패, UTC로 진행: $e');
    }
  }

  // === 권한 요청 ===
  static Future<void> requestPermissions() async {
    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  // === 매일 반복 알림 예약 ===
  //
  // 같은 메시지가 매일 똑같이 뜨지 않도록, 앱을 열 때마다 다시 예약한다
  // (matchDateTimeComponents.time 은 예약 당시의 제목·본문을 그대로 반복한다).
  static Future<void> scheduleDaily(AppLocalizations l10n) async {
    final messages = getMotivationalMessages(l10n);
    // 세 알림이 같은 문구가 되지 않게 서로 다른 메시지를 뽑는다.
    final picked = List<String>.from(messages)..shuffle(Random());

    await cancelAllNotifications();

    for (int i = 0; i < kNotificationHours.length; i++) {
      final hour = kNotificationHours[i];
      final details = NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: 'Daily life reminder notifications',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      try {
        await _notifications.zonedSchedule(
          i + 1,
          l10n.appTitle,
          picked[i % picked.length],
          nextInstanceOfTime(hour, 0),
          details,
          // ★ exact(기본값)이 아니라 inexact 를 쓴다.
          // exact 는 SCHEDULE_EXACT_ALARM/USE_EXACT_ALARM 을 요구하는데,
          // USE_EXACT_ALARM 은 Play가 알람시계·캘린더 앱에만 허용하는
          // 제한 권한이라 이런 리마인더 앱이 달고 있으면 정책 리스크가 된다.
          // 하루 3번 동기부여 알림에 분 단위 정확도는 필요 없다.
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      } catch (e) {
        // 한 슬롯이 실패해도 나머지는 예약한다.
        // (예전 구현은 여기서 통째로 빠져나가 3개 중 1개만 걸렸다.)
        debugPrint('알림 예약 실패 ($hour시): $e');
      }
    }
  }

  /// 알림이 켜져 있을 때만 다시 예약한다. 앱 시작 시 호출해 문구를 갱신한다.
  static Future<void> refreshIfEnabled(
      AppLocalizations l10n, bool enabled) async {
    if (!enabled) return;
    await scheduleDaily(l10n);
  }

  // === 다음 발송 시각 ===
  //
  // 기기 로컬 DateTime 으로 "다음 hour시 minute분"이라는 **절대 시각**을 먼저 정하고,
  // 그걸 tz.local 표현으로 변환한다. tz.local 설정이 실패해 UTC로 남아 있어도
  // 첫 발송 시각만큼은 사용자가 기대한 시계 시각에 맞는다.
  static tz.TZDateTime nextInstanceOfTime(int hour, int minute,
      {DateTime? now}) {
    final DateTime current = now ?? DateTime.now();
    DateTime target =
        DateTime(current.year, current.month, current.day, hour, minute);

    if (!target.isAfter(current)) {
      target = target.add(const Duration(days: 1));
    }

    return tz.TZDateTime.from(target, tz.local);
  }

  // === 즉시 테스트 알림 ===
  static Future<void> sendTestNotification(AppLocalizations l10n) async {
    final messages = getMotivationalMessages(l10n);
    final message = messages[Random().nextInt(messages.length)];

    await _notifications.show(
      999,
      '${l10n.appTitle} (Test)',
      '$message\n\n${l10n.notificationEnabled}',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_notification',
          'Test Notification',
          channelDescription: 'For testing notifications',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  // === 전체 취소 ===
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}

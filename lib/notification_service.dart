// 푸시 알림 서비스 클래스
// 매일 정해진 시간에 동기부여 메시지를 전송하는 기능 제공

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NotificationService {
  // 알림 플러그인 인스턴스
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  
  // 다국어 지원 동기부여 메시지 목록을 반환하는 함수
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

  // === 알림 서비스 초기화 ===
  static Future<void> initialize() async {
    try {
      tz.initializeTimeZones(); // 타임존 데이터 초기화
      
      // Android 알림 설정
      const AndroidInitializationSettings androidSettings = 
          AndroidInitializationSettings('@mipmap/ic_launcher'); // 앱 아이콘 사용
      
      // iOS 알림 설정
      const DarwinInitializationSettings iosSettings = 
          DarwinInitializationSettings(
            requestAlertPermission: true,  // 알림 표시 권한
            requestBadgePermission: true,  // 뱃지 표시 권한
            requestSoundPermission: true,  // 소리 재생 권한
          );
      
      // 플랫폼별 설정 통합
      const InitializationSettings settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );
      
      await _notifications.initialize(settings);
    } catch (e) {
      print('알림 서비스 초기화 실패: $e');
      // 초기화 실패해도 앱은 계속 실행
    }
  }

  // === 알림 권한 요청 ===
  static Future<void> requestPermissions() async {
    // Android 알림 권한 요청
    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    
    // iOS 알림 권한 요청
    await _notifications
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,  // 알림 표시
          badge: true,  // 뱃지 표시
          sound: true,  // 소리 재생
        );
  }

  // === 매일 반복 알림 스케줄링 (기본 영어 메시지) ===
  static Future<void> scheduleDailyNotification() async {
    // 기본 영어 메시지 사용 (앱 컨텍스트 없이 호출되는 경우)
    final messages = [
      "⏰ Check your remaining life and wake up!",
      "💀 Time doesn't wait. Check now!",
      "⚡ Every moment is precious. Check your remaining time!",
      "🔥 Life is short. Make today meaningful!",
      "💎 Time is your most precious asset. Check it!",
      "🚀 Run towards your goals. Check your remaining time!",
      "⭐ Cherish today too! Check your life timer",
      "🎯 First step of time management: Check remaining life",
    ];
    
    final random = Random();
    
    try {
      // 하루 3번 알림 설정 (8시, 13시, 18시)
      final notificationTimes = [
        {'hour': 8, 'id': 1, 'title': 'Life Timer - Morning'},
        {'hour': 13, 'id': 2, 'title': 'Life Timer - Afternoon'},
        {'hour': 18, 'id': 3, 'title': 'Life Timer - Evening'},
      ];
      
      for (final timeInfo in notificationTimes) {
        final message = messages[random.nextInt(messages.length)];
        
        await _notifications.zonedSchedule(
          timeInfo['id'] as int, // 각각 다른 알림 ID
          timeInfo['title'] as String, // 시간대별 제목
          message, // 알림 내용
          _nextInstanceOfTime(timeInfo['hour'] as int, 0), // 지정된 시간
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'daily_reminder', // 채널 ID
              'Daily Life Reminder', // 채널 이름
              channelDescription: '매일 수명 확인 알림 (하루 3번)',
              importance: Importance.high, // 높은 우선순위
              priority: Priority.high,
              icon: '@mipmap/ic_launcher', // 알림 아이콘
            ),
            iOS: DarwinNotificationDetails(
              sound: 'default.wav',
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time, // 매일 같은 시간 반복
        );
      }
    } catch (e) {
      // 정확한 알람이 허용되지 않는 경우, 대략적인 시간으로 스케줄링
      print('정확한 알람 권한이 없습니다. 대략적인 시간으로 설정합니다: $e');
      
      // 대신 24시간 간격 반복 알림으로 설정 (덜 정확하지만 작동함)
      final message = messages[random.nextInt(messages.length)];
      await _notifications.periodicallyShow(
        1,
        'Life Timer ⏰',
        message,
        RepeatInterval.daily, // 24시간마다 반복
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_reminder',
            'Daily Life Reminder',
            channelDescription: '매일 수명 확인 알림',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            sound: 'default.wav',
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
    }
  }

  // === 다국어 지원 매일 반복 알림 스케줄링 ===
  static Future<void> scheduleDailyNotificationWithLocale(AppLocalizations l10n) async {
    final messages = getMotivationalMessages(l10n);
    final random = Random();
    
    try {
      // 하루 3번 알림 설정 (8시, 13시, 18시)
      final notificationTimes = [
        {'hour': 8, 'id': 1, 'title': '${l10n.appTitle} - 아침'},
        {'hour': 13, 'id': 2, 'title': '${l10n.appTitle} - 점심'},
        {'hour': 18, 'id': 3, 'title': '${l10n.appTitle} - 저녁'},
      ];
      
      for (final timeInfo in notificationTimes) {
        final message = messages[random.nextInt(messages.length)];
        
        await _notifications.zonedSchedule(
          timeInfo['id'] as int, // 각각 다른 알림 ID
          timeInfo['title'] as String, // 시간대별 제목
          message, // 알림 내용
          _nextInstanceOfTime(timeInfo['hour'] as int, 0), // 지정된 시간
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'daily_reminder', // 채널 ID
              'Daily Life Reminder', // 채널 이름
              channelDescription: 'Daily life reminder notifications (3 times a day)',
              importance: Importance.high, // 높은 우선순위
              priority: Priority.high,
              icon: '@mipmap/ic_launcher', // 알림 아이콘
            ),
            iOS: DarwinNotificationDetails(
              sound: 'default.wav',
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time, // 매일 같은 시간 반복
        );
      }
    } catch (e) {
      // 정확한 알람이 허용되지 않는 경우, 대략적인 시간으로 스케줄링
      print('정확한 알람 권한이 없습니다. 대략적인 시간으로 설정합니다: $e');
      
      // 대신 24시간 간격 반복 알림으로 설정 (덜 정확하지만 작동함)
      final message = messages[random.nextInt(messages.length)];
      await _notifications.periodicallyShow(
        1,
        l10n.appTitle,
        message,
        RepeatInterval.daily, // 24시간마다 반복
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_reminder',
            'Daily Life Reminder',
            channelDescription: 'Daily life reminder notifications',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            sound: 'default.wav',
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
    }
  }

  // === 다음 알림 시간 계산 (특정 시간) ===
  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    
    // 오늘 해당 시간이 이미 지났다면 내일로 설정
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    return scheduledDate;
  }

  // === 즉시 테스트 알림 전송 (개발용) ===
  static Future<void> sendTestNotification() async {
    // 기본 영어 메시지 사용
    final messages = [
      "⏰ Check your remaining life and wake up!",
      "💀 Time doesn't wait. Check now!",
      "⚡ Every moment is precious. Check your remaining time!",
    ];
    final random = Random();
    final message = messages[random.nextInt(messages.length)];
    
    await _notifications.show(
      999, // 테스트용 고유 ID
      'Death Clock ⏰ (Test)', // 테스트임을 명시
      '$message\n\n✅ Notifications are working properly!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_notification', // 테스트용 별도 채널
          'Test Notification',
          channelDescription: 'For testing notifications',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          sound: 'default.wav',
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  // === 다국어 지원 즉시 테스트 알림 전송 ===
  static Future<void> sendTestNotificationWithLocale(AppLocalizations l10n) async {
    final messages = getMotivationalMessages(l10n);
    final random = Random();
    final message = messages[random.nextInt(messages.length)];
    
    await _notifications.show(
      999, // 테스트용 고유 ID
      '${l10n.appTitle} (Test)', // 테스트임을 명시
      '$message\n\n✅ ${l10n.notificationEnabled}',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_notification', // 테스트용 별도 채널
          'Test Notification',
          channelDescription: 'For testing notifications',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          sound: 'default.wav',
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  // === 모든 알림 취소 ===
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
} 
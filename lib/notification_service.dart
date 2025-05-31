// 푸시 알림 서비스 클래스
// 매일 정해진 시간에 동기부여 메시지를 전송하는 기능 제공

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:math';

class NotificationService {
  // 알림 플러그인 인스턴스
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  
  // 동기부여 메시지 목록 (8개) - 랜덤으로 선택되어 알림에 표시
  static final List<String> _motivationalMessages = [
    "⏰ 남은 수명을 확인하고 정신차리세요!",
    "💀 시간은 기다려주지 않습니다. 지금 확인하세요!",
    "⚡ 매 순간이 소중합니다. 남은 시간을 체크하세요!",
    "🔥 인생은 짧습니다. 오늘도 의미있게 보내세요!",
    "💎 시간은 가장 귀한 자산입니다. 확인해보세요!",
    "🚀 목표를 향해 달려가세요. 남은 시간을 확인하세요!",
    "⭐ 오늘 하루도 소중히! 수명 체크하러 가기",
    "🎯 시간 관리의 첫걸음, 남은 수명 확인하기",
  ];

  // === 알림 서비스 초기화 ===
  static Future<void> initialize() async {
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

  // === 매일 반복 알림 스케줄링 ===
  static Future<void> scheduleDailyNotification() async {
    final random = Random();
    final message = _motivationalMessages[random.nextInt(_motivationalMessages.length)];
    
    try {
      // 정확한 시간 알림 시도 (매일 아침 8시)
      await _notifications.zonedSchedule(
        0, // 알림 ID
        'Death Clock ⏰', // 알림 제목
        message, // 알림 내용
        _nextInstanceOfTime(8, 0), // 매일 아침 8시
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_reminder', // 채널 ID
            'Daily Life Reminder', // 채널 이름
            channelDescription: '매일 수명 확인 알림',
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
    } catch (e) {
      // 정확한 알람이 허용되지 않는 경우, 대략적인 시간으로 스케줄링
      print('정확한 알람 권한이 없습니다. 대략적인 시간으로 설정합니다: $e');
      
      // 대신 24시간 간격 반복 알림으로 설정 (덜 정확하지만 작동함)
      await _notifications.periodicallyShow(
        0,
        'Death Clock ⏰',
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
    final random = Random();
    final message = _motivationalMessages[random.nextInt(_motivationalMessages.length)];
    
    await _notifications.show(
      999, // 테스트용 고유 ID
      'Death Clock ⏰ (테스트)', // 테스트임을 명시
      '$message\n\n✅ 알림이 정상 작동합니다!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_notification', // 테스트용 별도 채널
          'Test Notification',
          channelDescription: '알림 테스트용',
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
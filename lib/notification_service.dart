import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:math';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  
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

  static Future<void> initialize() async {
    tz.initializeTimeZones();
    
    const AndroidInitializationSettings androidSettings = 
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings iosSettings = 
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );
    
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _notifications.initialize(settings);
  }

  static Future<void> requestPermissions() async {
    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    
    await _notifications
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  static Future<void> scheduleDailyNotification() async {
    final random = Random();
    final message = _motivationalMessages[random.nextInt(_motivationalMessages.length)];
    
    await _notifications.zonedSchedule(
      0,
      'Death Clock ⏰',
      message,
      _nextInstanceOfTime(20, 0), // 매일 오후 8시
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
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    return scheduledDate;
  }

  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
} 
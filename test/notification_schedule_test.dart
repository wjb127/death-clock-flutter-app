// 알림 발송 시각 회귀 테스트.
//
// 이 앱은 tz.local 을 설정하지 않은 채 8/13/18시를 예약해서, 실제로는
// 08:00 UTC(한국 17시)에 알림이 울리고 있었다. 그 회귀를 다시 들이지 않도록
// "예약된 절대시각이 기기 로컬 시계로 몇 시인가"를 직접 검증한다.

import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;

import 'package:death_clock_app/notification_service.dart';

/// 예약된 절대시각을 **기기(다트 시스템) 시계**로 환산한다.
///
/// TZDateTime.toLocal() 은 다트 시스템 로컬이 아니라 tz.local 을 쓰기 때문에
/// 그걸로는 "사용자 시계에 몇 시로 보이는가"를 검증할 수 없다.
DateTime asDeviceClock(tz.TZDateTime t) =>
    DateTime.fromMillisecondsSinceEpoch(t.millisecondsSinceEpoch);

void main() {
  setUp(() {
    tzdata.initializeTimeZones();
  });

  group('nextInstanceOfTime', () {
    test('tz.local 이 UTC로 남아 있어도 기기 로컬 시계 기준 시각에 발송된다', () {
      // 예전 버그 상황 그대로: initializeTimeZones() 직후 tz.local 은 UTC다.
      expect(tz.local.name, 'UTC', reason: 'timezone 패키지 기본값 전제 확인');

      final now = DateTime(2026, 8, 6, 7, 0); // 기기 로컬 오전 7시
      final scheduled = NotificationService.nextInstanceOfTime(8, 0, now: now);

      // 같은 순간을 기기 로컬 시계로 되돌려 보면 8시여야 한다.
      expect(asDeviceClock(scheduled).hour, 8);
      expect(asDeviceClock(scheduled).day, 6);
    });

    test('해당 시각이 이미 지났으면 다음 날로 넘어간다', () {
      final now = DateTime(2026, 8, 6, 20, 30); // 저녁 8시 반
      final scheduled = NotificationService.nextInstanceOfTime(18, 0, now: now);

      expect(asDeviceClock(scheduled).hour, 18);
      expect(asDeviceClock(scheduled).day, 7, reason: '오늘 18시는 지났으므로 내일');
    });

    test('정각과 같은 순간이면 다음 날로 넘어간다', () {
      final now = DateTime(2026, 8, 6, 13, 0, 0);
      final scheduled = NotificationService.nextInstanceOfTime(13, 0, now: now);

      expect(asDeviceClock(scheduled).day, 7);
    });

    test('tz.local 이 실제 지역이어도 로컬 시계 시각은 그대로 유지된다', () {
      tz.setLocalLocation(tz.getLocation('Asia/Seoul'));

      final now = DateTime(2026, 8, 6, 7, 0);
      final scheduled = NotificationService.nextInstanceOfTime(8, 0, now: now);

      expect(asDeviceClock(scheduled).hour, 8);
    });

    test('예약 시각 목록은 아침·점심·저녁 3개다', () {
      expect(kNotificationHours, [8, 13, 18]);
    });
  });
}

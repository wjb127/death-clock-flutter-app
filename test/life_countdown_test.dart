import 'package:flutter_test/flutter_test.dart';
import 'package:death_clock_app/life_countdown.dart';

void main() {
  test('remaining time changes within a day, not only at midnight', () {
    final birthday = DateTime(2000, 1, 1);
    final now = DateTime(2026, 9, 30, 12);
    final first = LifeSnapshot.calculate(birthday, now);
    final later =
        LifeSnapshot.calculate(birthday, now.add(const Duration(seconds: 42)));
    expect(first.remainingSeconds - later.remainingSeconds, 42);
    expect(later.percentage, greaterThan(first.percentage));
  });

  test('future and expired birthdays never produce invalid progress', () {
    final now = DateTime(2026, 9, 30);
    final future = LifeSnapshot.calculate(DateTime(2030), now);
    final expired = LifeSnapshot.calculate(DateTime(1900), now);
    expect(future.percentage, 0);
    expect(expired.percentage, 100);
    expect(expired.remainingSeconds, 0);
  });

  testWidgets('pausing stops work and resuming recomputes elapsed wall time',
      (tester) async {
    var now = DateTime(2026, 9, 30, 12);
    final clock = LifeCountdown(now: () => now);
    clock.setBirthday(DateTime(2000));
    clock.start();
    final before = clock.value.remainingSeconds;
    clock.stop();
    expect(clock.isRunning, false);
    now = now.add(const Duration(hours: 2));
    await tester.pump(const Duration(seconds: 2));
    expect(clock.value.remainingSeconds, before);
    clock.start();
    expect(clock.value.remainingSeconds, before - 7200);
    expect(clock.isRunning, true);
    clock.dispose();
    expect(clock.isRunning, false);
  });
}

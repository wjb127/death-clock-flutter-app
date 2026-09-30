import 'dart:async';
import 'package:flutter/foundation.dart';

@immutable
class LifeSnapshot {
  const LifeSnapshot(this.remainingSeconds, this.percentage);
  final int remainingSeconds;
  final double percentage;

  static LifeSnapshot calculate(DateTime birthday, DateTime now) {
    // Preserve the existing 100-year, 365.25-day model while retaining seconds.
    const lifespanSeconds = 100 * 365.25 * 24 * 60 * 60;
    final elapsed = now.difference(birthday).inMilliseconds / 1000;
    final remaining = (lifespanSeconds - elapsed).ceil();
    return LifeSnapshot(
      remaining.clamp(0, lifespanSeconds.toInt()),
      (elapsed / lifespanSeconds * 100).clamp(0.0, 100.0),
    );
  }
}

/// Only the countdown card listens to this controller, not the whole screen.
class LifeCountdown extends ValueNotifier<LifeSnapshot> {
  LifeCountdown({DateTime Function()? now})
      : _now = now ?? DateTime.now,
        super(const LifeSnapshot(0, 0));
  final DateTime Function() _now;
  DateTime? _birthday;
  Timer? _timer;
  bool get isRunning => _timer?.isActive ?? false;

  void setBirthday(DateTime birthday) {
    _birthday = birthday;
    refresh();
  }

  void refresh() {
    final birthday = _birthday;
    if (birthday == null) return;
    final next = LifeSnapshot.calculate(birthday, _now());
    if (next.remainingSeconds != value.remainingSeconds ||
        next.percentage != value.percentage) {
      value = next;
    }
    if (next.remainingSeconds == 0) stop();
  }

  void start() {
    stop();
    refresh();
    if (_birthday == null || value.remainingSeconds == 0) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => refresh());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }
}

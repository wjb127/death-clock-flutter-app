import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:death_clock_app/main.dart';

void main() {
  test('앱 루트 생성', () {
    expect(const DeathClockApp(), isA<StatelessWidget>());
  });
}

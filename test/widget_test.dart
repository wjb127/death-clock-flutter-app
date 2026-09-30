import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:death_clock_app/main.dart';

void main() {
  test('앱 루트 생성', () {
    expect(const DeathClockApp(), isA<StatelessWidget>());
  });

  testWidgets('birthday picker supports the current year and cancels safely',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const DeathClockApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byType(ElevatedButton).first);
    await tester.pumpAndSettle();
    final picker = tester.widget<CupertinoDatePicker>(
      find.byType(CupertinoDatePicker),
    );
    expect(picker.initialDateTime.year, DateTime.now().year);
    expect(picker.maximumDate, DateUtils.dateOnly(DateTime.now()));
    expect(tester.takeException(), isNull);
    await tester.tap(find
        .descendant(
          of: find.byType(AlertDialog),
          matching: find.byType(TextButton),
        )
        .first);
    await tester.pumpAndSettle();
    expect(find.byType(CupertinoDatePicker), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    debugDefaultTargetPlatformOverride = null;
  });
}

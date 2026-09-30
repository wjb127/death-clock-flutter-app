import 'package:death_clock_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture real Korean app screens on iOS', (tester) async {
    SharedPreferences.setMockInitialValues({
      'birth_date': DateTime(2000, 1, 1).toIso8601String(),
      'notifications_enabled': false,
    });
    await tester.pumpWidget(const DeathClockApp());
    await tester.pumpAndSettle();
    expect(find.text('2000.01.01'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await binding.takeScreenshot('01-countdown');

    await tester.tap(find.byType(ElevatedButton).first);
    await tester.pumpAndSettle();
    expect(find.byType(CupertinoDatePicker), findsOneWidget);
    await binding.takeScreenshot('02-birthday');
    await tester.tap(find
        .descendant(
          of: find.byType(AlertDialog),
          matching: find.byType(TextButton),
        )
        .first);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();
    expect(find.byType(Switch), findsOneWidget);
    await binding.takeScreenshot('03-settings');
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}

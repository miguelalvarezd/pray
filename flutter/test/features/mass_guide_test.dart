import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pray/data/boxes.dart';
import 'package:pray/data/providers.dart';
import 'package:pray/features/mass_guide/mass_guide_screen.dart';
import 'package:pray/services/liturgy/liturgical_calendar.dart';

import '../test_helpers.dart';

void main() {
  Future<void> openReadings(WidgetTester tester, String day) async {
    final (boxes, tmp) = await initTestHiveInWidgetTest(tester);
    addTearDown(() async => tester.runAsync(() => tearDownTestHive(boxes, tmp)));
    await tester.runAsync(() => boxes.settings.put(SettingsKeys.dateOverride, day));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appBoxesProvider.overrideWithValue(boxes),
          liturgicalCalendarProvider.overrideWith((ref) async => bundledLiturgicalCalendar),
        ],
        child: const MaterialApp(home: MassGuideScreen()),
      ),
    );
    await settle(tester);
    // Page forward to the Liturgy of the Word's Readings.
    for (var i = 0; i < 40 && find.text('FIRST READING').evaluate().isEmpty; i++) {
      await tester.tap(find.text('Next'));
      await settle(tester);
    }
    expect(find.text('FIRST READING'), findsOneWidget);
  }

  testWidgets("each Reading step shows the Day's Reading Reference", (tester) async {
    await openReadings(tester, '2026-09-27');

    expect(find.text('Ez 18:25-28'), findsOneWidget);
    expect(find.text('Ps 25:4-5, 6-7, 8-9'), findsOneWidget);
    expect(find.text('Phil 2:1-11 or 2:1-5'), findsOneWidget);
  });

  testWidgets('no Second Reading Reference on a Day without one', (tester) async {
    await openReadings(tester, '2026-09-28');

    expect(find.text('Jb 1:6-22'), findsOneWidget);
    expect(find.byKey(const ValueKey('reading-reference-word.second_reading')), findsNothing);
  });
}

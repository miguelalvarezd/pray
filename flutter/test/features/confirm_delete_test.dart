import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pray/app.dart';
import 'package:pray/data/boxes.dart';
import 'package:pray/data/models/novena.dart';
import 'package:pray/data/providers.dart';

import '../test_helpers.dart';

/// The app never fully settles (network-backed providers and ambient
/// animations), so pump a fixed number of frames instead.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  Future<AppBoxes> bootWithNovena(WidgetTester tester) async {
    final (boxes, tmp) = await initTestHiveInWidgetTest(tester);
    addTearDown(() async => tester.runAsync(() => tearDownTestHive(boxes, tmp)));
    await tester.runAsync(() async {
      await boxes.settings.put(SettingsKeys.dateOverride, '2026-05-03');
      await boxes.novenas.put(
        'n1',
        const Novena(
          id: 'n1',
          title: 'St. Jude',
          intention: 'For my brother',
          startDate: '2026-05-01',
          createdAt: '2026-05-01T08:00:00.000Z',
        ),
      );
    });
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appBoxesProvider.overrideWithValue(boxes)],
        child: const PrayApp(),
      ),
    );
    await _settle(tester);
    await tester.tap(find.text('Intentions').last);
    await _settle(tester);
    await tester.tap(find.text('Novenas').last);
    await _settle(tester);
    return boxes;
  }

  Future<void> tapDelete(WidgetTester tester) async {
    await tester.tap(find.byTooltip('Delete').first);
    await _settle(tester);
  }

  testWidgets('cancelling the delete confirmation keeps the Novena', (tester) async {
    final boxes = await bootWithNovena(tester);
    await tapDelete(tester);

    expect(find.text('Delete this novena?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await _settle(tester);

    expect(boxes.novenas.containsKey('n1'), isTrue);
    expect(find.text('St. Jude'), findsWidgets);
  });

  testWidgets('confirming the delete removes the Novena', (tester) async {
    final boxes = await bootWithNovena(tester);
    await tapDelete(tester);

    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await _settle(tester);

    expect(boxes.novenas.containsKey('n1'), isFalse);
  });
}

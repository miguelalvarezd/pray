import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pray/data/boxes.dart';
import 'package:pray/data/models/novena.dart';

import '../test_helpers.dart';

void main() {
  Future<AppBoxes> openNovenas(WidgetTester tester) async {
    final boxes = await pumpPrayApp(
      tester,
      day: '2026-05-03',
      seed: (boxes) => boxes.novenas.put(
        'n1',
        const Novena(
          id: 'n1',
          title: 'St. Jude',
          startDate: '2026-05-01',
          createdAt: '2026-05-01T08:00:00.000Z',
        ),
      ),
    );
    await tester.tap(find.text('Intentions').last);
    await settle(tester);
    await tester.tap(find.text('Novenas').last);
    await settle(tester);
    return boxes;
  }

  Future<void> tapDelete(WidgetTester tester) async {
    await tester.tap(find.byTooltip('Delete').first);
    await settle(tester);
  }

  testWidgets('cancelling the delete confirmation keeps the Novena', (tester) async {
    final boxes = await openNovenas(tester);
    await tapDelete(tester);

    expect(find.text('Delete this novena?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await settle(tester);

    expect(boxes.novenas.containsKey('n1'), isTrue);
    expect(find.text('St. Jude'), findsWidgets);
  });

  testWidgets('confirming the delete removes the Novena', (tester) async {
    final boxes = await openNovenas(tester);
    await tapDelete(tester);

    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await settle(tester);

    expect(boxes.novenas.containsKey('n1'), isFalse);
  });
}

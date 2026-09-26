import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pray/data/boxes.dart';
import 'package:pray/data/models/intention.dart';
import 'package:pray/data/models/novena.dart';
import 'package:pray/data/models/priority.dart';

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

  group('deleting an Intention', () {
    Future<AppBoxes> openIntentions(WidgetTester tester) async {
      final boxes = await pumpPrayApp(
        tester,
        day: '2026-05-03',
        seed: (boxes) => boxes.intentions.put(
          'i1',
          const Intention(
            id: 'i1',
            title: "Mom's surgery",
            createdAt: '2026-04-01T10:00:00.000Z',
            priority: Priority.high,
          ),
        ),
      );
      await tester.tap(find.text('Intentions').last);
      await settle(tester);
      await tapDelete(tester);
      return boxes;
    }

    testWidgets('cancelling keeps the Intention, and the dialog suggests archiving',
        (tester) async {
      final boxes = await openIntentions(tester);

      expect(find.text('Delete this intention?'), findsOneWidget);
      expect(find.textContaining('archive it instead'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await settle(tester);

      expect(boxes.intentions.containsKey('i1'), isTrue);
    });

    testWidgets('confirming removes the Intention', (tester) async {
      final boxes = await openIntentions(tester);

      await tester.tap(find.widgetWithText(TextButton, 'Delete'));
      await settle(tester);

      expect(boxes.intentions.containsKey('i1'), isFalse);
    });
  });
}

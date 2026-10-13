import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pray/data/models/intention.dart';
import 'package:pray/data/models/priority.dart';

import '../test_helpers.dart';

void main() {
  testWidgets('keep praying without a date clears the passed Target Date', (tester) async {
    final boxes = await pumpPrayApp(
      tester,
      day: '2026-05-03',
      seed: (boxes) => boxes.intentions.put(
        'i1',
        const Intention(
          id: 'i1',
          title: 'Exams',
          createdAt: '2026-04-01T10:00:00.000Z',
          targetDate: '2026-05-01',
          priority: Priority.medium,
        ),
      ),
    );
    await tester.tap(find.text('Intentions').last);
    await settle(tester);

    expect(find.text('The target date has passed. Was this answered?'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Keep praying'));
    await settle(tester);
    await tester.tap(find.text('No target date'));
    await settle(tester);

    expect(boxes.intentions.get('i1')!.targetDate, isNull);
    expect(find.text('The target date has passed. Was this answered?'), findsNothing);
  });
}

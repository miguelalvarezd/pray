import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pray/data/boxes.dart';
import 'package:pray/data/models/intention.dart';
import 'package:pray/data/models/intention_status.dart';
import 'package:pray/data/models/priority.dart';

import '../test_helpers.dart';

void main() {
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
    return boxes;
  }

  Future<void> markAnswered(WidgetTester tester, {String? note}) async {
    await chooseIntentionAction(tester, 'Mark answered');
    if (note != null) {
      await tester.enterText(find.byType(TextField), note);
    }
    await tester.tap(find.widgetWithText(FilledButton, 'Mark answered'));
    await settle(tester);
  }

  testWidgets('marking an Intention answered records today\'s Day and the note',
      (tester) async {
    final boxes = await openIntentions(tester);

    await markAnswered(tester, note: 'Surgery went well');

    final answered = boxes.intentions.get('i1')!;
    expect(answered.status, IntentionStatus.answered);
    expect(answered.answeredOn, '2026-05-03');
    expect(answered.answerNote, 'Surgery went well');
  });

  testWidgets('Undo after answering puts the Intention back', (tester) async {
    final boxes = await openIntentions(tester);
    await markAnswered(tester);

    await tester.tap(find.text('Undo'));
    await settle(tester);

    final restored = boxes.intentions.get('i1')!;
    expect(restored.status, IntentionStatus.active);
    expect(restored.answeredOn, isNull);
  });

  testWidgets('an Answered Intention\'s menu offers Restore and Delete', (tester) async {
    await openIntentions(tester);
    await markAnswered(tester);
    await tester.tap(find.text('Answered (1)'));
    await settle(tester);

    await tester.tap(find.byTooltip('Intention actions').first);
    await settle(tester);

    expect(find.text('Restore'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
    expect(find.text('Mark answered'), findsNothing);
    expect(find.text('Archive'), findsNothing);
  });
}

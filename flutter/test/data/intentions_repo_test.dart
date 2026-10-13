import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pray/data/boxes.dart';
import 'package:pray/data/models/daily_log.dart';
import 'package:pray/data/models/intention.dart';
import 'package:pray/data/models/intention_status.dart';
import 'package:pray/data/models/novena.dart';
import 'package:pray/data/models/priority.dart';
import 'package:pray/data/repositories/intentions_repo.dart';
import 'package:pray/data/repositories/logs_repo.dart';
import 'package:pray/data/repositories/novenas_repo.dart';

import '../test_helpers.dart';

const _mom = Intention(
  id: 'i1',
  title: "Mom's surgery",
  createdAt: '2026-04-01T10:00:00.000Z',
  priority: Priority.high,
);

void main() {
  late AppBoxes boxes;
  late dynamic tmp;
  late ProviderContainer container;

  setUp(() async {
    final (b, t) = await initTestHive();
    boxes = b;
    tmp = t;
    container = createTestContainer(boxes);
  });

  tearDown(() async {
    container.dispose();
    await tearDownTestHive(boxes, tmp);
  });

  IntentionsNotifier notifier() => container.read(intentionsProvider.notifier);
  Intention stored(String id) =>
      container.read(intentionsProvider).singleWhere((i) => i.id == id);

  test('archiving an Intention makes it Archived', () async {
    await notifier().add(_mom);
    await notifier().archive('i1');
    expect(stored('i1').status, IntentionStatus.archived);
  });

  test('restoring an Archived Intention makes it active again', () async {
    await notifier().add(_mom);
    await notifier().archive('i1');
    await notifier().restore('i1');
    expect(stored('i1').status, IntentionStatus.active);
  });

  test('marking an Intention Answered records the Day and note', () async {
    await notifier().add(_mom);
    await notifier().answer('i1', day: '2026-05-02', note: 'Surgery went well');

    final answered = stored('i1');
    expect(answered.status, IntentionStatus.answered);
    expect(answered.answeredOn, '2026-05-02');
    expect(answered.answerNote, 'Surgery went well');
  });

  test('an Intention can be Answered without a note', () async {
    await notifier().add(_mom);
    await notifier().answer('i1', day: '2026-05-02', note: '  ');
    expect(stored('i1').answerNote, isNull);
  });

  test('restoring an Answered Intention clears its answered Day and note', () async {
    await notifier().add(_mom);
    await notifier().answer('i1', day: '2026-05-02', note: 'Surgery went well');
    await notifier().restore('i1');

    final restored = stored('i1');
    expect(restored.status, IntentionStatus.active);
    expect(restored.answeredOn, isNull);
    expect(restored.answerNote, isNull);
  });

  test('putting back the previous Intention undoes a restore, answer included', () async {
    await notifier().add(_mom);
    await notifier().answer('i1', day: '2026-05-02', note: 'Surgery went well');
    final before = stored('i1');
    await notifier().restore('i1');

    await notifier().update(before);

    expect(stored('i1').status, IntentionStatus.answered);
    expect(stored('i1').answeredOn, '2026-05-02');
    expect(stored('i1').answerNote, 'Surgery went well');
  });

  group('keep praying after the Target Date', () {
    Intention withTarget() => _mom.copyWith(targetDate: '2026-04-30');

    test('clears the passed Target Date when no new one is given', () async {
      await notifier().add(withTarget());
      await notifier().keepPraying('i1');

      expect(stored('i1').targetDate, isNull);
      expect(stored('i1').status, IntentionStatus.active);
    });

    test('sets the new Target Date when one is given', () async {
      await notifier().add(withTarget());
      await notifier().keepPraying('i1', newTargetDate: '2026-06-01');

      expect(stored('i1').targetDate, '2026-06-01');
    });
  });

  group('deleting an Intention', () {
    test('removes it from every past Daily Log', () async {
      await notifier().add(_mom);
      final logs = container.read(logsProvider.notifier);
      await logs.save(const DailyLog(date: '2026-05-01', completedIntentions: ['i1', 'i2']));
      await logs.save(const DailyLog(date: '2026-05-02', completedIntentions: ['i1']));

      await notifier().delete('i1');

      expect(container.read(intentionsProvider), isEmpty);
      final after = container.read(logsProvider);
      expect(after['2026-05-01']!.completedIntentions, ['i2']);
      expect(after['2026-05-02']!.completedIntentions, isEmpty);
    });

    test('keeps the Novenas offered for it, with no Intention', () async {
      await notifier().add(_mom);
      await container.read(novenasProvider.notifier).add(const Novena(
            id: 'n1',
            title: 'St. Jude',
            intentionId: 'i1',
            startDate: '2026-05-01',
            createdAt: '2026-05-01T08:00:00.000Z',
          ));

      await notifier().delete('i1');

      final novena = container.read(novenasProvider).single;
      expect(novena.id, 'n1');
      expect(novena.intentionId, isNull);
    });
  });
}

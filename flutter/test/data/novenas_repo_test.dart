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

Novena _novena(String id) => Novena(
      id: id,
      title: 'St. Jude',
      startDate: '2026-05-01',
      createdAt: '2026-05-01T08:00:00.000Z',
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

  test('deleting a Novena removes it from every past Daily Log', () async {
    final novenas = container.read(novenasProvider.notifier);
    await novenas.add(_novena('n1'));
    await novenas.add(_novena('n2'));
    final logs = container.read(logsProvider.notifier);
    await logs.save(const DailyLog(date: '2026-05-01', completedNovenas: ['n1', 'n2']));
    await logs.save(const DailyLog(date: '2026-05-02', completedNovenas: ['n1']));

    await novenas.delete('n1');

    expect(container.read(novenasProvider).map((n) => n.id), ['n2']);
    final after = container.read(logsProvider);
    expect(after['2026-05-01']!.completedNovenas, ['n2']);
    expect(after['2026-05-02']!.completedNovenas, isEmpty);
  });

  group('starting a Novena', () {
    test('for new text creates an active Intention and links it', () async {
      await container.read(novenasProvider.notifier).start(
            _novena('n1'),
            intentionText: '  Exams  ',
          );

      final novena = container.read(novenasProvider).single;
      final intention = container.read(intentionsProvider).single;
      expect(intention.title, 'Exams');
      expect(intention.status, IntentionStatus.active);
      expect(novena.intentionId, intention.id);
    });

    test('for an existing Intention links it without creating another', () async {
      await container.read(intentionsProvider.notifier).add(const Intention(
            id: 'i1',
            title: "Mom's surgery",
            createdAt: '2026-04-01T10:00:00.000Z',
            priority: Priority.high,
          ));

      await container
          .read(novenasProvider.notifier)
          .start(_novena('n1').offeredFor('i1'));

      expect(container.read(novenasProvider).single.intentionId, 'i1');
      expect(container.read(intentionsProvider), hasLength(1));
    });

    test('for text matching an active Intention\'s title links it without creating another',
        () async {
      await container.read(intentionsProvider.notifier).add(const Intention(
            id: 'i1',
            title: "Mom's surgery",
            createdAt: '2026-04-01T10:00:00.000Z',
            priority: Priority.high,
          ));

      await container
          .read(novenasProvider.notifier)
          .start(_novena('n1'), intentionText: "  MOM'S SURGERY ");

      expect(container.read(novenasProvider).single.intentionId, 'i1');
      expect(container.read(intentionsProvider), hasLength(1));
    });

    test('for text matching only an Answered Intention creates a new one', () async {
      await container.read(intentionsProvider.notifier).add(const Intention(
            id: 'old',
            title: 'Exams',
            createdAt: '2026-01-01T10:00:00.000Z',
            priority: Priority.medium,
            status: IntentionStatus.answered,
          ));

      await container
          .read(novenasProvider.notifier)
          .start(_novena('n1'), intentionText: 'Exams');

      final linked = container.read(novenasProvider).single.intentionId;
      expect(linked, isNot('old'));
      expect(container.read(intentionsProvider), hasLength(2));
    });

    test('for empty text leaves it unlinked', () async {
      await container
          .read(novenasProvider.notifier)
          .start(_novena('n1'), intentionText: '   ');

      expect(container.read(novenasProvider).single.intentionId, isNull);
      expect(container.read(intentionsProvider), isEmpty);
    });

    test('for no Intention leaves it unlinked', () async {
      await container.read(novenasProvider.notifier).start(_novena('n1'));

      expect(container.read(novenasProvider).single.intentionId, isNull);
      expect(container.read(intentionsProvider), isEmpty);
    });
  });
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pray/data/boxes.dart';
import 'package:pray/data/models/daily_log.dart';
import 'package:pray/data/models/novena.dart';
import 'package:pray/data/repositories/logs_repo.dart';
import 'package:pray/data/repositories/novenas_repo.dart';

import '../test_helpers.dart';

Novena _novena(String id) => Novena(
      id: id,
      title: 'St. Jude',
      intention: 'For my brother',
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
}

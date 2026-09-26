import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pray/data/boxes.dart';
import 'package:pray/data/models/intention.dart';
import 'package:pray/data/models/intention_status.dart';
import 'package:pray/data/models/priority.dart';
import 'package:pray/data/repositories/intentions_repo.dart';

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
}

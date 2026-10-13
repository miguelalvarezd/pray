import 'package:flutter_test/flutter_test.dart';
import 'package:pray/data/backup/backup_envelope.dart';
import 'package:pray/data/backup/backup_service.dart';
import 'package:pray/data/boxes.dart';
import 'package:pray/data/models/intention.dart';
import 'package:pray/data/models/intention_status.dart';
import 'package:pray/data/models/novena.dart';
import 'package:pray/data/models/priority.dart';
import 'package:pray/data/repositories/intentions_repo.dart';

import '../test_helpers.dart';

/// A stand-in migration step used to prove that backup import and the
/// on-device upgrade run through the same chain.
Map<String, dynamic> _markTitles(Map<String, dynamic> data, DateTime today) {
  final list = (data['prayer-intentions'] as List?) ?? const [];
  return {
    ...data,
    'prayer-intentions': [
      for (final raw in list)
        {...(raw as Map<String, dynamic>), 'title': '${raw['title']} (migrated)'},
    ],
  };
}

Intention _intention(String id, String title) => Intention(
      id: id,
      title: title,
      createdAt: '2026-04-01T10:00:00.000Z',
      priority: Priority.medium,
    );

void main() {
  late AppBoxes boxes;
  late dynamic tmp;

  setUp(() async {
    final (b, t) = await initTestHive();
    boxes = b;
    tmp = t;
  });

  tearDown(() async => tearDownTestHive(boxes, tmp));

  group('migration chain', () {
    test('importing a backup older than the chain applies every newer step', () async {
      final service = BackupService(boxes, steps: [identityStep, _markTitles]);

      final result = service.parseBackup({
        'version': 1,
        'exportedAt': '2026-04-30T12:00:00.000Z',
        'data': {
          'prayer-intentions': [_intention('i1', 'For my family').toJson()],
        },
      });
      expect(result, isA<ImportOk>());
      final ok = result as ImportOk;
      expect(ok.version, 2);
      await service.applyImport(ok.data);

      expect(boxes.intentions.get('i1')!.title, 'For my family (migrated)');
    });

    test('a backup at the current version is imported unchanged', () async {
      final service = BackupService(boxes, steps: [identityStep, _markTitles]);
      final result = service.parseBackup({
        'version': 2,
        'exportedAt': '2026-04-30T12:00:00.000Z',
        'data': {
          'prayer-intentions': [_intention('i1', 'For my family').toJson()],
        },
      });
      await service.applyImport((result as ImportOk).data);
      expect(boxes.intentions.get('i1')!.title, 'For my family');
    });

    test('a backup newer than the chain is rejected', () {
      final service = BackupService(boxes, steps: [identityStep, _markTitles]);
      final result = service.parseBackup({
        'version': 3,
        'exportedAt': 'whenever',
        'data': {'prayer-intentions': []},
      });
      expect(result, isA<ImportFail>());
      expect((result as ImportFail).error, contains('newer version'));
    });
  });

  group('on-device upgrade', () {
    test('upgrades data stored before versioning through the same steps', () async {
      await boxes.intentions.put('i1', _intention('i1', 'For my family'));
      final service = BackupService(boxes, steps: [identityStep, _markTitles]);

      await service.upgradeStoredData();

      final container = createTestContainer(boxes);
      addTearDown(container.dispose);
      expect(container.read(intentionsProvider).single.title, 'For my family (migrated)');
      expect(service.storedDataVersion, 2);
    });

    test('does not run again once the stored version is current', () async {
      await boxes.intentions.put('i1', _intention('i1', 'For my family'));
      final service = BackupService(boxes, steps: [identityStep, _markTitles]);

      await service.upgradeStoredData();
      await service.upgradeStoredData();

      expect(boxes.intentions.get('i1')!.title, 'For my family (migrated)');
    });

    test('a fresh install is recorded at the current version without migrating', () async {
      final service = BackupService(boxes, steps: [identityStep, _markTitles]);

      await service.upgradeStoredData();
      await boxes.intentions.put('i1', _intention('i1', 'Added after install'));
      await service.upgradeStoredData();

      expect(boxes.intentions.get('i1')!.title, 'Added after install');
    });
  });

  test('the production chain is at the current schema version', () {
    final service = BackupService(boxes);
    final envelope = service.buildExport(now: DateTime.utc(2026, 4, 30));
    expect(envelope.version, kSchemaVersion);
  });

  group('v1 → v2: Intention status', () {
    test('an archived Intention in a v1 backup becomes Archived, others active', () async {
      final service = BackupService(boxes);
      final result = service.parseBackup({
        'version': 1,
        'exportedAt': '2026-04-30T12:00:00.000Z',
        'data': {
          'prayer-intentions': [
            {..._legacy('old', archived: true)},
            {..._legacy('current', archived: false)},
          ],
        },
      });
      await service.applyImport((result as ImportOk).data);

      expect(boxes.intentions.get('old')!.status, IntentionStatus.archived);
      expect(boxes.intentions.get('current')!.status, IntentionStatus.active);
    });

    test('Intentions archived on the device before the upgrade become Archived', () async {
      await boxes.intentions.put(
        'old',
        const Intention(
          id: 'old',
          title: 'Job search',
          createdAt: '2026-01-01T00:00:00.000Z',
          priority: Priority.low,
          legacyIsArchived: true,
        ),
      );
      final service = BackupService(boxes);

      await service.upgradeStoredData();

      final upgraded = boxes.intentions.get('old')!;
      expect(upgraded.status, IntentionStatus.archived);
      expect(upgraded.legacyIsArchived, isNull);
    });

    test('export then import keeps each Intention status', () async {
      final service = BackupService(boxes);
      await boxes.intentions.put(
        'a',
        _intention('a', 'Archived one').copyWith(status: IntentionStatus.archived),
      );
      final exported = service.buildExport(now: DateTime.utc(2026, 5, 1)).toJson();
      await boxes.intentions.clear();

      final result = service.parseBackup(exported);
      await service.applyImport((result as ImportOk).data);

      expect(boxes.intentions.get('a')!.status, IntentionStatus.archived);
    });
  });

  test('export then import keeps an Answered Intention with its Day and note', () async {
    final service = BackupService(boxes);
    await boxes.intentions.put(
      'a',
      _intention('a', 'Job').withStatus(
        IntentionStatus.answered,
        answeredOn: '2026-05-02',
        answerNote: 'Offer accepted',
      ),
    );
    final exported = service.buildExport(now: DateTime.utc(2026, 5, 3)).toJson();
    await boxes.intentions.clear();

    final result = service.parseBackup(exported);
    await service.applyImport((result as ImportOk).data);

    final back = boxes.intentions.get('a')!;
    expect(back.status, IntentionStatus.answered);
    expect(back.answeredOn, '2026-05-02');
    expect(back.answerNote, 'Offer accepted');
  });

  group('v3 → v4: Novenas offered for Intentions', () {
    // Pin "today" so whether a Novena's nine Days have passed is fixed.
    BackupService service() =>
        BackupService(boxes, today: () => DateTime(2026, 5, 20));

    Map<String, dynamic> v3Backup(List<Map<String, dynamic>> novenas) => {
          'version': 3,
          'exportedAt': '2026-05-20T12:00:00.000Z',
          'data': {'prayer-novenas': novenas},
        };

    Map<String, dynamic> legacyNovena(String id, String intention, String start) => {
          'id': id,
          'title': 'St. Jude',
          'intention': intention,
          'startDate': start,
          'createdAt': '${start}T08:00:00.000Z',
        };

    Future<void> import(Map<String, dynamic> backup) async {
      final result = service().parseBackup(backup);
      await service().applyImport((result as ImportOk).data);
    }

    test('a free-text intention becomes a linked Intention', () async {
      await import(v3Backup([legacyNovena('n1', 'For my brother', '2026-05-15')]));

      final novena = boxes.novenas.get('n1')!;
      final linked = boxes.intentions.get(novena.intentionId)!;
      expect(linked.title, 'For my brother');
      expect(linked.priority, Priority.medium);
      expect(linked.createdAt, '2026-05-15T08:00:00.000Z');
      expect(novena.legacyIntentionText, isNull);
    });

    test('an in-progress Novena gets an active Intention, a finished one Archived', () async {
      await import(v3Backup([
        legacyNovena('ongoing', 'Exams', '2026-05-15'),
        legacyNovena('done', 'New job', '2026-04-01'),
      ]));

      Intention linkedTo(String novenaId) =>
          boxes.intentions.get(boxes.novenas.get(novenaId)!.intentionId)!;
      expect(linkedTo('ongoing').status, IntentionStatus.active);
      expect(linkedTo('done').status, IntentionStatus.archived);
    });

    test('Novenas with the same text share one Intention', () async {
      await import(v3Backup([
        legacyNovena('a', 'For my brother', '2026-04-01'),
        legacyNovena('b', '  for my BROTHER ', '2026-05-15'),
      ]));

      final a = boxes.novenas.get('a')!.intentionId;
      expect(a, isNotNull);
      expect(boxes.novenas.get('b')!.intentionId, a);
      expect(boxes.intentions.length, 1);
      // One of them is still in progress, so the shared Intention is active.
      expect(boxes.intentions.get(a)!.status, IntentionStatus.active);
    });

    test('an empty free-text intention links no Intention', () async {
      await import(v3Backup([legacyNovena('n1', '  ', '2026-05-15')]));
      expect(boxes.novenas.get('n1')!.intentionId, isNull);
      expect(boxes.intentions.isEmpty, isTrue);
    });

    test('Novenas stored on the device before the upgrade get linked Intentions', () async {
      await boxes.novenas.put(
        'n1',
        const Novena(
          id: 'n1',
          title: 'St. Jude',
          startDate: '2026-05-15',
          createdAt: '2026-05-15T08:00:00.000Z',
          legacyIntentionText: 'For my brother',
        ),
      );
      await boxes.settings.put(SettingsKeys.dataVersion, 3);

      await service().upgradeStoredData();

      final novena = boxes.novenas.get('n1')!;
      expect(boxes.intentions.get(novena.intentionId)!.title, 'For my brother');
      expect(novena.legacyIntentionText, isNull);
    });
  });
}

/// An Intention as the React app and schema v1 exported it.
Map<String, dynamic> _legacy(String id, {required bool archived}) => {
      'id': id,
      'title': id,
      'createdAt': '2026-04-01T00:00:00.000Z',
      'priority': 'medium',
      'isArchived': archived,
    };

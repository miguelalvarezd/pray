import 'package:flutter_test/flutter_test.dart';
import 'package:pray/data/backup/backup_envelope.dart';
import 'package:pray/data/backup/backup_service.dart';
import 'package:pray/data/boxes.dart';
import 'package:pray/data/models/intention.dart';
import 'package:pray/data/models/priority.dart';
import 'package:pray/data/repositories/intentions_repo.dart';

import '../test_helpers.dart';

/// A stand-in migration step used to prove that backup import and the
/// on-device upgrade run through the same chain.
Map<String, dynamic> _markTitles(Map<String, dynamic> data) {
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
      isArchived: false,
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
}

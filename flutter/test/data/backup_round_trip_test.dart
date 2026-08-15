import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pray/data/backup/backup_envelope.dart';
import 'package:pray/data/backup/backup_service.dart';
import 'package:pray/data/boxes.dart';
import 'package:pray/data/models/daily_log.dart';
import 'package:pray/data/models/intention.dart';
import 'package:pray/data/models/novena.dart';
import 'package:pray/data/models/priority.dart';

import '../test_helpers.dart';

void main() {
  group('BackupService', () {
    late AppBoxes boxes;
    late BackupService service;
    late dynamic tmp;

    setUp(() async {
      final (b, t) = await initTestHive();
      boxes = b;
      service = BackupService(boxes);
      tmp = t;
    });

    tearDown(() async => tearDownTestHive(boxes, tmp));

    test('round-trips through JSON', () async {
      await boxes.intentions.put(
        'i1',
        Intention(
          id: 'i1',
          title: 'For my family',
          description: 'Health and unity',
          createdAt: '2026-04-01T10:00:00.000Z',
          targetDate: '2026-12-25',
          priority: Priority.high,
          isArchived: false,
        ),
      );
      await boxes.novenas.put(
        'n1',
        const Novena(
          id: 'n1',
          title: 'St. Jude',
          intention: 'For my brother',
          startDate: '2026-04-25',
          createdAt: '2026-04-25T08:00:00.000Z',
          templateId: 'st-jude',
        ),
      );
      await boxes.logs.put(
        '2026-04-30',
        const DailyLog(
          date: '2026-04-30',
          completedPrayers: ['morning_prayer', 'rosary'],
          completedIntentions: ['i1'],
          completedNovenas: ['n1'],
          journal: 'Felt peace today.',
        ),
      );
      await boxes.settings.put(SettingsKeys.dateOverride, '2026-04-30');

      // Export → JSON → parse → import into a clean state.
      final envelope1 = service.buildExport(now: DateTime.utc(2026, 4, 30));
      final json = jsonEncode(envelope1.toJson());

      // Wipe boxes, simulate fresh install.
      await boxes.intentions.clear();
      await boxes.novenas.clear();
      await boxes.logs.clear();
      await boxes.settings.delete(SettingsKeys.dateOverride);

      final result = service.parseBackup(jsonDecode(json));
      expect(result, isA<ImportOk>());
      await service.applyImport((result as ImportOk).data);

      // Verify roundtrip.
      expect(boxes.intentions.length, 1);
      final i = boxes.intentions.get('i1')!;
      expect(i.title, 'For my family');
      expect(i.priority, Priority.high);
      expect(i.targetDate, '2026-12-25');

      expect(boxes.novenas.length, 1);
      expect(boxes.novenas.get('n1')!.title, 'St. Jude');

      expect(boxes.logs.length, 1);
      final log = boxes.logs.get('2026-04-30')!;
      expect(log.completedPrayers, ['morning_prayer', 'rosary']);
      expect(log.journal, 'Felt peace today.');

      expect(boxes.settings.get(SettingsKeys.dateOverride), '2026-04-30');

      // Re-exporting yields the same data envelope (modulo exportedAt).
      final envelope2 = service.buildExport(now: DateTime.utc(2026, 4, 30));
      expect(envelope2.data, envelope1.data);
    });

    test('parses a React-shaped versioned envelope', () async {
      final raw = {
        'version': 1,
        'exportedAt': '2026-04-30T12:00:00.000Z',
        'data': {
          'prayer-intentions': [
            {
              'id': 'r1',
              'title': 'From React',
              'createdAt': '2026-04-15T00:00:00.000Z',
              'priority': 'medium',
              'isArchived': false,
            }
          ],
          'prayer-logs': {
            '2026-04-20': {
              'date': '2026-04-20',
              'completedPrayers': ['mass'],
              'completedIntentions': [],
            }
          },
          'prayer-date-override': null,
        },
      };

      final result = service.parseBackup(raw);
      expect(result, isA<ImportOk>());
      await service.applyImport((result as ImportOk).data);

      expect(boxes.intentions.get('r1')!.title, 'From React');
      expect(boxes.logs.get('2026-04-20')!.completedPrayers, ['mass']);
      // null override should clear, not crash.
      expect(boxes.settings.get(SettingsKeys.dateOverride), isNull);
    });

    test('parses legacy unversioned (flat) backup', () async {
      final raw = {
        'prayer-intentions': [
          {
            'id': 'legacy1',
            'title': 'Legacy import',
            'createdAt': '2025-12-01T00:00:00.000Z',
            'priority': 'low',
            'isArchived': false,
          }
        ],
      };
      final result = service.parseBackup(raw);
      expect(result, isA<ImportOk>());
      await service.applyImport((result as ImportOk).data);
      expect(boxes.intentions.get('legacy1')!.title, 'Legacy import');
    });

    test('rejects unknown / non-object payloads', () {
      expect(service.parseBackup('not a map'), isA<ImportFail>());
      expect(service.parseBackup({'unrelated': 1}), isA<ImportFail>());
    });

    test('rejects future schema versions', () {
      final r = service.parseBackup({
        'version': 99,
        'exportedAt': 'whenever',
        'data': {'prayer-intentions': []},
      });
      expect(r, isA<ImportFail>());
      expect((r as ImportFail).error, contains('newer version'));
    });
  });
}

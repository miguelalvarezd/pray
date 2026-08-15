import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pray/data/boxes.dart';
import 'package:pray/services/api/lectio_client.dart';
import 'package:pray/services/api/litcal_client.dart';

import '../test_helpers.dart';

void main() {
  late AppBoxes boxes;
  late dynamic tmp;

  setUp(() async {
    final (b, t) = await initTestHive();
    boxes = b;
    tmp = t;
  });

  tearDown(() async => tearDownTestHive(boxes, tmp));

  group('LitCalClient', () {
    test('fetches the year, caches raw JSON, and parses the day', () async {
      var hits = 0;
      final mock = MockClient((req) async {
        hits++;
        expect(req.url.toString(), contains('/calendar/2026'));
        return http.Response(
          jsonEncode({
            'litcal': [
              {
                'date': '2026-05-01',
                'name': 'Saint Joseph the Worker',
                'color': ['white'],
                'rankName': 'memorial',
                'readings': {'gospel': 'Mt 13:54-58'},
              }
            ]
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      final client = LitCalClient(boxes.litcalCache, client: mock);

      final day = await client.dayFor(DateTime(2026, 5, 1));
      expect(day, isNotNull);
      expect(day!.celebrations.first.title, 'Saint Joseph the Worker');
      expect(day.celebrations.first.colour, 'white');
      expect(boxes.litcalCache.containsKey('2026'), isTrue);

      // Second call should hit the cache, not the network.
      final day2 = await client.dayFor(DateTime(2026, 5, 1));
      expect(day2!.celebrations.first.title, 'Saint Joseph the Worker');
      expect(hits, 1);
    });

    test('colorSyncFor reads the cached year without a network call', () async {
      await boxes.litcalCache.put(
        '2026',
        jsonEncode([
          {
            'date': '2026-05-02',
            'name': 'Saint Athanasius',
            'color': 'white',
          }
        ]),
      );
      // Pass a client that would explode if called.
      final client = LitCalClient(
        boxes.litcalCache,
        client: MockClient((_) async => throw StateError('no network')),
      );
      expect(client.colorSyncFor('2026-05-02'), 'white');
      expect(client.colorSyncFor('2026-05-03'), isNull);
    });

    test('returns null when the API errors and there is no cache', () async {
      final mock = MockClient((_) async => http.Response('boom', 500));
      final client = LitCalClient(boxes.litcalCache, client: mock);
      expect(await client.dayFor(DateTime(2026, 5, 1)), isNull);
      expect(boxes.litcalCache.length, 0);
    });
  });

  group('LectioClient', () {
    test('caches the devotion and skips network within the TTL window', () async {
      var hits = 0;
      final mock = MockClient((_) async {
        hits++;
        return http.Response(
          jsonEncode([
            {
              'date': '2026-05-01',
              'firstReadingRef': 'Acts 13:26-33',
              'gospelRef': 'Jn 14:1-6',
              'quote': 'I am the way, the truth, and the life.',
              'quoteCitation': 'John 14:6',
            }
          ]),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      final client = LectioClient(boxes.lectioCache, client: mock);
      final fetchedAt = DateTime.utc(2026, 5, 1, 8);

      final d = await client.devotionFor(DateTime(2026, 5, 1), now: fetchedAt);
      expect(d?.gospelRef, 'Jn 14:1-6');
      expect(hits, 1);

      // Second call within TTL should serve from cache.
      final d2 = await client.devotionFor(
        DateTime(2026, 5, 1),
        now: fetchedAt.add(const Duration(days: 5)),
      );
      expect(d2?.gospelRef, 'Jn 14:1-6');
      expect(hits, 1);
    });

    test('re-fetches when the cached entry is older than TTL', () async {
      var hits = 0;
      final mock = MockClient((_) async {
        hits++;
        return http.Response(
          jsonEncode([
            {'gospelRef': 'fresh'}
          ]),
          200,
        );
      });
      final client = LectioClient(boxes.lectioCache, client: mock);
      // Seed a stale envelope for today (cached 60 days ago).
      await boxes.lectioCache.put(
        '2026-05-01',
        jsonEncode({
          'cachedAt': DateTime.utc(2026, 3, 1).toIso8601String(),
          'data': {'gospelRef': 'stale'},
        }),
      );
      final d = await client.devotionFor(
        DateTime(2026, 5, 1),
        now: DateTime.utc(2026, 5, 1, 8),
      );
      expect(d?.gospelRef, 'fresh');
      expect(hits, 1);
    });

    test('returns null on transport error and leaves cache untouched', () async {
      final mock = MockClient((_) async => throw StateError('offline'));
      final client = LectioClient(boxes.lectioCache, client: mock);
      expect(await client.devotionFor(DateTime(2026, 5, 1)), isNull);
      expect(boxes.lectioCache.length, 0);
    });
  });
}

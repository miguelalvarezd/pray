import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:pray/core/time/logical_day.dart';
import 'package:pray/data/boxes.dart';
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

  test('at 01:00 on a Sunday the Liturgical Day is still Saturday', () async {
    await boxes.litcalCache.put(
      '2026_en',
      jsonEncode([
        {'date': '2026-05-02', 'name': 'Saint Athanasius', 'color': 'white'},
        {'date': '2026-05-03', 'name': 'Fifth Sunday of Easter', 'color': 'white'},
      ]),
    );
    final client = LitCalClient(
      boxes.litcalCache,
      client: MockClient((_) async => throw StateError('no network')),
    );

    final day = logicalToday(now: DateTime(2026, 5, 3, 1, 0));
    final liturgy = await client.dayFor(day);

    expect(liturgy!.title, 'Saint Athanasius');
  });
}

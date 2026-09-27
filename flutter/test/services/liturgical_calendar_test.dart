import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pray/core/time/logical_day.dart';
import 'package:pray/domain/mass/types.dart';
import 'package:pray/services/liturgy/liturgical_calendar.dart';
import 'package:pray/services/liturgy/reading_references.dart';

void main() {
  // The real bundled data, as the app ships it.
  final calendar = LiturgicalCalendar.fromJson(
    File('assets/liturgy/liturgy.json').readAsStringSync(),
  );

  test('a Day gives its Celebration, rank and colour', () {
    final day = calendar.dayFor(DateTime(2026, 10, 12))!;
    expect(day.celebration.name(Lang.es), 'Nuestra Señora del Pilar');
    expect(day.celebration.name(Lang.en), 'Our Lady of the Pillar');
    expect(day.celebration.rank, CelebrationRank.feast);
    expect(day.color, 'white');
  });

  test('Optional Memorials are listed as alternatives, with their names', () {
    final day = calendar.dayFor(DateTime(2026, 9, 28))!;
    expect(day.celebration.rank, CelebrationRank.weekday);
    expect(
      day.optionalMemorials.map((c) => c.name(Lang.en)),
      ['Saint Wenceslaus, Martyr', 'Saint Lawrence Ruiz and Companions, Martyrs'],
    );
  });

  test('at 01:00 on a Sunday the Liturgical Day is still Saturday', () {
    final day = logicalToday(now: DateTime(2026, 5, 3, 1, 0));
    expect(calendar.dayFor(day)!.date, '2026-05-02');
  });

  test('a Day outside the bundled years has no Liturgical Day', () {
    expect(calendar.dayFor(DateTime(calendar.toYear + 1, 1, 1)), isNull);
  });

  test('the bundled years reach at least 3 years past the current year', () {
    // If this fails, regenerate the data with a later end year (tools/liturgy).
    expect(calendar.toYear - DateTime.now().year, greaterThanOrEqualTo(3));
  });

  group('Reading References in English', () {
    List<String> refs(DateTime day) => [
          for (final r in calendar.dayFor(day)!.readings)
            '${r.kind.name}: ${formatReading(r, Lang.en)}',
        ];

    test('a Sunday lists all four Readings, with a shorter form after "or"', () {
      expect(refs(DateTime(2026, 9, 27)), [
        'first: Ez 18:25-28',
        'psalm: Ps 25:4-5, 6-7, 8-9',
        'second: Phil 2:1-11 or 2:1-5',
        'gospel: Mt 21:28-32',
      ]);
    });

    test('a weekday has no Second Reading', () {
      expect(refs(DateTime(2026, 9, 28)), [
        'first: Jb 1:6-22',
        'psalm: Ps 17:1, 2-3, 6-7',
        'gospel: Lk 9:46-50',
      ]);
    });

    test('alternatives from different books keep their book', () {
      expect(refs(DateTime(2026, 7, 29)).last, 'gospel: Jn 11:19-27 or Lk 10:38-42');
    });

    test('passages spanning chapters separate them with "; "', () {
      expect(refs(DateTime(2026, 10, 2)).first, startsWith('first: Jb 38:1, 12-21; 40:3-'));
    });
  });
}

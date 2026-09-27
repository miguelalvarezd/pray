import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pray/core/time/logical_day.dart';
import 'package:pray/domain/mass/types.dart';
import 'package:pray/services/liturgy/liturgical_calendar.dart';

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
}

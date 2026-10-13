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

  test('the bundled years end more than 3 years after the current year', () {
    // Fails once the current year is within 3 years of the end: regenerate
    // the data with a later end year (tools/liturgy).
    expect(calendar.toYear - DateTime.now().year, greaterThan(3));
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

  List<String> formatted(DateTime day, Lang lang) =>
      [for (final r in calendar.dayFor(day)!.readings) formatReading(r, lang)];

  group('Reading References in Spanish, as Spain\'s lectionary writes them', () {
    test('a Sunday: Spain\'s abbreviations, punctuation and psalm numbering', () {
      expect(formatted(DateTime(2026, 9, 27), Lang.es), [
        'Ez 18, 25-28',
        'Sal 24',
        'Flp 2, 1-11 o 2, 1-5',
        'Mt 21, 28-32',
      ]);
    });

    test('passages across chapters, and several chapters', () {
      expect(formatted(DateTime(2026, 2, 18), Lang.es)[2], '2 Cor 5, 20 — 6, 2');
      expect(formatted(DateTime(2026, 10, 2), Lang.es).first, startsWith('Job 38, 1. 12-21; 40, 3-'));
    });

    test('psalms that Spain numbers differently, including split ones', () {
      // Hebrew 116:12-18 is Spain's Psalm 115 (Holy Thursday).
      expect(formatted(DateTime(2026, 4, 2), Lang.es)[1], 'Sal 115');
      // Hebrew 147:12-20 is Spain's Psalm 147 (Second Sunday after Christmas).
      expect(formatted(DateTime(2026, 1, 4), Lang.es)[1], 'Sal 147');
      // Hebrew 51 is Spain's Psalm 50 (Ash Wednesday).
      expect(formatted(DateTime(2026, 2, 18), Lang.es)[1], 'Sal 50');
    });
  });

  group("Spain's psalm numbering", () {
    test('Psalms 1-8 and 148-150 keep their number', () {
      expect(vulgatePsalm(1, 1), 1);
      expect(vulgatePsalm(8, 1), 8);
      expect(vulgatePsalm(148, 1), 148);
      expect(vulgatePsalm(150, 1), 150);
    });

    test('Hebrew 9 and 10 are both Psalm 9', () {
      expect(vulgatePsalm(9, 2), 9);
      expect(vulgatePsalm(10, 1), 9);
    });

    test('Hebrew 11-113 and 117-146 are one lower', () {
      expect(vulgatePsalm(23, 1), 22);
      expect(vulgatePsalm(113, 1), 112);
      expect(vulgatePsalm(118, 1), 117);
      expect(vulgatePsalm(146, 1), 145);
    });

    test('Hebrew 114 and 115 are both Psalm 113', () {
      expect(vulgatePsalm(114, 1), 113);
      expect(vulgatePsalm(115, 1), 113);
    });

    test('Hebrew 116 splits into Psalms 114 (verses 1-9) and 115 (verses 10-19)', () {
      expect(vulgatePsalm(116, 1), 114);
      expect(vulgatePsalm(116, 9), 114);
      expect(vulgatePsalm(116, 10), 115);
      expect(vulgatePsalm(116, 12), 115);
    });

    test('Hebrew 147 splits into Psalms 146 (verses 1-11) and 147 (verses 12-20)', () {
      expect(vulgatePsalm(147, 1), 146);
      expect(vulgatePsalm(147, 11), 146);
      expect(vulgatePsalm(147, 12), 147);
    });
  });

  group('Reading References in German', () {
    test('a Sunday: German abbreviations and both psalm numbers', () {
      expect(formatted(DateTime(2026, 9, 27), Lang.de), [
        'Ez 18,25-28',
        'Ps 25 (24)',
        'Phil 2,1-11 oder 2,1-5',
        'Mt 21,28-32',
      ]);
    });

    test('passages across chapters', () {
      expect(formatted(DateTime(2026, 2, 18), Lang.de)[2], '2 Kor 5,20 – 6,2');
    });
  });
}

import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/time/logical_day.dart';
import '../../domain/mass/types.dart';
import 'reading_references.dart';

/// Rank of a Celebration, highest first.
enum CelebrationRank {
  solemnity,
  feast,
  sunday,
  memorial,
  optionalMemorial,
  weekday;

  static CelebrationRank fromJson(String s) => switch (s) {
        'SOLEMNITY' => solemnity,
        'FEAST' => feast,
        'SUNDAY' => sunday,
        'MEMORIAL' => memorial,
        'OPTIONAL_MEMORIAL' => optionalMemorial,
        _ => weekday,
      };
}

/// What a Liturgical Day celebrates, or one of its Optional Memorials.
class Celebration {
  final String id;
  final CelebrationRank rank;
  final Map<Lang, String> _names;

  const Celebration({
    required this.id,
    required this.rank,
    required Map<Lang, String> names,
  }) : _names = names;

  /// The Celebration's name in [lang], falling back to English.
  String name(Lang lang) => _names[lang] ?? _names[Lang.en] ?? id;
}

/// The Church calendar for one Day (see `CONTEXT.md`).
class LiturgicalDay {
  final String date;

  /// Season id, e.g. `ORDINARY_TIME`, `LENT`.
  final String season;
  final Celebration celebration;

  /// Liturgical colour (`green`, `white`, `red`, `purple`, `rose`, …), or
  /// null on Days without a Mass.
  final String? color;
  final List<Celebration> optionalMemorials;

  /// The Day's Readings in order (First Reading, Psalm, Second Reading if
  /// any, Gospel; the Easter Vigil has more).
  final List<Reading> readings;

  const LiturgicalDay({
    required this.date,
    required this.season,
    required this.celebration,
    required this.color,
    required this.optionalMemorials,
    required this.readings,
  });
}

/// Spain's Liturgical Calendar for the bundled range of years, generated
/// ahead of time by `tools/liturgy` (ADR-0003). Never touches the network.
class LiturgicalCalendar {
  final int fromYear;
  final int toYear;
  final Map<String, Map<String, dynamic>> _days;
  final Map<String, Map<Lang, String>> _names;
  final Map<String, List<Reading>> _lectionary;

  LiturgicalCalendar._(
    this.fromYear,
    this.toYear,
    this._days,
    this._names,
    this._lectionary,
  );

  factory LiturgicalCalendar.fromJson(String json) {
    final data = jsonDecode(json) as Map<String, dynamic>;
    final names = <String, Map<Lang, String>>{
      for (final MapEntry(:key, :value)
          in (data['names'] as Map<String, dynamic>).entries)
        key: {
          for (final lang in Lang.values)
            if ((value as Map<String, dynamic>)[lang.name] case final String n)
              lang: n,
        },
    };
    return LiturgicalCalendar._(
      data['fromYear'] as int,
      data['toYear'] as int,
      (data['days'] as Map<String, dynamic>).cast<String, Map<String, dynamic>>(),
      names,
      {
        for (final MapEntry(:key, :value)
            in ((data['lectionary'] as Map<String, dynamic>?) ?? const {}).entries)
          key: [
            for (final r in value as List) Reading.fromJson(r as Map<String, dynamic>),
          ],
      },
    );
  }

  /// The Liturgical Day for [day] (a Day, already shifted to 04:00), or null
  /// outside the bundled years.
  LiturgicalDay? dayFor(DateTime day) {
    final date = formatLogDate(day);
    final raw = _days[date];
    if (raw == null) return null;
    final rank = CelebrationRank.fromJson(raw['rank'] as String);
    return LiturgicalDay(
      date: date,
      season: raw['season'] as String,
      celebration: _celebration(raw['celebration'] as String, rank),
      color: raw['color'] as String?,
      optionalMemorials: [
        for (final id in (raw['optionalMemorials'] as List?) ?? const [])
          _celebration(id as String, CelebrationRank.optionalMemorial),
      ],
      readings: _lectionary[raw['readings']] ?? const [],
    );
  }

  Celebration _celebration(String id, CelebrationRank rank) =>
      Celebration(id: id, rank: rank, names: _names[id] ?? const {});
}

/// The bundled Liturgical Calendar, loaded once from the app's assets.
final liturgicalCalendarProvider = FutureProvider<LiturgicalCalendar>((ref) async {
  return LiturgicalCalendar.fromJson(
    await rootBundle.loadString('assets/liturgy/liturgy.json'),
  );
});

/// The Liturgical Day for a Day, or null while the calendar is loading or
/// outside the bundled years.
final liturgicalDayProvider = Provider.family<LiturgicalDay?, DateTime>((ref, day) {
  return ref.watch(liturgicalCalendarProvider).value?.dayFor(day);
});

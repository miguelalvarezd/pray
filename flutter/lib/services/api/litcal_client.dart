import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:http/http.dart' as http;

import '../../data/providers.dart';

/// One celebration on a given liturgical day.
class LiturgicalCelebration {
  final String title;
  final String colour; // 'green' / 'purple' / 'white' / 'red' / 'rose'
  final String? rank;
  final Map<String, dynamic>? readings;

  const LiturgicalCelebration({
    required this.title,
    required this.colour,
    this.rank,
    this.readings,
  });
}

class LitCalDay {
  final String date; // YYYY-MM-DD
  final List<LiturgicalCelebration> celebrations;
  const LitCalDay({required this.date, required this.celebrations});

  /// Convenience: dominant color (first celebration), null if none.
  String? get colour => celebrations.isEmpty ? null : celebrations.first.colour;
  String? get title => celebrations.isEmpty ? null : celebrations.first.title;
}

/// Read-only client for the LitCal calendar at
/// `https://litcal.johnromanodorazio.com/api/v5/calendar/{year}`. Caches the
/// raw year payload in a Hive box so subsequent days within the same year are
/// fully offline.
class LitCalClient {
  final Box<String> cache;
  final http.Client _http;

  LitCalClient(this.cache, {http.Client? client})
      : _http = client ?? http.Client();

  /// Synchronous read of the cached liturgical color for a given date string
  /// (`YYYY-MM-DD`). Returns null if the year hasn't been fetched yet — never
  /// performs a network call.
  String? colorSyncFor(String dateStr) {
    final yearStr = dateStr.split('-').first;
    final raw = cache.get('${yearStr}_en');
    if (raw == null) return null;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      final event = list.cast<Map<String, dynamic>>().firstWhere(
            (e) => _dateStrFrom(e['date']) == dateStr,
            orElse: () => const {},
          );
      if (event.isEmpty) return null;
      return _extractColor(event);
    } catch (_) {
      return null;
    }
  }

  /// Returns the [LitCalDay] for [date], fetching the whole year if it's
  /// not already cached. Returns null on any network error so callers can fall
  /// back gracefully to the curated defaults.
  Future<LitCalDay?> dayFor(DateTime date) async {
    final dateStr = _fmt(date);
    final yearStr = date.year.toString();

    List<dynamic>? yearData;
    final cacheKey = '${yearStr}_en';
    final cached = cache.get(cacheKey);
    if (cached != null) {
      try {
        yearData = jsonDecode(cached) as List<dynamic>;
      } catch (_) {
        yearData = null;
      }
    }

    if (yearData == null) {
      try {
        final res = await _http.get(Uri.parse(
          'https://litcal.johnromanodorazio.com/api/v5/calendar/$yearStr?locale=EN',
        ));
        if (res.statusCode != 200) return null;
        final payload = jsonDecode(res.body) as Map<String, dynamic>;
        final litcal = payload['litcal'];
        yearData = litcal is List
            ? litcal
            : (litcal is Map ? litcal.values.toList() : null);
        if (yearData == null) return null;
        await cache.put(cacheKey, jsonEncode(yearData));
      } catch (_) {
        return null;
      }
    }

    final events = yearData
        .cast<Map<String, dynamic>>()
        .where((e) => _dateStrFrom(e['date']) == dateStr)
        .toList();
    if (events.isEmpty) return null;

    return LitCalDay(
      date: dateStr,
      celebrations: events.map((e) {
        return LiturgicalCelebration(
          title: e['name'] as String? ?? 'Roman Calendar',
          colour: _extractColor(e) ?? 'green',
          rank: e['rankName'] as String?,
          readings: e['readings'] as Map<String, dynamic>?,
        );
      }).toList(),
    );
  }

  /// Normalizes the `date` field from a LitCal event, which may be a
  /// `"YYYY-MM-DD..."` string or a Unix-seconds integer, to `"YYYY-MM-DD"`.
  static String? _dateStrFrom(dynamic raw) {
    if (raw is String) return raw.length >= 10 ? raw.substring(0, 10) : raw;
    if (raw is int) {
      final dt = DateTime.fromMillisecondsSinceEpoch(raw * 1000, isUtc: true);
      final y = dt.year.toString().padLeft(4, '0');
      final m = dt.month.toString().padLeft(2, '0');
      final d = dt.day.toString().padLeft(2, '0');
      return '$y-$m-$d';
    }
    return null;
  }

  /// LitCal returns `color` as a string OR an array, sometimes only on
  /// `colorNames`. This normalizes to a lowercase color name.
  static String? _extractColor(Map<String, dynamic> e) {
    final raw = e['color'] ?? e['colorNames'];
    if (raw is String) return raw.toLowerCase();
    if (raw is List && raw.isNotEmpty) {
      final first = raw.first;
      if (first is String) return first.toLowerCase();
    }
    return null;
  }

  static String _fmt(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '$y-$m-$dd';
  }
}

final litCalClientProvider = Provider<LitCalClient>((ref) {
  return LitCalClient(ref.watch(litcalCacheBoxProvider));
});

/// Async lookup for a specific date. Riverpod caches per-arg so calls for the
/// same date during a session don't re-fetch.
final litcalDayProvider =
    FutureProvider.family<LitCalDay?, DateTime>((ref, date) async {
  final client = ref.watch(litCalClientProvider);
  return client.dayFor(date);
});

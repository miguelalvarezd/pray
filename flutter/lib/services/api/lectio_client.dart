import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:http/http.dart' as http;

import '../../data/providers.dart';

class DailyLectio {
  final String? date;
  final String? firstReadingRef;
  final String? secondReadingRef;
  final String? psalmRef;
  final String? gospelRef;
  final String? quote;
  final String? quoteCitation;
  final String? dailyPrayer;
  final String? saintReflection;
  final String? liturgicalColor;
  final List<String> tags;

  const DailyLectio({
    this.date,
    this.firstReadingRef,
    this.secondReadingRef,
    this.psalmRef,
    this.gospelRef,
    this.quote,
    this.quoteCitation,
    this.dailyPrayer,
    this.saintReflection,
    this.liturgicalColor,
    this.tags = const [],
  });

  static DailyLectio fromJson(Map<String, dynamic> j) => DailyLectio(
        date: j['date'] as String?,
        firstReadingRef: j['firstReadingRef'] as String?,
        secondReadingRef: j['secondReadingRef'] as String?,
        psalmRef: j['psalmRef'] as String?,
        gospelRef: j['gospelRef'] as String?,
        quote: j['quote'] as String?,
        quoteCitation: j['quoteCitation'] as String?,
        dailyPrayer: j['dailyPrayer'] as String?,
        saintReflection: j['saintReflection'] as String?,
        liturgicalColor: j['liturgicalColor'] as String?,
        tags: (j['tags'] as List?)?.cast<String>() ?? const [],
      );

  Map<String, dynamic> toJson() => {
        if (date != null) 'date': date,
        if (firstReadingRef != null) 'firstReadingRef': firstReadingRef,
        if (secondReadingRef != null) 'secondReadingRef': secondReadingRef,
        if (psalmRef != null) 'psalmRef': psalmRef,
        if (gospelRef != null) 'gospelRef': gospelRef,
        if (quote != null) 'quote': quote,
        if (quoteCitation != null) 'quoteCitation': quoteCitation,
        if (dailyPrayer != null) 'dailyPrayer': dailyPrayer,
        if (saintReflection != null) 'saintReflection': saintReflection,
        if (liturgicalColor != null) 'liturgicalColor': liturgicalColor,
        if (tags.isNotEmpty) 'tags': tags,
      };
}

/// Read-only client for `https://dailylectio.org/devotions.json`. Caches the
/// (single) most recent entry keyed by the requested local date with a
/// 30-day TTL — older entries are evicted on read.
class LectioClient {
  static const Duration ttl = Duration(days: 30);

  final Box<String> cache;
  final http.Client _http;

  LectioClient(this.cache, {http.Client? client})
      : _http = client ?? http.Client();

  Future<DailyLectio?> dailyLectioFor(DateTime date, {DateTime? now}) async {
    final dateStr = _fmt(date);

    final cached = cache.get(dateStr);
    if (cached != null) {
      try {
        final envelope = jsonDecode(cached) as Map<String, dynamic>;
        final cachedAt = DateTime.parse(envelope['cachedAt'] as String);
        if ((now ?? DateTime.now()).difference(cachedAt) < ttl) {
          final data = envelope['data'] as Map<String, dynamic>;
          return DailyLectio.fromJson(data);
        }
        // Stale — fall through to re-fetch.
      } catch (_) {
        // Corrupt entry; re-fetch.
      }
    }

    try {
      final res =
          await _http.get(Uri.parse('https://dailylectio.org/devotions.json'));
      if (res.statusCode != 200) return null;
      final payload = jsonDecode(res.body);
      if (payload is! List || payload.isEmpty) return null;
      final first = payload.first as Map<String, dynamic>;
      await cache.put(
        dateStr,
        jsonEncode({
          'cachedAt': (now ?? DateTime.now()).toIso8601String(),
          'data': first,
        }),
      );
      return DailyLectio.fromJson(first);
    } catch (_) {
      return null;
    }
  }

  static String _fmt(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '$y-$m-$dd';
  }
}

final lectioClientProvider = Provider<LectioClient>((ref) {
  return LectioClient(ref.watch(lectioCacheBoxProvider));
});

final dailyLectioProvider =
    FutureProvider.family<DailyLectio?, DateTime>((ref, date) async {
  final client = ref.watch(lectioClientProvider);
  return client.dailyLectioFor(date);
});

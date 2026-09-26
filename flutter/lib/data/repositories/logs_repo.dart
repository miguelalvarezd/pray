import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/daily_log.dart';
import '../providers.dart';

class LogsNotifier extends Notifier<Map<String, DailyLog>> {
  @override
  Map<String, DailyLog> build() {
    final box = ref.watch(logsBoxProvider);
    return {
      for (final key in box.keys) key as String: box.get(key) as DailyLog,
    };
  }

  DailyLog forDate(String date) =>
      ref.read(logsBoxProvider).get(date) ??
      DailyLog(date: date);

  Future<void> save(DailyLog log) async {
    await ref.read(logsBoxProvider).put(log.date, log);
    ref.invalidateSelf();
  }

  Future<void> togglePrayer(String date, String prayerId) async {
    final current = forDate(date);
    final list = List<String>.from(current.completedPrayers);
    if (list.contains(prayerId)) {
      list.remove(prayerId);
    } else {
      list.add(prayerId);
    }
    await save(current.copyWith(completedPrayers: list));
  }

  Future<void> toggleIntention(String date, String intentionId) async {
    final current = forDate(date);
    final list = List<String>.from(current.completedIntentions);
    if (list.contains(intentionId)) {
      list.remove(intentionId);
    } else {
      list.add(intentionId);
    }
    await save(current.copyWith(completedIntentions: list));
  }

  /// Removes a deleted Novena from every Daily Log.
  Future<void> forgetNovena(String novenaId) async {
    final box = ref.read(logsBoxProvider);
    for (final key in box.keys.toList()) {
      final log = box.get(key)!;
      final ids = log.completedNovenas;
      if (ids == null || !ids.contains(novenaId)) continue;
      await box.put(
        key,
        log.copyWith(completedNovenas: ids.where((id) => id != novenaId).toList()),
      );
    }
    ref.invalidateSelf();
  }

  Future<void> toggleNovena(String date, String novenaId) async {
    final current = forDate(date);
    final list = List<String>.from(current.completedNovenas ?? const []);
    if (list.contains(novenaId)) {
      list.remove(novenaId);
    } else {
      list.add(novenaId);
    }
    await save(current.copyWith(completedNovenas: list));
  }
}

final logsProvider =
    NotifierProvider<LogsNotifier, Map<String, DailyLog>>(LogsNotifier.new);

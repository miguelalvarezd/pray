import 'package:intl/intl.dart';

import '../data/models/daily_log.dart';

class StreakResult {
  final int current;
  final int best;
  const StreakResult({required this.current, required this.best});
}

typedef LogPredicate = bool Function(DailyLog log);

/// Strips the time component so DST transitions don't affect day-diff math.
DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// A Prayed Day has at least one Daily Prayer, Activity or Novena prayed.
/// Intentions and the Gratitude Entry on their own don't count.
bool isPrayedDay(DailyLog log) =>
    log.completedPrayers.isNotEmpty ||
    (log.completedActivities?.isNotEmpty ?? false) ||
    (log.completedNovenas?.isNotEmpty ?? false);

/// Builds a predicate that checks whether a specific prayer was completed.
LogPredicate hasPrayerCompleted(String prayerId) =>
    (log) => log.completedPrayers.contains(prayerId);

/// Generic streak calculator. Mirrors `calculateStreak` in
/// `src/lib/streaks.ts`.
///
/// "Current" walks backwards from [today]. It tolerates today being empty as
/// long as yesterday counted — so a user who hasn't prayed yet today still
/// sees their streak from yesterday.
StreakResult calculateStreak(
  Map<String, DailyLog> logs,
  LogPredicate predicate,
  DateTime today,
) {
  final fmt = DateFormat('yyyy-MM-dd');
  final todayStr = fmt.format(today);
  final yesterday = today.subtract(const Duration(days: 1));
  final yesterdayStr = fmt.format(yesterday);

  bool hasActivity(String dateStr) {
    final log = logs[dateStr];
    return log != null && predicate(log);
  }

  int current = 0;
  DateTime checkDate = today;
  if (hasActivity(todayStr)) {
    current++;
    checkDate = today.subtract(const Duration(days: 1));
  } else if (hasActivity(yesterdayStr)) {
    checkDate = today.subtract(const Duration(days: 1));
  }

  if (current > 0 || hasActivity(yesterdayStr)) {
    while (true) {
      final dateStr = fmt.format(checkDate);
      if (hasActivity(dateStr)) {
        if (dateStr != todayStr) current++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
  }

  // Best streak — scan all dates chronologically for the longest consecutive run.
  int best = 0;
  int temp = 0;
  final sortedDates = logs.keys.toList()..sort();
  DateTime? lastDate;
  for (final dateStr in sortedDates) {
    if (!hasActivity(dateStr)) continue;
    final d = _dateOnly(DateTime.parse(dateStr));
    if (lastDate == null) {
      temp = 1;
    } else {
      // Use calendar-day diff to avoid DST artifacts from Duration arithmetic.
      final diff = d.difference(lastDate).inDays;
      if (diff == 1) {
        temp++;
      } else if (diff > 1) {
        temp = 1;
      }
    }
    lastDate = d;
    if (temp > best) best = temp;
  }

  // Guarantee best >= current (the current run is always part of history).
  if (best < current) best = current;

  return StreakResult(current: current, best: best);
}

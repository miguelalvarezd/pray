import '../data/models/daily_log.dart';
import '../data/models/intention.dart';
import '../data/models/intention_status.dart';
import '../data/models/priority.dart';

/// Urgency score used to sort intentions on the Intentions screen and to
/// flag urgent items. Mirrors `calculateUrgency` in `src/lib/intentions.ts`.
double calculateUrgency(Intention i, DateTime now) {
  if (i.status != IntentionStatus.active) return -1;

  double score = switch (i.priority) {
    Priority.high => 50,
    Priority.medium => 30,
    Priority.low => 10,
  };

  if (i.targetDate != null) {
    final target = DateTime.parse(i.targetDate!);
    final daysUntil = _daysBetween(target, now);
    if (daysUntil < 0) {
      score -= daysUntil.abs() * 5;
    } else if (daysUntil <= 7) {
      score += (7 - daysUntil) * 10;
    } else {
      final extra = 20 - daysUntil;
      score += extra > 0 ? extra : 0;
    }
  } else {
    final created = DateTime.parse(i.createdAt);
    final daysSince = _daysBetween(now, created);
    score -= daysSince * 0.5;
  }

  return score;
}

List<Intention> sortIntentions(Iterable<Intention> intentions, DateTime now) {
  final list = intentions.toList();
  list.sort((a, b) => calculateUrgency(b, now).compareTo(calculateUrgency(a, now)));
  return list;
}

/// `intentionId → number of distinct days marked as prayed-for`. Computed
/// once per logs map to avoid re-walking on every card render. Mirrors
/// `buildIntentionCountMap` in `src/lib/intentions.ts`.
Map<String, int> buildIntentionCountMap(Map<String, DailyLog> logs) {
  final out = <String, int>{};
  for (final log in logs.values) {
    for (final id in log.completedIntentions) {
      out[id] = (out[id] ?? 0) + 1;
    }
  }
  return out;
}

/// Calendar-day difference, ignoring time-of-day. Matches the spirit of
/// `differenceInDays` from date-fns: positive when [a] is later than [b].
int _daysBetween(DateTime a, DateTime b) {
  final ad = DateTime(a.year, a.month, a.day);
  final bd = DateTime(b.year, b.month, b.day);
  return ad.difference(bd).inDays;
}

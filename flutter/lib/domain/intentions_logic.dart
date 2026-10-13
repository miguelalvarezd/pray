import '../data/models/daily_log.dart';
import '../data/models/intention.dart';
import '../data/models/intention_status.dart';
import '../data/models/novena.dart';
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

/// Whether [i] is still being prayed for but its Target Date is before
/// [today] (a Day), so the user should be asked whether it was Answered.
bool isTargetDatePassed(Intention i, DateTime today) {
  final target = i.targetDate;
  if (target == null || i.status != IntentionStatus.active) return false;
  return _daysBetween(DateTime.parse(target), today) < 0;
}

/// Active Intentions whose title contains [text], ignoring case and
/// surrounding spaces. Offered as suggestions when typing what a Novena is
/// offered for.
List<Intention> suggestIntentions(String text, Iterable<Intention> intentions) {
  final query = _normalized(text);
  if (query.isEmpty) return const [];
  return [
    for (final i in intentions)
      if (i.status == IntentionStatus.active &&
          i.title.toLowerCase().contains(query))
        i,
  ];
}

/// The active Intention whose title is exactly [text], ignoring case and
/// surrounding spaces, if any. Typing it links that Intention rather than
/// creating a duplicate.
Intention? findActiveIntentionTitled(String text, Iterable<Intention> intentions) {
  final title = _normalized(text);
  if (title.isEmpty) return null;
  return intentions
      .where((i) => i.status == IntentionStatus.active && _normalized(i.title) == title)
      .firstOrNull;
}

String _normalized(String s) => s.trim().toLowerCase();

List<Intention> sortIntentions(Iterable<Intention> intentions, DateTime now) {
  final list = intentions.toList();
  list.sort((a, b) => calculateUrgency(b, now).compareTo(calculateUrgency(a, now)));
  return list;
}

/// `intentionId → number of distinct Days it was prayed for`. A Day counts
/// if the Intention was ticked or a Novena offered for it was prayed.
/// Computed once per logs map to avoid re-walking on every card render.
Map<String, int> buildIntentionCountMap(
  Map<String, DailyLog> logs, {
  Iterable<Novena> novenas = const [],
}) {
  final intentionOfNovena = {
    for (final n in novenas)
      if (n.intentionId != null) n.id: n.intentionId!,
  };
  final out = <String, int>{};
  for (final log in logs.values) {
    final prayedFor = {
      ...log.completedIntentions,
      for (final id in log.completedNovenas ?? const <String>[])
        ?intentionOfNovena[id],
    };
    for (final id in prayedFor) {
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

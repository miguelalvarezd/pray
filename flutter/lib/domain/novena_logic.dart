import '../core/time/logical_day.dart';
import '../data/models/daily_log.dart';
import '../data/models/novena.dart';

/// Where a Novena stands on a given Day. Always derived from the Daily Logs,
/// never stored.
sealed class NovenaStatus {
  const NovenaStatus();
}

/// The start Day is still ahead.
class NovenaUpcoming extends NovenaStatus {
  const NovenaUpcoming();
}

/// Within its nine Days. [day] is counted from the start Day (1–9), so a
/// missed Day does not shift the Days that follow.
class NovenaInProgress extends NovenaStatus {
  final int day;
  const NovenaInProgress(this.day);
}

/// Nine Days have passed and the Novena was prayed on each of them.
class NovenaCompleted extends NovenaStatus {
  const NovenaCompleted();
}

/// Nine Days have passed with at least one of them not prayed.
class NovenaIncomplete extends NovenaStatus {
  final int daysPrayed;
  const NovenaIncomplete(this.daysPrayed);
}

/// The Novena's position relative to [today] (a Day). Mirrors the day math
/// used on the Today screen.
NovenaStatus novenaStatus(
  Novena novena,
  Map<String, DailyLog> logs,
  DateTime today,
) {
  final start = DateTime.parse(novena.startDate);
  final day = _calendarDaysBetween(start, today) + 1;
  if (day < 1) return const NovenaUpcoming();
  if (day <= 9) return NovenaInProgress(day);

  var daysPrayed = 0;
  for (var i = 0; i < 9; i++) {
    final key = formatLogDate(DateTime(start.year, start.month, start.day + i));
    if (logs[key]?.completedNovenas?.contains(novena.id) ?? false) daysPrayed++;
  }
  return daysPrayed == 9 ? const NovenaCompleted() : NovenaIncomplete(daysPrayed);
}

/// Whole calendar days from [a] to [b], computed in UTC so a DST change
/// between them can't shave off a day.
int _calendarDaysBetween(DateTime a, DateTime b) =>
    DateTime.utc(b.year, b.month, b.day)
        .difference(DateTime.utc(a.year, a.month, a.day))
        .inDays;

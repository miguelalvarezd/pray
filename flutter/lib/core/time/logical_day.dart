import 'package:intl/intl.dart';

/// Logical day boundary — matches `getLogicalDate()` in `src/App.tsx:37-42`.
/// The day "starts" at 4 AM, so 00:00–03:59 still belongs to the previous day.
const Duration kDayShift = Duration(hours: 4);

/// Returns the user's logical "today" — the calendar day shifted back by
/// [kDayShift] from `now`. If [override] is set (a `YYYY-MM-DD` string from
/// the dev settings), that takes precedence and pins the day to noon UTC of
/// the given date so timezone math doesn't drift it to a neighbor day.
DateTime logicalToday({
  DateTime? now,
  String? override,
}) {
  if (override != null && override.isNotEmpty) {
    return DateTime.parse('${override}T12:00:00');
  }
  return (now ?? DateTime.now()).subtract(kDayShift);
}

/// `YYYY-MM-DD` formatter — the canonical key shape used in DailyLog / Hive.
String formatLogDate(DateTime date) =>
    DateFormat('yyyy-MM-dd').format(date);

/// Day-of-year (1-366), matching the React reflection picker math.
int dayOfYear(DateTime date) =>
    date.difference(DateTime(date.year, 1, 1)).inDays + 1;

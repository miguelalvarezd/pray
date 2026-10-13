import 'package:hive_ce/hive.dart';

part 'daily_log.g.dart';

@HiveType(typeId: 4)
class DailyLog {
  /// `YYYY-MM-DD`.
  @HiveField(0)
  final String date;

  @HiveField(1)
  final List<String> completedPrayers;

  @HiveField(2)
  final List<String> completedIntentions;

  @HiveField(3)
  final List<String>? completedNovenas;

  @HiveField(4)
  final List<String>? completedActivities;

  /// The Day's Gratitude Entry. Persisted under the legacy `journal` key so
  /// older backups import unchanged.
  @HiveField(5)
  final String? gratitudeEntry;

  const DailyLog({
    required this.date,
    this.completedPrayers = const [],
    this.completedIntentions = const [],
    this.completedNovenas,
    this.completedActivities,
    this.gratitudeEntry,
  });

  DailyLog copyWith({
    String? date,
    List<String>? completedPrayers,
    List<String>? completedIntentions,
    List<String>? completedNovenas,
    List<String>? completedActivities,
    String? gratitudeEntry,
  }) =>
      DailyLog(
        date: date ?? this.date,
        completedPrayers: completedPrayers ?? this.completedPrayers,
        completedIntentions: completedIntentions ?? this.completedIntentions,
        completedNovenas: completedNovenas ?? this.completedNovenas,
        completedActivities: completedActivities ?? this.completedActivities,
        gratitudeEntry: gratitudeEntry ?? this.gratitudeEntry,
      );

  Map<String, dynamic> toJson() => {
        'date': date,
        'completedPrayers': completedPrayers,
        'completedIntentions': completedIntentions,
        if (completedNovenas != null) 'completedNovenas': completedNovenas,
        if (completedActivities != null) 'completedActivities': completedActivities,
        if (gratitudeEntry != null) 'journal': gratitudeEntry,
      };

  static DailyLog fromJson(Map<String, dynamic> j) => DailyLog(
        date: j['date'] as String,
        completedPrayers: _stringList(j['completedPrayers']),
        completedIntentions: _stringList(j['completedIntentions']),
        completedNovenas: j['completedNovenas'] == null ? null : _stringList(j['completedNovenas']),
        completedActivities:
            j['completedActivities'] == null ? null : _stringList(j['completedActivities']),
        gratitudeEntry: j['journal'] as String?,
      );

  static List<String> _stringList(dynamic raw) {
    if (raw == null) return const [];
    return (raw as List).map((e) => e as String).toList();
  }
}

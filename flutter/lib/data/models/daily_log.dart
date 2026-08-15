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

  @HiveField(5)
  final String? journal;

  const DailyLog({
    required this.date,
    this.completedPrayers = const [],
    this.completedIntentions = const [],
    this.completedNovenas,
    this.completedActivities,
    this.journal,
  });

  DailyLog copyWith({
    String? date,
    List<String>? completedPrayers,
    List<String>? completedIntentions,
    List<String>? completedNovenas,
    List<String>? completedActivities,
    String? journal,
  }) =>
      DailyLog(
        date: date ?? this.date,
        completedPrayers: completedPrayers ?? this.completedPrayers,
        completedIntentions: completedIntentions ?? this.completedIntentions,
        completedNovenas: completedNovenas ?? this.completedNovenas,
        completedActivities: completedActivities ?? this.completedActivities,
        journal: journal ?? this.journal,
      );

  Map<String, dynamic> toJson() => {
        'date': date,
        'completedPrayers': completedPrayers,
        'completedIntentions': completedIntentions,
        if (completedNovenas != null) 'completedNovenas': completedNovenas,
        if (completedActivities != null) 'completedActivities': completedActivities,
        if (journal != null) 'journal': journal,
      };

  static DailyLog fromJson(Map<String, dynamic> j) => DailyLog(
        date: j['date'] as String,
        completedPrayers: _stringList(j['completedPrayers']),
        completedIntentions: _stringList(j['completedIntentions']),
        completedNovenas: j['completedNovenas'] == null ? null : _stringList(j['completedNovenas']),
        completedActivities:
            j['completedActivities'] == null ? null : _stringList(j['completedActivities']),
        journal: j['journal'] as String?,
      );

  static List<String> _stringList(dynamic raw) {
    if (raw == null) return const [];
    return (raw as List).map((e) => e as String).toList();
  }
}

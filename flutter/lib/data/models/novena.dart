import 'package:hive_ce/hive.dart';

part 'novena.g.dart';

@HiveType(typeId: 3)
class Novena {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String intention;

  /// `YYYY-MM-DD`.
  @HiveField(3)
  final String startDate;

  /// ISO-8601 string.
  @HiveField(4)
  final String createdAt;

  /// Optional prayer text copied from a library template when the novena was started.
  @HiveField(5)
  final String? prayer;

  /// Id of the NovenaTemplate this novena was started from, if any.
  @HiveField(6)
  final String? templateId;

  const Novena({
    required this.id,
    required this.title,
    required this.intention,
    required this.startDate,
    required this.createdAt,
    this.prayer,
    this.templateId,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'intention': intention,
        'startDate': startDate,
        'createdAt': createdAt,
        if (prayer != null) 'prayer': prayer,
        if (templateId != null) 'templateId': templateId,
      };

  static Novena fromJson(Map<String, dynamic> j) => Novena(
        id: j['id'] as String,
        title: j['title'] as String,
        intention: j['intention'] as String,
        startDate: j['startDate'] as String,
        createdAt: j['createdAt'] as String,
        prayer: j['prayer'] as String?,
        templateId: j['templateId'] as String?,
      );
}

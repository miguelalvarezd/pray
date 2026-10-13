import 'package:hive_ce/hive.dart';

part 'novena.g.dart';

@HiveType(typeId: 3)
class Novena {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  /// Free-text intention from before schema v4. Only set on records stored
  /// by an older version of the app; the on-device upgrade turns it into a
  /// linked Intention and clears it. Never set this on new records.
  @HiveField(2)
  final String? legacyIntentionText;

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

  /// Id of the Intention this Novena is offered for, if any. A Novena that
  /// honors a saint may be offered for no Intention.
  @HiveField(7)
  final String? intentionId;

  const Novena({
    required this.id,
    required this.title,
    this.intentionId,
    required this.startDate,
    required this.createdAt,
    this.prayer,
    this.templateId,
    this.legacyIntentionText,
  });

  /// This Novena offered for [intentionId] (or for no Intention when null).
  Novena offeredFor(String? intentionId) => Novena(
        id: id,
        title: title,
        intentionId: intentionId,
        startDate: startDate,
        createdAt: createdAt,
        prayer: prayer,
        templateId: templateId,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        if (intentionId != null) 'intentionId': intentionId,
        if (legacyIntentionText != null) 'intention': legacyIntentionText,
        'startDate': startDate,
        'createdAt': createdAt,
        if (prayer != null) 'prayer': prayer,
        if (templateId != null) 'templateId': templateId,
      };

  static Novena fromJson(Map<String, dynamic> j) => Novena(
        id: j['id'] as String,
        title: j['title'] as String,
        intentionId: j['intentionId'] as String?,
        legacyIntentionText: j['intention'] as String?,
        startDate: j['startDate'] as String,
        createdAt: j['createdAt'] as String,
        prayer: j['prayer'] as String?,
        templateId: j['templateId'] as String?,
      );
}

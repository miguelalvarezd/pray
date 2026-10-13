import 'package:hive_ce/hive.dart';

import 'intention_status.dart';
import 'priority.dart';

part 'intention.g.dart';

@HiveType(typeId: 2)
class Intention {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String? description;

  /// ISO-8601 string. Kept as `String` for byte-identical round-trip with the
  /// React app's exported JSON.
  @HiveField(3)
  final String createdAt;

  /// ISO-8601 string, optional.
  @HiveField(4)
  final String? targetDate;

  @HiveField(5)
  final Priority priority;

  /// Archived flag from before schema v2. Only set on records stored by an
  /// older version of the app; the on-device upgrade turns it into [status]
  /// and clears it. Never set this on new records.
  @HiveField(6)
  final bool? legacyIsArchived;

  @HiveField(7, defaultValue: IntentionStatus.active)
  final IntentionStatus status;

  /// The Day (`YYYY-MM-DD`) the Intention was Answered. Only set while
  /// [status] is [IntentionStatus.answered].
  @HiveField(8)
  final String? answeredOn;

  /// Optional note on how the Intention was Answered.
  @HiveField(9)
  final String? answerNote;

  const Intention({
    required this.id,
    required this.title,
    this.description,
    required this.createdAt,
    this.targetDate,
    required this.priority,
    this.status = IntentionStatus.active,
    this.answeredOn,
    this.answerNote,
    this.legacyIsArchived,
  });

  Intention copyWith({
    String? id,
    String? title,
    String? description,
    String? createdAt,
    String? targetDate,
    Priority? priority,
    IntentionStatus? status,
  }) =>
      Intention(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        createdAt: createdAt ?? this.createdAt,
        targetDate: targetDate ?? this.targetDate,
        priority: priority ?? this.priority,
        status: status ?? this.status,
        answeredOn: answeredOn,
        answerNote: answerNote,
      );

  /// This Intention with its Target Date set to [targetDate] (`null` clears
  /// it).
  Intention withTargetDate(String? targetDate) => Intention(
        id: id,
        title: title,
        description: description,
        createdAt: createdAt,
        targetDate: targetDate,
        priority: priority,
        status: status,
        answeredOn: answeredOn,
        answerNote: answerNote,
      );

  /// This Intention with [status], and the answer fields set exactly as
  /// given, so leaving the Answered state always clears them.
  Intention withStatus(
    IntentionStatus status, {
    String? answeredOn,
    String? answerNote,
  }) =>
      Intention(
        id: id,
        title: title,
        description: description,
        createdAt: createdAt,
        targetDate: targetDate,
        priority: priority,
        status: status,
        answeredOn: answeredOn,
        answerNote: answerNote,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        if (description != null) 'description': description,
        'createdAt': createdAt,
        if (targetDate != null) 'targetDate': targetDate,
        'priority': priority.toJson(),
        'status': status.toJson(),
        if (answeredOn != null) 'answeredOn': answeredOn,
        if (answerNote != null) 'answerNote': answerNote,
        if (legacyIsArchived != null) 'isArchived': legacyIsArchived,
      };

  static Intention fromJson(Map<String, dynamic> j) => Intention(
        id: j['id'] as String,
        title: j['title'] as String,
        description: j['description'] as String?,
        createdAt: j['createdAt'] as String,
        targetDate: j['targetDate'] as String?,
        priority: Priority.fromJson(j['priority'] as String),
        status: IntentionStatus.fromJson(j['status'] as String? ?? 'active'),
        answeredOn: j['answeredOn'] as String?,
        answerNote: j['answerNote'] as String?,
        legacyIsArchived: j['isArchived'] as bool?,
      );
}

import 'package:hive_ce/hive.dart';

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

  @HiveField(6)
  final bool isArchived;

  const Intention({
    required this.id,
    required this.title,
    this.description,
    required this.createdAt,
    this.targetDate,
    required this.priority,
    required this.isArchived,
  });

  Intention copyWith({
    String? id,
    String? title,
    String? description,
    String? createdAt,
    String? targetDate,
    Priority? priority,
    bool? isArchived,
  }) =>
      Intention(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        createdAt: createdAt ?? this.createdAt,
        targetDate: targetDate ?? this.targetDate,
        priority: priority ?? this.priority,
        isArchived: isArchived ?? this.isArchived,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        if (description != null) 'description': description,
        'createdAt': createdAt,
        if (targetDate != null) 'targetDate': targetDate,
        'priority': priority.toJson(),
        'isArchived': isArchived,
      };

  static Intention fromJson(Map<String, dynamic> j) => Intention(
        id: j['id'] as String,
        title: j['title'] as String,
        description: j['description'] as String?,
        createdAt: j['createdAt'] as String,
        targetDate: j['targetDate'] as String?,
        priority: Priority.fromJson(j['priority'] as String),
        isArchived: (j['isArchived'] as bool?) ?? false,
      );
}

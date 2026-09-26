import 'package:hive_ce/hive.dart';

import 'activity_category.dart';

part 'activity.g.dart';

@HiveType(typeId: 5)
class Activity {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  /// Lucide icon name, kept as a string so the same data file works in React
  /// and Flutter (`lucide_icons_flutter` resolves it).
  @HiveField(2)
  final String icon;

  @HiveField(3)
  final ActivityCategory category;

  const Activity({
    required this.id,
    required this.name,
    required this.icon,
    required this.category,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'icon': icon,
        'category': category.toJson(),
      };

  static Activity fromJson(Map<String, dynamic> j) => Activity(
        id: j['id'] as String,
        name: j['name'] as String,
        icon: j['icon'] as String,
        category: ActivityCategory.fromJson(j['category'] as String),
      );
}

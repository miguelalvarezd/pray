import 'package:hive_ce/hive.dart';

part 'activity_category.g.dart';

@HiveType(typeId: 1)
enum ActivityCategory {
  @HiveField(0)
  sacramental,
  @HiveField(1)
  devotional,
  @HiveField(2)
  service,
  @HiveField(3)
  spiritual;

  String toJson() => name;

  static ActivityCategory fromJson(String s) => ActivityCategory.values
      .firstWhere((c) => c.name == s, orElse: () => ActivityCategory.devotional);
}

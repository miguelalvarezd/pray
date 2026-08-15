import 'package:hive_ce/hive.dart';

part 'priority.g.dart';

@HiveType(typeId: 0)
enum Priority {
  @HiveField(0)
  low,
  @HiveField(1)
  medium,
  @HiveField(2)
  high;

  String toJson() => name;

  static Priority fromJson(String s) =>
      Priority.values.firstWhere((p) => p.name == s, orElse: () => Priority.medium);
}

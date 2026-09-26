import 'package:hive_ce/hive.dart';

part 'intention_status.g.dart';

/// Where an Intention stands: prayed for (active), or no longer prayed for
/// because it was Archived.
@HiveType(typeId: 6)
enum IntentionStatus {
  @HiveField(0)
  active,
  @HiveField(1)
  archived;

  String toJson() => name;

  static IntentionStatus fromJson(String s) => IntentionStatus.values
      .firstWhere((v) => v.name == s, orElse: () => IntentionStatus.active);
}

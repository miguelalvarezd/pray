/// Transforms backup data from one schema version to the next. Step `n` in
/// a chain (0-based) migrates data at version `n` to version `n + 1`.
typedef MigrationStep = Map<String, dynamic> Function(Map<String, dynamic> data);

/// The production migration chain. Add one step per schema change; the
/// schema version is always the length of this list.
const List<MigrationStep> kMigrationSteps = [
  identityStep,
  intentionStatusStep,
  answeredIntentionsStep,
];

/// Schema version for exported backups and for data stored on the device.
/// Version 1 matches `SCHEMA_VERSION` in `src/types.ts`.
final int kSchemaVersion = kMigrationSteps.length;

/// v0 → v1: the unversioned React shape is already a subset of v1.
Map<String, dynamic> identityStep(Map<String, dynamic> data) => data;

/// v1 → v2: the `isArchived` flag becomes an Intention `status`.
Map<String, dynamic> intentionStatusStep(Map<String, dynamic> data) =>
    _mapIntentions(data, (i) {
      final archived = i.remove('isArchived');
      if (archived is bool) i['status'] = archived ? 'archived' : 'active';
      return i;
    });

/// v2 → v3: adds the Answered status with its Day and note. Nothing to
/// transform; the version bump keeps older apps from misreading Answered
/// Intentions as active.
Map<String, dynamic> answeredIntentionsStep(Map<String, dynamic> data) => data;

Map<String, dynamic> _mapIntentions(
  Map<String, dynamic> data,
  Map<String, dynamic> Function(Map<String, dynamic>) f,
) {
  final list = data['prayer-intentions'];
  if (list is! List) return data;
  return {
    ...data,
    'prayer-intentions': [
      for (final raw in list) f(Map<String, dynamic>.from(raw as Map)),
    ],
  };
}

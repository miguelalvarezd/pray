/// Transforms backup data from one schema version to the next. Step `n` in
/// a chain (0-based) migrates data at version `n` to version `n + 1`.
typedef MigrationStep = Map<String, dynamic> Function(Map<String, dynamic> data);

/// v0 → v1: the unversioned React shape is already a subset of v1.
Map<String, dynamic> identityStep(Map<String, dynamic> data) => data;

/// The production migration chain. Add one step per schema change; the
/// schema version is always the length of this list.
const List<MigrationStep> kMigrationSteps = [identityStep];

/// Schema version for exported backups and for data stored on the device.
/// Version 1 matches `SCHEMA_VERSION` in `src/types.ts`.
final int kSchemaVersion = kMigrationSteps.length;

/// React `localStorage` keys that participate in backup. Matches
/// `STORAGE_KEYS` in `src/lib/migrations.ts` byte-for-byte.
const List<String> kStorageKeys = [
  'prayer-intentions',
  'prayer-novenas',
  'prayer-logs',
  'prayer-date-override',
];

/// Versioned export wrapper. Field names mirror the TS `BackupEnvelope`.
class BackupEnvelope {
  final int version;
  final String exportedAt;
  final Map<String, dynamic> data;

  const BackupEnvelope({
    required this.version,
    required this.exportedAt,
    required this.data,
  });

  Map<String, dynamic> toJson() => {
        'version': version,
        'exportedAt': exportedAt,
        'data': data,
      };
}

sealed class ImportResult {
  const ImportResult();
}

class ImportOk extends ImportResult {
  final Map<String, dynamic> data;
  final int version;
  const ImportOk(this.data, this.version);
}

class ImportFail extends ImportResult {
  final String error;
  const ImportFail(this.error);
}

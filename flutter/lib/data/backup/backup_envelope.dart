/// Schema version for exported backups. Matches `SCHEMA_VERSION` in
/// `src/types.ts` so React-exported JSON imports cleanly.
const int kSchemaVersion = 1;

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

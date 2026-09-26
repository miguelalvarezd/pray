import '../boxes.dart';
import '../models/daily_log.dart';
import '../models/intention.dart';
import '../models/novena.dart';
import 'backup_envelope.dart';

/// Round-trips the Hive state through the versioned backup envelope, and
/// upgrades data stored on the device. Both backup import and the on-device
/// upgrade run through the same chain of [MigrationStep]s.
class BackupService {
  final AppBoxes boxes;
  final List<MigrationStep> steps;
  const BackupService(this.boxes, {this.steps = kMigrationSteps});

  int get _currentVersion => steps.length;

  /// Version of the data currently stored on the device, or `null` if it
  /// has never been recorded (a fresh install, or data from before versioning).
  int? get storedDataVersion =>
      boxes.settings.get(SettingsKeys.dataVersion) as int?;

  /// Reads all four backup-eligible storage keys out of Hive and wraps them
  /// in the versioned envelope ready for `jsonEncode`.
  BackupEnvelope buildExport({DateTime? now}) {
    return BackupEnvelope(
      version: _currentVersion,
      exportedAt: (now ?? DateTime.now().toUtc()).toIso8601String(),
      data: _dumpStoredData(),
    );
  }

  /// Brings data stored on the device up to the current schema version by
  /// running it through the migration chain, as if it were imported. Call
  /// once at startup, after the boxes are open.
  Future<void> upgradeStoredData() async {
    final stored = storedDataVersion ?? (_isEmpty ? _currentVersion : 1);
    if (stored < _currentVersion) {
      final migrated = _runSteps(_dumpStoredData(), stored);
      await applyImport(migrated);
    }
    if (stored <= _currentVersion) {
      await boxes.settings.put(SettingsKeys.dataVersion, _currentVersion);
    }
  }

  bool get _isEmpty =>
      boxes.intentions.isEmpty && boxes.novenas.isEmpty && boxes.logs.isEmpty;

  Map<String, dynamic> _dumpStoredData() {
    final data = <String, dynamic>{};

    final intentions = boxes.intentions.values.toList();
    if (intentions.isNotEmpty) {
      data['prayer-intentions'] = intentions.map((i) => i.toJson()).toList();
    }

    final novenas = boxes.novenas.values.toList();
    if (novenas.isNotEmpty) {
      data['prayer-novenas'] = novenas.map((n) => n.toJson()).toList();
    }

    final logs = <String, dynamic>{};
    for (final key in boxes.logs.keys) {
      final log = boxes.logs.get(key);
      if (log != null) logs[key as String] = log.toJson();
    }
    if (logs.isNotEmpty) {
      data['prayer-logs'] = logs;
    }

    final dateOverride = boxes.settings.get(SettingsKeys.dateOverride);
    if (dateOverride != null) {
      data['prayer-date-override'] = dateOverride;
    }
    return data;
  }

  /// Validates a parsed JSON blob and normalizes legacy (unversioned) exports
  /// into the current schema shape. Mirrors `parseBackup` in
  /// `src/lib/migrations.ts`.
  ImportResult parseBackup(dynamic raw) {
    if (raw is! Map<String, dynamic>) {
      return const ImportFail('Backup file is not a valid JSON object.');
    }

    // Versioned envelope path.
    final version = raw['version'];
    final data = raw['data'];
    if (version is num && data is Map<String, dynamic>) {
      return _migrate(data, version.toInt());
    }

    // Legacy path: flat object of storage keys.
    final hasAnyKnownKey = kStorageKeys.any(raw.containsKey);
    if (!hasAnyKnownKey) {
      return const ImportFail(
        'Backup file does not contain any recognized prayer data.',
      );
    }
    return _migrate(raw, 0);
  }

  ImportResult _migrate(Map<String, dynamic> data, int fromVersion) {
    if (fromVersion > _currentVersion) {
      return ImportFail(
        'Backup is from a newer version (v$fromVersion) than this app supports (v$_currentVersion).',
      );
    }
    return ImportOk(_runSteps(data, fromVersion), _currentVersion);
  }

  Map<String, dynamic> _runSteps(Map<String, dynamic> data, int fromVersion) {
    var out = data;
    for (var v = fromVersion; v < _currentVersion; v++) {
      out = steps[v](out);
    }
    return out;
  }

  /// Writes a migrated backup payload into Hive. Only keys in [kStorageKeys]
  /// are applied so a crafted file can't pollute storage.
  Future<void> applyImport(Map<String, dynamic> data) async {
    if (data.containsKey('prayer-intentions')) {
      await boxes.intentions.clear();
      final list = (data['prayer-intentions'] as List).cast<Map>();
      for (final raw in list) {
        final json = Map<String, dynamic>.from(raw);
        final i = Intention.fromJson(json);
        await boxes.intentions.put(i.id, i);
      }
    }

    if (data.containsKey('prayer-novenas')) {
      await boxes.novenas.clear();
      final list = (data['prayer-novenas'] as List).cast<Map>();
      for (final raw in list) {
        final json = Map<String, dynamic>.from(raw);
        final n = Novena.fromJson(json);
        await boxes.novenas.put(n.id, n);
      }
    }

    if (data.containsKey('prayer-logs')) {
      await boxes.logs.clear();
      final logs = (data['prayer-logs'] as Map).cast<String, dynamic>();
      for (final entry in logs.entries) {
        final json = Map<String, dynamic>.from(entry.value as Map);
        // Tolerate legacy logs that omit the date field (use the map key).
        json.putIfAbsent('date', () => entry.key);
        final log = DailyLog.fromJson(json);
        await boxes.logs.put(entry.key, log);
      }
    }

    if (data.containsKey('prayer-date-override')) {
      final value = data['prayer-date-override'];
      if (value == null) {
        await boxes.settings.delete(SettingsKeys.dateOverride);
      } else {
        await boxes.settings.put(SettingsKeys.dateOverride, value);
      }
    }
  }
}

import 'dart:typed_data';

import 'package:hive_ce_flutter/adapters.dart';

import '../hive_registrar.g.dart';
import 'models/daily_log.dart';
import 'models/intention.dart';
import 'models/novena.dart';

/// Hive box names. The first three match the React app's `localStorage` keys
/// 1:1 so backup JSON round-trips. `settings` is internal-only.
class BoxNames {
  static const intentions = 'prayer-intentions';
  static const novenas = 'prayer-novenas';
  static const logs = 'prayer-logs';
  static const settings = 'settings';

}

/// Settings keys (stored in [BoxNames.settings]).
class SettingsKeys {
  static const theme = 'prayer-tracker-theme';
  static const dateOverride = 'prayer-date-override';

  /// Schema version of the data stored on the device (see `BackupService`).
  static const dataVersion = 'data-version';
  // Mass guide
  static const massLang = 'mass-lang';
  static const massSecondaryLang = 'mass-secondary-lang';
  static const massPageIndex = 'mass-page-index';
  static const massPageDate = 'mass-page-date';
}

class AppBoxes {
  final Box<Intention> intentions;
  final Box<Novena> novenas;
  final Box<DailyLog> logs;
  final Box settings;

  const AppBoxes({
    required this.intentions,
    required this.novenas,
    required this.logs,
    required this.settings,
  });
}

/// Opens all production boxes. Call once at app startup before `runApp`.
Future<AppBoxes> openAppBoxes() async {
  await Hive.initFlutter();
  Hive.registerAdapters();
  // Caches of the remote liturgy sources the app no longer uses (ADR-0003).
  for (final stale in ['litcal-cache', 'lectio-cache']) {
    await Hive.deleteBoxFromDisk(stale);
  }
  return _openBoxes();
}

/// Test helper: open boxes against an explicit on-disk path. Use `Hive.init`
/// (not `Hive.initFlutter`) before calling. With [inMemory], boxes live in
/// memory only, so reads and writes complete without real IO (needed inside
/// widget tests, which run on fake async).
Future<AppBoxes> openTestBoxes({bool inMemory = false}) async {
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapters();
  }
  return _openBoxes(bytes: inMemory ? Uint8List(0) : null);
}

Future<AppBoxes> _openBoxes({Uint8List? bytes}) async {
  final intentions = await Hive.openBox<Intention>(BoxNames.intentions, bytes: bytes);
  final novenas = await Hive.openBox<Novena>(BoxNames.novenas, bytes: bytes);
  final logs = await Hive.openBox<DailyLog>(BoxNames.logs, bytes: bytes);
  final settings = await Hive.openBox(BoxNames.settings, bytes: bytes);
  return AppBoxes(
    intentions: intentions,
    novenas: novenas,
    logs: logs,
    settings: settings,
  );
}

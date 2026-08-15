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

  /// Per-year liturgical calendar JSON cache (`litcal-cache-<year>` mirrors the
  /// React key shape). Stored as `Box<String>` keyed by year as a string.
  static const litcalCache = 'litcal-cache';

  /// Per-day daily-readings cache. `Box<String>` keyed by `YYYY-MM-DD`. Each
  /// value is a JSON envelope `{cachedAt, data}` so we can apply a TTL.
  static const lectioCache = 'lectio-cache';
}

/// Settings keys (stored in [BoxNames.settings]).
class SettingsKeys {
  static const theme = 'prayer-tracker-theme';
  static const dateOverride = 'prayer-date-override';
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
  final Box<String> litcalCache;
  final Box<String> lectioCache;

  const AppBoxes({
    required this.intentions,
    required this.novenas,
    required this.logs,
    required this.settings,
    required this.litcalCache,
    required this.lectioCache,
  });
}

/// Opens all production boxes. Call once at app startup before `runApp`.
Future<AppBoxes> openAppBoxes() async {
  await Hive.initFlutter();
  Hive.registerAdapters();
  return _openBoxes();
}

/// Test helper: open boxes against an explicit on-disk path. Use `Hive.init`
/// (not `Hive.initFlutter`) before calling.
Future<AppBoxes> openTestBoxes() async {
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapters();
  }
  return _openBoxes();
}

Future<AppBoxes> _openBoxes() async {
  final intentions = await Hive.openBox<Intention>(BoxNames.intentions);
  final novenas = await Hive.openBox<Novena>(BoxNames.novenas);
  final logs = await Hive.openBox<DailyLog>(BoxNames.logs);
  final settings = await Hive.openBox(BoxNames.settings);
  final litcalCache = await Hive.openBox<String>(BoxNames.litcalCache);
  final lectioCache = await Hive.openBox<String>(BoxNames.lectioCache);
  return AppBoxes(
    intentions: intentions,
    novenas: novenas,
    logs: logs,
    settings: settings,
    litcalCache: litcalCache,
    lectioCache: lectioCache,
  );
}

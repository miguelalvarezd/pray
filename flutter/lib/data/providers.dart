import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';

import 'boxes.dart';
import 'models/daily_log.dart';
import 'models/intention.dart';
import 'models/novena.dart';

/// The set of opened Hive boxes. Overridden at startup with the real
/// [AppBoxes] from `openAppBoxes()`.
final appBoxesProvider = Provider<AppBoxes>((ref) {
  throw UnimplementedError(
    'appBoxesProvider must be overridden with openAppBoxes() before use.',
  );
});

final intentionsBoxProvider = Provider<Box<Intention>>(
  (ref) => ref.watch(appBoxesProvider).intentions,
);
final novenasBoxProvider = Provider<Box<Novena>>(
  (ref) => ref.watch(appBoxesProvider).novenas,
);
final logsBoxProvider = Provider<Box<DailyLog>>(
  (ref) => ref.watch(appBoxesProvider).logs,
);
final settingsBoxProvider = Provider<Box>(
  (ref) => ref.watch(appBoxesProvider).settings,
);
final litcalCacheBoxProvider = Provider<Box<String>>(
  (ref) => ref.watch(appBoxesProvider).litcalCache,
);
final lectioCacheBoxProvider = Provider<Box<String>>(
  (ref) => ref.watch(appBoxesProvider).lectioCache,
);

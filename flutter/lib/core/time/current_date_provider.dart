import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/boxes.dart';
import '../../data/providers.dart';
import 'logical_day.dart';

/// The user's logical "today" — 4 AM-shifted, with optional dev override
/// from the settings box. Read with `ref.watch(currentDateProvider)`.
///
/// This rebuilds whenever the override changes; it does NOT auto-rebuild as
/// wall-clock time advances. The Today screen is short-lived enough that this
/// is fine; if a screen needs minute-level updates it can use a Ticker.
final currentDateProvider = Provider<DateTime>((ref) {
  final settings = ref.watch(settingsBoxProvider);
  final override = settings.get(SettingsKeys.dateOverride) as String?;
  return logicalToday(override: override);
});

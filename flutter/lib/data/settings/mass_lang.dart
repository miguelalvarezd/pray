import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/mass/types.dart';
import '../boxes.dart';
import '../providers.dart';

/// The Mass Guide's language, which also sets the language of the liturgy
/// shown elsewhere (Celebration names, Reading References). Invalidate after
/// changing the setting so listeners update.
final massLangProvider = Provider<Lang>((ref) {
  final name = ref.watch(settingsBoxProvider).get(SettingsKeys.massLang) as String?;
  return Lang.values.where((l) => l.name == name).firstOrNull ?? Lang.en;
});

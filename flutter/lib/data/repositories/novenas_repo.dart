import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/novena.dart';
import '../providers.dart';
import 'logs_repo.dart';

class NovenasNotifier extends Notifier<List<Novena>> {
  @override
  List<Novena> build() {
    final box = ref.watch(novenasBoxProvider);
    return box.values.toList();
  }

  Future<void> add(Novena n) async {
    await ref.read(novenasBoxProvider).put(n.id, n);
    ref.invalidateSelf();
  }

  /// Deletes the Novena and removes it from every past Daily Log.
  Future<void> delete(String id) async {
    await ref.read(novenasBoxProvider).delete(id);
    await ref.read(logsProvider.notifier).forgetNovena(id);
    ref.invalidateSelf();
  }
}

final novenasProvider =
    NotifierProvider<NovenasNotifier, List<Novena>>(NovenasNotifier.new);

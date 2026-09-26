import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/intention.dart';
import '../models/novena.dart';
import '../models/priority.dart';
import '../providers.dart';
import 'intentions_repo.dart';
import 'logs_repo.dart';

const _uuid = Uuid();

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

  /// Starts [novena]. With a non-empty [newPetition], a new Intention with
  /// that title is created and the Novena is offered for it; otherwise the
  /// Novena keeps whatever Intention (or none) it was given.
  Future<void> start(Novena novena, {String? newPetition}) async {
    final petition = newPetition?.trim() ?? '';
    var toStart = novena;
    if (petition.isNotEmpty) {
      final intention = Intention(
        id: _uuid.v4(),
        title: petition,
        createdAt: novena.createdAt,
        priority: Priority.medium,
      );
      await ref.read(intentionsProvider.notifier).add(intention);
      toStart = novena.offeredFor(intention.id);
    }
    await add(toStart);
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

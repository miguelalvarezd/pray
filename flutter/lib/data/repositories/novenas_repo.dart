import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../domain/intentions_logic.dart';
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

  /// Starts [novena]. If it isn't already offered for an Intention, the
  /// typed [intentionText] decides: text equal to an active Intention's title
  /// (ignoring case and surrounding spaces) links that Intention; any other
  /// non-empty text creates a new Intention; empty text links none.
  Future<void> start(Novena novena, {String? intentionText}) async {
    final text = intentionText?.trim() ?? '';
    var toStart = novena;
    if (novena.intentionId == null && text.isNotEmpty) {
      final existing = findActiveIntentionTitled(text, ref.read(intentionsProvider));
      final String intentionId;
      if (existing != null) {
        intentionId = existing.id;
      } else {
        final created = Intention(
          id: _uuid.v4(),
          title: text,
          createdAt: novena.createdAt,
          priority: Priority.medium,
        );
        await ref.read(intentionsProvider.notifier).add(created);
        intentionId = created.id;
      }
      toStart = novena.offeredFor(intentionId);
    }
    await add(toStart);
  }

  /// Unlinks every Novena offered for a deleted Intention. The Novenas are
  /// kept, offered for no Intention.
  Future<void> unlinkIntention(String intentionId) async {
    final box = ref.read(novenasBoxProvider);
    for (final n in box.values.toList()) {
      if (n.intentionId == intentionId) await box.put(n.id, n.offeredFor(null));
    }
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

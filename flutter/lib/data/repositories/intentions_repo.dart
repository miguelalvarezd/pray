import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/intention.dart';
import '../models/intention_status.dart';
import '../providers.dart';

class IntentionsNotifier extends Notifier<List<Intention>> {
  @override
  List<Intention> build() {
    final box = ref.watch(intentionsBoxProvider);
    return box.values.toList();
  }

  Future<void> add(Intention i) async {
    await ref.read(intentionsBoxProvider).put(i.id, i);
    ref.invalidateSelf();
  }

  Future<void> update(Intention i) async {
    await ref.read(intentionsBoxProvider).put(i.id, i);
    ref.invalidateSelf();
  }

  Future<void> archive(String id) => _setStatus(id, IntentionStatus.archived);

  Future<void> restore(String id) => _setStatus(id, IntentionStatus.active);

  Future<void> _setStatus(String id, IntentionStatus status) async {
    final box = ref.read(intentionsBoxProvider);
    final current = box.get(id);
    if (current == null) return;
    await box.put(id, current.copyWith(status: status));
    ref.invalidateSelf();
  }

  Future<void> delete(String id) async {
    await ref.read(intentionsBoxProvider).delete(id);
    ref.invalidateSelf();
  }
}

final intentionsProvider =
    NotifierProvider<IntentionsNotifier, List<Intention>>(IntentionsNotifier.new);

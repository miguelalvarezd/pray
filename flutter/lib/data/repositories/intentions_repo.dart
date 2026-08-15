import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/intention.dart';
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

  Future<void> delete(String id) async {
    await ref.read(intentionsBoxProvider).delete(id);
    ref.invalidateSelf();
  }
}

final intentionsProvider =
    NotifierProvider<IntentionsNotifier, List<Intention>>(IntentionsNotifier.new);

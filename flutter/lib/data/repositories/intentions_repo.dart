import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/intention.dart';
import '../models/intention_status.dart';
import '../providers.dart';
import 'logs_repo.dart';
import 'novenas_repo.dart';

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

  /// Marks the Intention Answered on [day] (`YYYY-MM-DD`), with an optional
  /// [note] on how it was answered.
  Future<void> answer(String id, {required String day, String? note}) =>
      _replace(id, (i) => i.withStatus(
            IntentionStatus.answered,
            answeredOn: day,
            answerNote: (note == null || note.trim().isEmpty) ? null : note.trim(),
          ));

  Future<void> archive(String id) =>
      _replace(id, (i) => i.withStatus(IntentionStatus.archived));

  /// Makes an Answered or Archived Intention active again. Any answered Day
  /// and note are cleared.
  Future<void> restore(String id) =>
      _replace(id, (i) => i.withStatus(IntentionStatus.active));

  /// Keeps praying for an Intention whose Target Date has passed: sets
  /// [newTargetDate] (`YYYY-MM-DD`), or clears the Target Date if none.
  Future<void> keepPraying(String id, {String? newTargetDate}) =>
      _replace(id, (i) => i.withTargetDate(newTargetDate));

  Future<void> _replace(String id, Intention Function(Intention) change) async {
    final box = ref.read(intentionsBoxProvider);
    final current = box.get(id);
    if (current == null) return;
    await box.put(id, change(current));
    ref.invalidateSelf();
  }

  /// Deletes the Intention, removes it from every past Daily Log, and
  /// unlinks any Novenas offered for it.
  Future<void> delete(String id) async {
    await ref.read(intentionsBoxProvider).delete(id);
    await ref.read(logsProvider.notifier).forgetIntention(id);
    await ref.read(novenasProvider.notifier).unlinkIntention(id);
    ref.invalidateSelf();
  }
}

final intentionsProvider =
    NotifierProvider<IntentionsNotifier, List<Intention>>(IntentionsNotifier.new);

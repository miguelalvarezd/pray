import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/time/current_date_provider.dart';
import '../../../core/time/logical_day.dart';
import '../../../data/models/intention.dart';
import '../../../data/repositories/intentions_repo.dart';

/// Asks for the Day an Intention was Answered (today's Day by default) and an
/// optional note, then marks it Answered. Resolves to `true` if it was.
Future<bool> showAnswerIntentionSheet(
  BuildContext context,
  Intention intention,
) async {
  final answered = await showModalBottomSheet<bool>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => _AnswerIntentionSheet(intention: intention),
  );
  return answered ?? false;
}

class _AnswerIntentionSheet extends ConsumerStatefulWidget {
  const _AnswerIntentionSheet({required this.intention});
  final Intention intention;

  @override
  ConsumerState<_AnswerIntentionSheet> createState() =>
      _AnswerIntentionSheetState();
}

class _AnswerIntentionSheetState extends ConsumerState<_AnswerIntentionSheet> {
  final _note = TextEditingController();
  late DateTime _day = ref.read(currentDateProvider);

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickDay() async {
    final today = ref.read(currentDateProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: _day,
      firstDate: DateTime(today.year - 5),
      lastDate: today,
    );
    if (picked != null) setState(() => _day = picked);
  }

  Future<void> _submit() async {
    HapticFeedback.mediumImpact();
    await ref.read(intentionsProvider.notifier).answer(
          widget.intention.id,
          day: formatLogDate(_day),
          note: _note.text,
        );
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 8, 20, 20 + viewInsets),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Prayer answered',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              widget.intention.title,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _pickDay,
              icon: const Icon(Icons.calendar_today_outlined, size: 16),
              label: Text('Answered ${DateFormat('MMM d, yyyy').format(_day)}'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _note,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'How was it answered? (optional)',
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _submit,
                  child: const Text('Mark answered'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

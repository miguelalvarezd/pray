import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../core/time/current_date_provider.dart';
import '../../../data/models/intention.dart';
import '../../../data/models/priority.dart';
import '../../../data/repositories/intentions_repo.dart';

const _uuid = Uuid();

Future<void> showAddIntentionSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => const _AddIntentionSheet(),
  );
}

class _AddIntentionSheet extends ConsumerStatefulWidget {
  const _AddIntentionSheet();

  @override
  ConsumerState<_AddIntentionSheet> createState() => _AddIntentionSheetState();
}

class _AddIntentionSheetState extends ConsumerState<_AddIntentionSheet> {
  final _title = TextEditingController();
  final _desc = TextEditingController();
  Priority _priority = Priority.medium;
  DateTime? _targetDate;
  GoRouter? _router;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final router = GoRouter.of(context);
    if (_router != router) {
      _router?.routerDelegate.removeListener(_popOnNavigation);
      router.routerDelegate.addListener(_popOnNavigation);
      _router = router;
    }
  }

  void _popOnNavigation() {
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop();
      });
    }
  }

  @override
  void dispose() {
    _router?.routerDelegate.removeListener(_popOnNavigation);
    _title.dispose();
    _desc.dispose();
    super.dispose();
  }

  Future<void> _pickTargetDate() async {
    final now = ref.read(currentDateProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) setState(() => _targetDate = picked);
  }

  Future<void> _submit() async {
    final title = _title.text.trim();
    if (title.isEmpty) return;
    HapticFeedback.mediumImpact();
    final now = ref.read(currentDateProvider);
    final intention = Intention(
      id: _uuid.v4(),
      title: title,
      description: _desc.text.trim().isEmpty ? null : _desc.text.trim(),
      createdAt: now.toUtc().toIso8601String(),
      targetDate: _targetDate == null
          ? null
          : DateFormat('yyyy-MM-dd').format(_targetDate!),
      priority: _priority,
      isArchived: false,
    );
    await ref.read(intentionsProvider.notifier).add(intention);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    final canSubmit = _title.text.trim().isNotEmpty;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 8, 20, 20 + viewInsets),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('New Intention',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(
              controller: _title,
              autofocus: true,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'What are you praying for?',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _desc,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Additional details (optional)',
              ),
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OutlinedButton.icon(
                  onPressed: _pickTargetDate,
                  icon: const Icon(Icons.calendar_today_outlined, size: 16),
                  label: Text(
                    _targetDate == null
                        ? 'Target date'
                        : DateFormat('MMM d, yyyy').format(_targetDate!),
                  ),
                ),
                const SizedBox(height: 12),
                SegmentedButton<Priority>(
                  segments: Priority.values
                      .map((p) => ButtonSegment<Priority>(
                            value: p,
                            label: Text(
                                p.name[0].toUpperCase() + p.name.substring(1)),
                          ))
                      .toList(),
                  selected: {_priority},
                  onSelectionChanged: (s) =>
                      setState(() => _priority = s.first),
                  showSelectedIcon: false,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: canSubmit ? _submit : null,
                  child: const Text('Add Intention'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

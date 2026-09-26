import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../core/time/current_date_provider.dart';
import '../../../data/models/intention_status.dart';
import '../../../data/models/novena.dart';
import '../../../data/repositories/intentions_repo.dart';
import '../../../data/repositories/novenas_repo.dart';
import '../../../domain/novena_library.dart';

const _uuid = Uuid();

enum _Source { library, custom }

/// Dropdown value for "offer this Novena for a new petition".
const _newPetition = '__new__';

Future<void> showAddNovenaSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => const _AddNovenaSheet(),
  );
}

class _AddNovenaSheet extends ConsumerStatefulWidget {
  const _AddNovenaSheet();

  @override
  ConsumerState<_AddNovenaSheet> createState() => _AddNovenaSheetState();
}

class _AddNovenaSheetState extends ConsumerState<_AddNovenaSheet> {
  _Source _source = _Source.library;
  String? _templateId;
  final _saint = TextEditingController();
  final _petition = TextEditingController();

  /// What the Novena is offered for: `null` for no Intention, [_newPetition]
  /// for a new one typed below, or the id of an active Intention.
  String? _offeredFor;
  DateTime? _startDate;
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
    _saint.dispose();
    _petition.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final now = ref.read(currentDateProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  /// The petition text for a new Intention, falling back to the template's
  /// suggested intention when left empty.
  String get _petitionText {
    final typed = _petition.text.trim();
    if (typed.isNotEmpty) return typed;
    final tpl = _templateId == null ? null : findTemplate(_templateId!);
    return tpl?.suggestedIntention ?? '';
  }

  bool get _canSubmit {
    final hasSource = _source == _Source.library
        ? _templateId != null
        : _saint.text.trim().isNotEmpty;
    final hasPetition = _offeredFor != _newPetition || _petitionText.isNotEmpty;
    return hasSource && hasPetition;
  }

  Future<void> _submit() async {
    final now = ref.read(currentDateProvider);
    final start = _startDate ?? now;
    final startStr = DateFormat('yyyy-MM-dd').format(start);
    final createdAt = now.toUtc().toIso8601String();

    final existingIntentionId =
        _offeredFor == _newPetition ? null : _offeredFor;
    final Novena novena;
    if (_source == _Source.library) {
      final tpl = findTemplate(_templateId!);
      if (tpl == null) return;
      novena = Novena(
        id: _uuid.v4(),
        title: tpl.title,
        intentionId: existingIntentionId,
        startDate: startStr,
        createdAt: createdAt,
        prayer: tpl.prayer,
        templateId: tpl.id,
      );
    } else {
      novena = Novena(
        id: _uuid.v4(),
        title: _saint.text.trim(),
        intentionId: existingIntentionId,
        startDate: startStr,
        createdAt: createdAt,
      );
    }

    await ref.read(novenasProvider.notifier).start(
          novena,
          newPetition: _offeredFor == _newPetition ? _petitionText : null,
        );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    final selectedTemplate = _templateId == null ? null : findTemplate(_templateId!);
    final petitionHint = selectedTemplate != null
        ? 'Your petition (default: ${selectedTemplate.suggestedIntention})'
        : 'What are you asking for?';
    final activeIntentions = ref
        .watch(intentionsProvider)
        .where((i) => i.status == IntentionStatus.active)
        .toList();

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 8, 20, 20 + viewInsets),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('New Novena',
                      style: Theme.of(context).textTheme.titleLarge),
                ),
                Tooltip(
                  message:
                      'A 9-day prayer to a specific saint or for a specific intention.',
                  triggerMode: TooltipTriggerMode.tap,
                  showDuration: const Duration(seconds: 4),
                  preferBelow: true,
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: scheme.onSurface,
                  ),
                  child: Icon(Icons.info_outline,
                      size: 18, color: scheme.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SegmentedButton<_Source>(
              segments: const [
                ButtonSegment(
                  value: _Source.library,
                  icon: Icon(Icons.auto_awesome, size: 14),
                  label: Text('From Library'),
                ),
                ButtonSegment(
                  value: _Source.custom,
                  label: Text('Custom'),
                ),
              ],
              selected: {_source},
              onSelectionChanged: (s) => setState(() {
                _source = s.first;
                if (_source == _Source.custom) _templateId = null;
              }),
            ),
            const SizedBox(height: 16),
            if (_source == _Source.library)
              _LibraryPicker(
                selectedId: _templateId,
                onSelect: (id) => setState(() => _templateId = id),
              )
            else
              TextField(
                controller: _saint,
                onChanged: (_) => setState(() {}),
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Saint or Novena Name',
                ),
              ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              initialValue: _offeredFor,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Offered for'),
              items: [
                const DropdownMenuItem(value: null, child: Text('No intention')),
                for (final i in activeIntentions)
                  DropdownMenuItem(
                    value: i.id,
                    child: Text(i.title, overflow: TextOverflow.ellipsis),
                  ),
                const DropdownMenuItem(
                  value: _newPetition,
                  child: Text('New petition…'),
                ),
              ],
              onChanged: (v) => setState(() => _offeredFor = v),
            ),
            if (_offeredFor == _newPetition) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _petition,
                onChanged: (_) => setState(() {}),
                autofocus: true,
                minLines: 1,
                maxLines: 3,
                decoration: InputDecoration(hintText: petitionHint),
              ),
            ],
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _pickStartDate,
              icon: const Icon(Icons.calendar_today_outlined, size: 16),
              label: Text(
                _startDate == null
                    ? 'Start: today'
                    : 'Start: ${DateFormat('MMM d, yyyy').format(_startDate!)}',
              ),
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
                FilledButton.tonal(
                  onPressed: _canSubmit ? _submit : null,
                  child: const Text('Start Novena'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LibraryPicker extends StatefulWidget {
  const _LibraryPicker({required this.selectedId, required this.onSelect});
  final String? selectedId;
  final void Function(String id) onSelect;

  @override
  State<_LibraryPicker> createState() => _LibraryPickerState();
}

class _LibraryPickerState extends State<_LibraryPicker> {
  String? _expandedId;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 260),
      child: SingleChildScrollView(
        child: Column(
          children: [
            for (final t in kNovenaLibrary) ...[
              _LibraryRow(
                template: t,
                isSelected: widget.selectedId == t.id,
                isExpanded: _expandedId == t.id,
                onSelect: () => widget.onSelect(t.id),
                onToggleExpand: () => setState(
                    () => _expandedId = _expandedId == t.id ? null : t.id),
                scheme: scheme,
              ),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}

class _LibraryRow extends StatelessWidget {
  const _LibraryRow({
    required this.template,
    required this.isSelected,
    required this.isExpanded,
    required this.onSelect,
    required this.onToggleExpand,
    required this.scheme,
  });

  final NovenaTemplate template;
  final bool isSelected;
  final bool isExpanded;
  final VoidCallback onSelect;
  final VoidCallback onToggleExpand;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: isSelected
            ? scheme.tertiaryContainer.withValues(alpha: 0.4)
            : scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? scheme.tertiary : Colors.transparent,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onSelect,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: scheme.tertiaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.menu_book_outlined,
                        size: 18, color: scheme.tertiary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(template.title,
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 2),
                        Text(
                          template.patron.toUpperCase(),
                          style: TextStyle(
                            fontSize: 9,
                            letterSpacing: 1.4,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(template.description,
                            style: TextStyle(
                                fontSize: 12,
                                height: 1.35,
                                color: scheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: onToggleExpand,
                    icon: AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 180),
                      child: Icon(Icons.keyboard_arrow_down,
                          color: scheme.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 180),
            child: isExpanded
                ? Padding(
                    padding:
                        const EdgeInsets.fromLTRB(16, 0, 16, 14),
                    child: Text(
                      template.prayer,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.5,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

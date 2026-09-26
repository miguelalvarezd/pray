import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/icons.dart';
import '../../core/nav/scroll_notifier.dart' show scrollTriggersProvider;
import '../../core/widgets/expandable_fab.dart';
import '../../core/time/current_date_provider.dart';
import '../../core/time/logical_day.dart';
import '../../core/widgets/confirm_dialog.dart';
import '../../core/widgets/undo_snack_bar.dart';
import '../../data/models/intention.dart';
import '../../data/models/intention_status.dart';
import '../../data/models/novena.dart';
import '../../data/repositories/intentions_repo.dart';
import '../../data/repositories/logs_repo.dart';
import '../../data/repositories/novenas_repo.dart';
import '../../domain/intentions_logic.dart';
import '../../domain/novena_logic.dart';
import 'sheets/add_intention_sheet.dart';
import 'sheets/add_novena_sheet.dart';
import 'sheets/answer_intention_sheet.dart';
import 'widgets/intention_card.dart';
import 'widgets/novena_card.dart';

enum _View { intentions, novenas }

enum _KeepPrayingChoice { newDate, noDate }

class IntentionsScreen extends ConsumerStatefulWidget {
  const IntentionsScreen({super.key});

  @override
  ConsumerState<IntentionsScreen> createState() => _IntentionsScreenState();
}

class _IntentionsScreenState extends ConsumerState<IntentionsScreen> {
  _View _view = _View.intentions;

  /// Selected sub-tab: Active / Answered / Archived for Intentions, and
  /// Active / History for Novenas.
  int _subTab = 0;
  bool _fabOpen = false;
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!TickerMode.valuesOf(context).enabled && _fabOpen) {
      setState(() => _fabOpen = false);
    }
  }

  void _switchView(_View v) {
    setState(() {
      _view = v;
      _subTab = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      scrollTriggersProvider.select((m) => m[1] ?? 0),
      (_, _) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOutCubicEmphasized,
          );
        }
      },
    );
    final scheme = Theme.of(context).colorScheme;
    final now = ref.watch(currentDateProvider);

    final intentions = ref.watch(intentionsProvider);
    final novenas = ref.watch(novenasProvider);
    final logs = ref.watch(logsProvider);
    final prayedCounts = buildIntentionCountMap(logs, novenas: novenas);
    final intentionTitles = {for (final i in intentions) i.id: i.title};

    final activeIntentions = sortIntentions(
      intentions.where((i) => i.status == IntentionStatus.active),
      now,
    );
    final answeredIntentions = intentions
        .where((i) => i.status == IntentionStatus.answered)
        .toList()
      ..sort((a, b) => (b.answeredOn ?? '').compareTo(a.answeredOn ?? ''));
    final archivedIntentions =
        intentions.where((i) => i.status == IntentionStatus.archived).toList();

    final novenaStatuses = {
      for (final n in novenas) n.id: novenaStatus(n, logs, now),
    };
    bool isPast(Novena n) => switch (novenaStatuses[n.id]!) {
          NovenaCompleted() || NovenaIncomplete() => true,
          NovenaUpcoming() || NovenaInProgress() => false,
        };
    final activeNovenas = novenas.where((n) => !isPast(n)).toList();
    final historicalNovenas = novenas.where(isPast).toList();

    return Scaffold(
      floatingActionButton: ExpandableFab(
        isOpen: _fabOpen,
        onToggle: () => setState(() => _fabOpen = !_fabOpen),
        actions: [
          FabAction(
            heroTag: 'fab-novena',
            icon: lucideIconFor('BookHeart'),
            label: 'Novena',
            onPressed: () => showAddNovenaSheet(context),
          ),
          FabAction(
            heroTag: 'fab-intention',
            icon: Icons.favorite_outline,
            label: 'Intention',
            onPressed: () => showAddIntentionSheet(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: ListView(
              controller: _scrollController,

              cacheExtent: 300,
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 96),
              children: [
                _Header(scheme: scheme),
                const SizedBox(height: 24),
                _ViewTabs(
                  view: _view,
                  onChange: _switchView,
                  scheme: scheme,
                ),
                const SizedBox(height: 20),
                if (_view == _View.intentions) ...[
                  _SubTabs(
                    labels: [
                      'Active (${activeIntentions.length})',
                      'Answered (${answeredIntentions.length})',
                      'Archived (${archivedIntentions.length})',
                    ],
                    selected: _subTab,
                    onSelect: (v) => setState(() => _subTab = v),
                    scheme: scheme,
                  ),
                  const SizedBox(height: 16),
                  ..._buildIntentionList(
                    [activeIntentions, answeredIntentions, archivedIntentions][_subTab],
                    prayedCounts,
                    now,
                  ),
                ] else ...[
                  _SubTabs(
                    labels: [
                      'Active (${activeNovenas.length})',
                      'History (${historicalNovenas.length})',
                    ],
                    selected: _subTab,
                    onSelect: (v) => setState(() => _subTab = v),
                    scheme: scheme,
                  ),
                  const SizedBox(height: 16),
                  ..._buildNovenaList(
                    _subTab == 1 ? historicalNovenas : activeNovenas,
                    novenaStatuses,
                    intentionTitles,
                  ),
                ],
              ],
            ),
          ),
          Positioned.fill(
            child: FabScrim(
              visible: _fabOpen,
              onDismiss: () => setState(() => _fabOpen = false),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildIntentionList(
    List<Intention> intentions,
    Map<String, int> counts,
    DateTime now,
  ) {
    if (intentions.isEmpty) {
      return [
        _EmptyState(
          message: const [
            'No active intentions.',
            'No answered intentions yet.',
            'No archived intentions.',
          ][_subTab],
        ),
      ];
    }
    final widgets = <Widget>[];
    for (var i = 0; i < intentions.length; i++) {
      final it = intentions[i];
      widgets.add(IntentionCard(
        intention: it,
        urgency: calculateUrgency(it, now),
        prayedCount: counts[it.id] ?? 0,
        targetDatePassed: isTargetDatePassed(it, now),
        onKeepPraying: () => _keepPraying(it),
        onAnswer: () => _answer(it),
        onArchive: () => _changeStatus(it, archive: true),
        onRestore: () => _changeStatus(it, archive: false),
        onDelete: () => _confirmDeleteIntention(it),
      ));
      if (i < intentions.length - 1) widgets.add(const SizedBox(height: 12));
    }
    return widgets;
  }

  Future<void> _confirmDeleteIntention(Intention intention) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete this intention?',
      message:
          '"${intention.title}" and its record in your history will be removed. '
          'This can\'t be undone.\n\n'
          'To stop praying for it but keep its history, archive it instead.',
      confirmLabel: 'Delete',
    );
    if (confirmed) {
      await ref.read(intentionsProvider.notifier).delete(intention.id);
    }
  }

  Future<void> _confirmDeleteNovena(Novena novena) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete this novena?',
      message:
          '"${novena.title}" and its record in your history will be removed. This can\'t be undone.',
      confirmLabel: 'Delete',
    );
    if (confirmed) await ref.read(novenasProvider.notifier).delete(novena.id);
  }

  Future<void> _answer(Intention intention) async {
    final answered = await showAnswerIntentionSheet(context, intention);
    if (!answered || !mounted) return;
    _offerUndo('Marked answered', intention);
  }

  /// Keeps praying for [intention] after its Target Date, with a new Target
  /// Date or none.
  Future<void> _keepPraying(Intention intention) async {
    final choice = await showDialog<_KeepPrayingChoice>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keep praying'),
        content: const Text('Set a new target date, or keep praying without one?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(_KeepPrayingChoice.noDate),
            child: const Text('No target date'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(_KeepPrayingChoice.newDate),
            child: const Text('New date'),
          ),
        ],
      ),
    );
    if (choice == null || !mounted) return;

    String? newTargetDate;
    if (choice == _KeepPrayingChoice.newDate) {
      final today = ref.read(currentDateProvider);
      final picked = await showDatePicker(
        context: context,
        initialDate: today.add(const Duration(days: 7)),
        firstDate: today,
        lastDate: DateTime(today.year + 5),
      );
      if (picked == null) return;
      newTargetDate = formatLogDate(picked);
    }
    await ref
        .read(intentionsProvider.notifier)
        .keepPraying(intention.id, newTargetDate: newTargetDate);
  }

  /// Archives or restores [intention].
  Future<void> _changeStatus(Intention intention, {required bool archive}) async {
    final notifier = ref.read(intentionsProvider.notifier);
    if (archive) {
      await notifier.archive(intention.id);
    } else {
      await notifier.restore(intention.id);
    }
    if (!mounted) return;
    _offerUndo(archive ? 'Intention archived' : 'Intention restored', intention);
  }

  /// Shows an Undo that puts [before] back exactly as it was, including any
  /// answered Day and note.
  void _offerUndo(String message, Intention before) {
    showUndoSnackBar(
      context,
      message,
      onUndo: () => ref.read(intentionsProvider.notifier).update(before),
    );
  }

  List<Widget> _buildNovenaList(
    List<Novena> novenas,
    Map<String, NovenaStatus> statuses,
    Map<String, String> intentionTitles,
  ) {
    if (novenas.isEmpty) {
      return [
        _EmptyState(
          message: _subTab == 1 ? 'No past novenas.' : 'No active novenas.',
        ),
      ];
    }
    final widgets = <Widget>[];
    for (var i = 0; i < novenas.length; i++) {
      final n = novenas[i];
      widgets.add(NovenaCard(
        novena: n,
        intentionTitle: intentionTitles[n.intentionId],
        status: statuses[n.id]!,
        onDelete: () => _confirmDeleteNovena(n),
      ));
      if (i < novenas.length - 1) widgets.add(const SizedBox(height: 12));
    }
    return widgets;
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.scheme});
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ASK AND IT WILL BE GIVEN TO YOU',
          style: GoogleFonts.manrope(
            fontSize: 11,
            letterSpacing: 1.6,
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            style: GoogleFonts.newsreader(
              fontSize: 38,
              height: 1.05,
              color: scheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
            children: [
              const TextSpan(text: "Your Heart's\n"),
              TextSpan(
                text: 'Quiet Echoes',
                style: GoogleFonts.newsreader(
                  fontSize: 38,
                  fontStyle: FontStyle.italic,
                  color: scheme.tertiary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ViewTabs extends StatelessWidget {
  const _ViewTabs({
    required this.view,
    required this.onChange,
    required this.scheme,
  });
  final _View view;
  final void Function(_View) onChange;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _PillTab(
          label: 'Intentions',
          selected: view == _View.intentions,
          activeBg: scheme.secondaryContainer,
          activeFg: scheme.onSecondaryContainer,
          onTap: () => onChange(_View.intentions),
        ),
        const SizedBox(width: 8),
        _PillTab(
          label: 'Novenas',
          selected: view == _View.novenas,
          activeBg: scheme.tertiaryContainer,
          activeFg: scheme.onTertiaryContainer,
          onTap: () => onChange(_View.novenas),
        ),
      ],
    );
  }
}

class _SubTabs extends StatelessWidget {
  const _SubTabs({
    required this.labels,
    required this.selected,
    required this.onSelect,
    required this.scheme,
  });
  final List<String> labels;
  final int selected;
  final void Function(int) onSelect;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var i = 0; i < labels.length; i++)
          _PillTab(
            label: labels[i],
            selected: selected == i,
            activeBg: scheme.primaryContainer,
            activeFg: scheme.onPrimaryContainer,
            onTap: () => onSelect(i),
            dense: true,
          ),
      ],
    );
  }
}

class _PillTab extends StatelessWidget {
  const _PillTab({
    required this.label,
    required this.selected,
    required this.activeBg,
    required this.activeFg,
    required this.onTap,
    this.dense = false,
  });
  final String label;
  final bool selected;
  final Color activeBg;
  final Color activeFg;
  final VoidCallback onTap;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final border = StadiumBorder(
      side: selected
          ? BorderSide.none
          : BorderSide(color: scheme.outlineVariant),
    );
    return Material(
      color: selected ? activeBg : Colors.transparent,
      shape: border,
      child: InkWell(
        onTap: onTap,
        customBorder: border,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: dense ? 14 : 18,
            vertical: dense ? 6 : 9,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: dense ? 11 : 13,
              fontWeight: dense ? FontWeight.w700 : FontWeight.w500,
              letterSpacing: dense ? 1.3 : 0.2,
              color: selected ? activeFg : scheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: scheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

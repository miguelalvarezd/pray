import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/icons.dart';
import '../../core/nav/scroll_notifier.dart' show scrollTriggersProvider;
import '../../core/widgets/expandable_fab.dart';
import '../../core/time/current_date_provider.dart';
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
import 'widgets/intention_card.dart';
import 'widgets/novena_card.dart';

enum _View { intentions, novenas }

class IntentionsScreen extends ConsumerStatefulWidget {
  const IntentionsScreen({super.key});

  @override
  ConsumerState<IntentionsScreen> createState() => _IntentionsScreenState();
}

class _IntentionsScreenState extends ConsumerState<IntentionsScreen> {
  _View _view = _View.intentions;
  bool _showArchived = false;
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
      _showArchived = false;
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
    final prayedCounts = buildIntentionCountMap(logs);

    final activeIntentions = sortIntentions(
      intentions.where((i) => i.status == IntentionStatus.active),
      now,
    );
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
                    activeLabel: 'Active (${activeIntentions.length})',
                    archivedLabel: 'Archived (${archivedIntentions.length})',
                    showArchived: _showArchived,
                    onToggle: (v) => setState(() => _showArchived = v),
                    scheme: scheme,
                  ),
                  const SizedBox(height: 16),
                  ..._buildIntentionList(
                    _showArchived ? archivedIntentions : activeIntentions,
                    prayedCounts,
                    now,
                  ),
                ] else ...[
                  _SubTabs(
                    activeLabel: 'Active (${activeNovenas.length})',
                    archivedLabel: 'History (${historicalNovenas.length})',
                    showArchived: _showArchived,
                    onToggle: (v) => setState(() => _showArchived = v),
                    scheme: scheme,
                  ),
                  const SizedBox(height: 16),
                  ..._buildNovenaList(
                    _showArchived ? historicalNovenas : activeNovenas,
                    novenaStatuses,
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
    List intentions,
    Map<String, int> counts,
    DateTime now,
  ) {
    if (intentions.isEmpty) {
      return [
        _EmptyState(
          message: _showArchived
              ? 'No archived intentions.'
              : 'No active intentions.',
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
        onArchiveToggle: () => _toggleArchive(it),
        onDelete: () =>
            ref.read(intentionsProvider.notifier).delete(it.id),
      ));
      if (i < intentions.length - 1) widgets.add(const SizedBox(height: 12));
    }
    return widgets;
  }

  /// Archives or restores [intention], with an Undo that puts back exactly
  /// what was there before.
  Future<void> _toggleArchive(Intention intention) async {
    final notifier = ref.read(intentionsProvider.notifier);
    final archiving = intention.status == IntentionStatus.active;
    if (archiving) {
      await notifier.archive(intention.id);
    } else {
      await notifier.restore(intention.id);
    }
    if (!mounted) return;
    showUndoSnackBar(
      context,
      archiving ? 'Intention archived' : 'Intention restored',
      onUndo: () => notifier.update(intention),
    );
  }

  List<Widget> _buildNovenaList(
    List<Novena> novenas,
    Map<String, NovenaStatus> statuses,
  ) {
    if (novenas.isEmpty) {
      return [
        _EmptyState(
          message: _showArchived
              ? 'No past novenas.'
              : 'No active novenas.',
        ),
      ];
    }
    final widgets = <Widget>[];
    for (var i = 0; i < novenas.length; i++) {
      final n = novenas[i];
      widgets.add(NovenaCard(
        novena: n,
        status: statuses[n.id]!,
        onDelete: () => ref.read(novenasProvider.notifier).delete(n.id),
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
    required this.activeLabel,
    required this.archivedLabel,
    required this.showArchived,
    required this.onToggle,
    required this.scheme,
  });
  final String activeLabel;
  final String archivedLabel;
  final bool showArchived;
  final void Function(bool) onToggle;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _PillTab(
          label: activeLabel,
          selected: !showArchived,
          activeBg: scheme.primaryContainer,
          activeFg: scheme.onPrimaryContainer,
          onTap: () => onToggle(false),
          dense: true,
        ),
        const SizedBox(width: 8),
        _PillTab(
          label: archivedLabel,
          selected: showArchived,
          activeBg: scheme.primaryContainer,
          activeFg: scheme.onPrimaryContainer,
          onTap: () => onToggle(true),
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

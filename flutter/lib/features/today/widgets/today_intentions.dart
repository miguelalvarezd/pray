import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/time/current_date_provider.dart';
import '../../../core/time/logical_day.dart';
import '../../../data/models/intention.dart';
import '../../../data/repositories/intentions_repo.dart';
import '../../../data/repositories/logs_repo.dart';
import '../../../domain/intentions_logic.dart';

class TodayIntentionsList extends ConsumerWidget {
  const TodayIntentionsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final date = ref.watch(currentDateProvider);
    final dateStr = formatLogDate(date);
    final logs = ref.watch(logsProvider);
    final completedIntentions =
        logs[dateStr]?.completedIntentions ?? const <String>[];

    final intentions = ref.watch(intentionsProvider);
    final active = sortIntentions(
      intentions.where((i) => !i.isArchived),
      date,
    ).toList();

    if (active.isEmpty) return const SizedBox.shrink();

    final visible = active.take(5).toList();
    final hiddenCount = active.length - visible.length;

    Future<void> toggle(String id) =>
        ref.read(logsProvider.notifier).toggleIntention(dateStr, id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Intentions',
          style: GoogleFonts.newsreader(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < visible.length; i++) ...[
          _IntentionTile(
            intention: visible[i],
            done: completedIntentions.contains(visible[i].id),
            onTap: () => toggle(visible[i].id),
          ),
          if (i < visible.length - 1 || hiddenCount > 0)
            const SizedBox(height: 10),
        ],
        if (hiddenCount > 0)
          _MoreTile(
            count: hiddenCount,
            onTap: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              useSafeArea: true,
              showDragHandle: true,
              backgroundColor:
                  Theme.of(context).colorScheme.surfaceContainerLowest,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              builder: (_) => _AllIntentionsSheet(
                all: active,
                completedIntentions: completedIntentions.toSet(),
                onToggle: toggle,
              ),
            ),
          ),
      ],
    );
  }
}

class _MoreTile extends StatelessWidget {
  const _MoreTile({required this.count, required this.onTap});
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(
                color: scheme.outlineVariant.withValues(alpha: 0.6)),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Row(
            children: [
              Icon(Icons.more_horiz,
                  size: 18, color: scheme.onSurfaceVariant),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '$count more intention${count == 1 ? '' : 's'}',
                  style: GoogleFonts.newsreader(
                    fontSize: 15,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              Icon(Icons.chevron_right,
                  size: 20, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _AllIntentionsSheet extends StatefulWidget {
  const _AllIntentionsSheet({
    required this.all,
    required this.completedIntentions,
    required this.onToggle,
  });
  final List<Intention> all;
  final Set<String> completedIntentions;
  final Future<void> Function(String) onToggle;

  @override
  State<_AllIntentionsSheet> createState() => _AllIntentionsSheetState();
}

class _AllIntentionsSheetState extends State<_AllIntentionsSheet> {
  late final Set<String> _completed = {...widget.completedIntentions};

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ConstrainedBox(
      constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 12, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'All Intentions',
                    style: GoogleFonts.newsreader(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: scheme.onSurface,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          Flexible(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              itemCount: widget.all.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final intention = widget.all[i];
                return _IntentionTile(
                  intention: intention,
                  done: _completed.contains(intention.id),
                  onTap: () async {
                    await widget.onToggle(intention.id);
                    if (!mounted) return;
                    setState(() {
                      if (_completed.contains(intention.id)) {
                        _completed.remove(intention.id);
                      } else {
                        _completed.add(intention.id);
                      }
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _IntentionTile extends StatelessWidget {
  const _IntentionTile({
    required this.intention,
    required this.done,
    required this.onTap,
  });

  final Intention intention;
  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: done ? scheme.secondaryContainer : scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(28),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: GoogleFonts.newsreader(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: done
                              ? scheme.onSecondaryContainer
                                  .withValues(alpha: 0.7)
                              : scheme.onSurface,
                          decoration: done
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          decorationColor: scheme.onSurfaceVariant,
                        ),
                        child: Text(intention.title),
                      ),
                      if (intention.description != null &&
                          intention.description!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          intention.description!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: done ? scheme.secondary : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: done ? scheme.secondary : scheme.outlineVariant,
                      width: 2,
                    ),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: ScaleTransition(scale: anim, child: child),
                    ),
                    child: done
                        ? Icon(Icons.check,
                            key: const ValueKey('check'),
                            size: 16,
                            color: scheme.onSecondary)
                        : const SizedBox.shrink(key: ValueKey('empty')),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

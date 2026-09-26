import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/icons.dart';
import '../../../core/time/current_date_provider.dart';
import '../../../core/time/logical_day.dart';
import '../../../data/models/novena.dart';
import '../../../data/repositories/intentions_repo.dart';
import '../../../data/repositories/logs_repo.dart';
import '../../../data/repositories/novenas_repo.dart';
import '../../../domain/novena_logic.dart';

class ActiveNovenas extends ConsumerStatefulWidget {
  const ActiveNovenas({super.key});

  @override
  ConsumerState<ActiveNovenas> createState() => _ActiveNovenasState();
}

class _ActiveNovenasState extends ConsumerState<ActiveNovenas> {
  final _expanded = <String>{};

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final date = ref.watch(currentDateProvider);
    final dateStr = formatLogDate(date);
    final logs = ref.watch(logsProvider);
    final completedNovenas = logs[dateStr]?.completedNovenas ?? const <String>[];
    final novenas = ref.watch(novenasProvider);
    final intentionTitles = {
      for (final i in ref.watch(intentionsProvider)) i.id: i.title,
    };

    final active = [
      for (final n in novenas)
        if (novenaStatus(n, logs, date) case NovenaInProgress(:final day))
          (novena: n, day: day),
    ];

    if (active.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Active Novenas',
          style: GoogleFonts.newsreader(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < active.length; i++) ...[
          _NovenaCard(
            novena: active[i].novena,
            intentionTitle: intentionTitles[active[i].novena.intentionId],
            dayOfNovena: active[i].day,
            done: completedNovenas.contains(active[i].novena.id),
            expanded: _expanded.contains(active[i].novena.id),
            onToggleExpand: () => setState(() {
              if (_expanded.contains(active[i].novena.id)) {
                _expanded.remove(active[i].novena.id);
              } else {
                _expanded.add(active[i].novena.id);
              }
            }),
            onToggleDone: () => ref
                .read(logsProvider.notifier)
                .toggleNovena(dateStr, active[i].novena.id),
          ),
          if (i < active.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _NovenaCard extends StatelessWidget {
  const _NovenaCard({
    required this.novena,
    required this.intentionTitle,
    required this.dayOfNovena,
    required this.done,
    required this.expanded,
    required this.onToggleExpand,
    required this.onToggleDone,
  });

  final Novena novena;
  final String? intentionTitle;
  final int dayOfNovena;
  final bool done;
  final bool expanded;
  final VoidCallback onToggleExpand;
  final VoidCallback onToggleDone;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasPrayer = novena.prayer != null && novena.prayer!.isNotEmpty;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: done ? scheme.tertiaryContainer : scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(32),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: hasPrayer ? onToggleExpand : onToggleDone,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 18, 22),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: done ? scheme.tertiary : scheme.tertiaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        lucideIconFor('BookHeart'),
                        size: 22,
                        color: done ? scheme.onTertiary : scheme.tertiary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: GoogleFonts.newsreader(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: scheme.onSurface,
                              decoration: done
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              decorationColor: scheme.onSurfaceVariant,
                            ),
                            child: Text(novena.title),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            [
                              'DAY $dayOfNovena OF 9',
                              ?intentionTitle,
                            ].join(' · ').toUpperCase(),
                            style: GoogleFonts.manrope(
                              fontSize: 10,
                              letterSpacing: 1.4,
                              color: scheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    if (hasPrayer) ...[
                      AnimatedRotation(
                        turns: expanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOutCubic,
                        child: Icon(Icons.keyboard_arrow_down,
                            color: scheme.onSurfaceVariant),
                      ),
                      const SizedBox(width: 12),
                    ],
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onToggleDone,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOut,
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: done ? scheme.tertiary : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: done
                                ? scheme.tertiary
                                : scheme.outlineVariant,
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
                                  color: scheme.onTertiary)
                              : const SizedBox.shrink(
                                  key: ValueKey('empty')),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutQuart,
              child: expanded && hasPrayer
                  ? Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color:
                                scheme.outlineVariant.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PRAYER FOR TODAY',
                            style: GoogleFonts.manrope(
                              fontSize: 10,
                              letterSpacing: 1.4,
                              fontWeight: FontWeight.w600,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            novena.prayer!,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox(width: double.infinity),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/icons.dart';
import '../../../data/models/daily_log.dart';
import '../../../data/models/novena.dart';
import '../../../domain/defaults.dart';
import '../../../services/liturgy/liturgical_calendar.dart';

class DayCard extends ConsumerWidget {
  const DayCard({
    super.key,
    required this.day,
    required this.log,
    required this.activeNovenas,
    required this.isToday,
    required this.expanded,
    required this.onToggleExpand,
  });

  final DateTime day;
  final DailyLog? log;
  final List<Novena> activeNovenas;
  final bool isToday;
  final bool expanded;
  final VoidCallback onToggleExpand;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final completed = log?.completedPrayers.length ?? 0;
    final total = kDefaultPrayers.length;
    final pct = total == 0 ? 0 : ((completed / total) * 100).round();
    final hasGratitudeEntry = (log?.gratitudeEntry?.isNotEmpty ?? false);
    final liturgicalColor = ref.watch(liturgicalDayProvider(day))?.color;

    final brightness = Theme.of(context).brightness;
    final pctColor = pct == 100
        ? scheme.secondary
        : pct > 0
            ? scheme.primary
            : scheme.outlineVariant;

    return Container(
      decoration: BoxDecoration(
        color: isToday ? scheme.secondaryContainer : scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(28),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        type: MaterialType.transparency,
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: hasGratitudeEntry ? onToggleExpand : null,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('EEEE').format(day),
                              style: GoogleFonts.newsreader(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: scheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              DateFormat('MMMM d, yyyy').format(day).toUpperCase(),
                              style: GoogleFonts.manrope(
                                fontSize: 10,
                                letterSpacing: 1.6,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (hasGratitudeEntry) ...[
                        AnimatedRotation(
                          turns: expanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 180),
                          child: Icon(Icons.keyboard_arrow_down,
                              color: scheme.onSurfaceVariant),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Text(
                        '$pct%',
                        style: GoogleFonts.newsreader(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: pctColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: pct / 100),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOutCubic,
                    builder: (context, v, _) => ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: v,
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(8),
                        backgroundColor: scheme.surfaceContainerHigh,
                        valueColor: AlwaysStoppedAnimation(
                          pct == 100 ? scheme.secondary : scheme.primary,
                        ),
                      ),
                    ),
                  ),
                  if (completed > 0 || activeNovenas.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final p in kDefaultPrayers)
                          _Dot(
                            icon: lucideIconFor(p.icon),
                            done: log?.completedPrayers.contains(p.id) ?? false,
                            doneBg: p.id == 'mass'
                                ? _liturgicalMainColor(liturgicalColor, brightness)
                                : scheme.secondary,
                            doneFg: p.id == 'mass'
                                ? _liturgicalOnColor(liturgicalColor, brightness)
                                : scheme.onSecondary,
                            offBg: scheme.surfaceContainerHigh,
                            offFg: scheme.onSurfaceVariant,
                            tooltip: p.title,
                          ),
                        for (final n in activeNovenas)
                          _Dot(
                            icon: lucideIconFor('BookHeart'),
                            done: log?.completedNovenas?.contains(n.id) ?? false,
                            doneBg: scheme.tertiary,
                            doneFg: scheme.onTertiary,
                            offBg: scheme.surfaceContainer,
                            offFg: scheme.onSurfaceVariant,
                            tooltip: n.title,
                          ),
                      ],
                    ),
                  ],
                  if ((log?.completedActivities?.isNotEmpty ?? false)) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final actId in log!.completedActivities!)
                          _ActivityChip(
                            id: actId,
                            scheme: scheme,
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: expanded && hasGratitudeEntry
                ? Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: scheme.outlineVariant.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    child: Text(
                      log!.gratitudeEntry!,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
        ),
      ),
    );
  }
}

Color _liturgicalMainColor(String? name, Brightness brightness) {
  final dark = brightness == Brightness.dark;
  switch (name) {
    case 'purple': return dark ? const Color(0xFFBFA1CE) : const Color(0xFF6B4C7A);
    case 'red':    return dark ? const Color(0xFFD98F8F) : const Color(0xFF8B3A3A);
    case 'rose':   return dark ? const Color(0xFFE6A8BB) : const Color(0xFFBF6B84);
    case 'white':  return dark ? const Color(0xFFD1CAAD) : const Color(0xFFE8E2C8);
    default:       return dark ? const Color(0xFFA4BFA3) : const Color(0xFF546354);
  }
}

Color _liturgicalOnColor(String? name, Brightness brightness) {
  final dark = brightness == Brightness.dark;
  switch (name) {
    case 'purple': return dark ? const Color(0xFF3F204D) : Colors.white;
    case 'red':    return dark ? const Color(0xFF4D1515) : Colors.white;
    case 'rose':   return dark ? const Color(0xFF5C2035) : Colors.white;
    case 'white':  return dark ? const Color(0xFF383525) : const Color(0xFF2F3332);
    default:       return dark ? const Color(0xFF1A261A) : Colors.white;
  }
}

class _Dot extends StatelessWidget {
  const _Dot({
    required this.icon,
    required this.done,
    required this.doneBg,
    required this.doneFg,
    required this.offBg,
    required this.offFg,
    required this.tooltip,
  });

  final IconData icon;
  final bool done;
  final Color doneBg;
  final Color doneFg;
  final Color offBg;
  final Color offFg;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final w = Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: done ? doneBg : offBg,
        shape: BoxShape.circle,
      ),
      child: Opacity(
        opacity: done ? 1 : 0.4,
        child: Icon(icon, size: 22, color: done ? doneFg : offFg),
      ),
    );
    return Tooltip(message: tooltip, child: w);
  }
}

class _ActivityChip extends StatelessWidget {
  const _ActivityChip({required this.id, required this.scheme});
  final String id;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final activity = kDefaultActivities.where((a) => a.id == id).firstOrNull;
    if (activity == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(lucideIconFor(activity.icon), size: 11, color: scheme.onPrimaryContainer),
          const SizedBox(width: 4),
          Text(
            activity.name,
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 0.6,
              color: scheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

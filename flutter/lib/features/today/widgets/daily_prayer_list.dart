import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/icons.dart';
import '../../../core/time/current_date_provider.dart';
import '../../../core/time/logical_day.dart';
import '../../../data/repositories/logs_repo.dart';
import '../../../domain/defaults.dart';
import '../../../services/api/litcal_client.dart';
import '../today_sections.dart';

class DailyPrayerList extends ConsumerStatefulWidget {
  const DailyPrayerList({super.key});

  @override
  ConsumerState<DailyPrayerList> createState() => _DailyPrayerListState();
}

class _DailyPrayerListState extends ConsumerState<DailyPrayerList> {
  final _expanded = <String>{};

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final date = ref.watch(currentDateProvider);
    final dateStr = formatLogDate(date);
    final logs = ref.watch(logsProvider);
    final completed = logs[dateStr]?.completedPrayers ?? const <String>[];
    final litcalClient = ref.watch(litCalClientProvider);
    final massColorName = litcalClient.colorSyncFor(dateStr);

    final cards = <Widget>[];
    for (var i = 0; i < kDefaultPrayers.length; i++) {
      final p = kDefaultPrayers[i];
      cards.add(_PrayerCard(
        prayer: p,
        done: completed.contains(p.id),
        expanded: _expanded.contains(p.id),
        sections: sectionsFor(ref, p.id),
        liturgicalColorName: p.id == 'mass' ? massColorName : null,
        onToggleExpand: () => setState(() {
          if (_expanded.contains(p.id)) {
            _expanded.remove(p.id);
          } else {
            _expanded.add(p.id);
          }
        }),
        onToggleDone: () {
          HapticFeedback.mediumImpact();
          ref.read(logsProvider.notifier).togglePrayer(dateStr, p.id);
        },
      ));
      if (i < kDefaultPrayers.length - 1) cards.add(const SizedBox(height: 12));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daily Prayers',
          style: GoogleFonts.newsreader(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        ...cards,
      ],
    );
  }
}

typedef _LitColors = ({
  Color color,
  Color onColor,
  Color container,
  Color onContainer,
});

_LitColors? _litcalColorSet(String? name, Brightness brightness) {
  if (name == null) return null;
  final dark = brightness == Brightness.dark;
  switch (name) {
    case 'purple':
      return dark
          ? (color: const Color(0xFFBFA1CE), onColor: const Color(0xFF3F204D), container: const Color(0xFF543563), onContainer: const Color(0xFFE8D7F0))
          : (color: const Color(0xFF6B4C7A), onColor: Colors.white, container: const Color(0xFFE8D7F0), onContainer: const Color(0xFF452B52));
    case 'red':
      return dark
          ? (color: const Color(0xFFD98F8F), onColor: const Color(0xFF4D1515), container: const Color(0xFF732626), onContainer: const Color(0xFFF2CECE))
          : (color: const Color(0xFF8B3A3A), onColor: Colors.white, container: const Color(0xFFF2CECE), onContainer: const Color(0xFF5C2121));
    case 'white':
      return dark
          ? (color: const Color(0xFFD1CAAD), onColor: const Color(0xFF383525), container: const Color(0xFF4F4B36), onContainer: const Color(0xFFF9F6EA))
          : (color: const Color(0xFFE8E2C8), onColor: const Color(0xFF2F3332), container: const Color(0xFFF9F6EA), onContainer: const Color(0xFF54503E));
    case 'rose':
      return dark
          ? (color: const Color(0xFFE6A8BB), onColor: const Color(0xFF5C2035), container: const Color(0xFF8C3B57), onContainer: const Color(0xFFF7DBE4))
          : (color: const Color(0xFFBF6B84), onColor: Colors.white, container: const Color(0xFFF7DBE4), onContainer: const Color(0xFF7A3A50));
    default: // green + any unknown
      return dark
          ? (color: const Color(0xFFA4BFA3), onColor: const Color(0xFF1A261A), container: const Color(0xFF394A39), onContainer: const Color(0xFFD7E7D4))
          : (color: const Color(0xFF546354), onColor: Colors.white, container: const Color(0xFFD7E7D4), onContainer: const Color(0xFF263326));
  }
}

class _PrayerCard extends StatelessWidget {
  const _PrayerCard({
    required this.prayer,
    required this.done,
    required this.expanded,
    required this.sections,
    required this.onToggleExpand,
    required this.onToggleDone,
    this.liturgicalColorName,
  });

  final PrayerDefault prayer;
  final bool done;
  final bool expanded;
  final List<PrayerSection> sections;
  final VoidCallback onToggleExpand;
  final VoidCallback onToggleDone;
  final String? liturgicalColorName;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    final hasSections = sections.isNotEmpty;

    final lit = _litcalColorSet(liturgicalColorName, brightness);
    final cardDoneBg = lit?.container ?? scheme.secondaryContainer;
    final iconBg = done
        ? (lit?.color ?? scheme.secondary)
        : (lit?.container ?? scheme.secondaryContainer);
    final iconFg = done
        ? (lit?.onColor ?? scheme.onSecondary)
        : (lit?.onContainer ?? scheme.onSecondaryContainer);
    final checkAccent = lit?.color ?? scheme.secondary;
    final checkFg = lit?.onColor ?? scheme.onSecondary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: done ? cardDoneBg : scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(32),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: hasSections ? onToggleExpand : onToggleDone,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 18, 22),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
                      child: Icon(lucideIconFor(prayer.icon), size: 22, color: iconFg),
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
                            child: Text(prayer.title),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            prayer.subtitle,
                            style: GoogleFonts.manrope(
                              fontSize: 10,
                              letterSpacing: 1.4,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    if (hasSections) ...[
                      AnimatedRotation(
                        turns: expanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOutCubic,
                        child: Icon(Icons.keyboard_arrow_down,
                            color: scheme.onSurfaceVariant),
                      ),
                      const SizedBox(width: 12),
                    ],
                    _CheckButton(
                      done: done,
                      accentColor: checkAccent,
                      checkFg: checkFg,
                      onTap: onToggleDone,
                    ),
                  ],
                ),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutQuart,
              child: expanded && hasSections
                  ? Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: scheme.outlineVariant.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (var i = 0; i < sections.length; i++) ...[
                            _SectionView(section: sections[i]),
                            if (i < sections.length - 1) const SizedBox(height: 20),
                          ],
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

class _CheckButton extends StatelessWidget {
  const _CheckButton({
    required this.done,
    required this.accentColor,
    required this.checkFg,
    required this.onTap,
  });
  final bool done;
  final Color accentColor;
  final Color checkFg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: done ? accentColor : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: done ? accentColor : scheme.outlineVariant,
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
                  key: ValueKey('check'),
                  size: 16,
                  color: checkFg)
              : const SizedBox.shrink(key: ValueKey('empty')),
        ),
      ),
    );
  }
}

class _SectionView extends StatelessWidget {
  const _SectionView({required this.section});
  final PrayerSection section;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          section.title,
          style: GoogleFonts.manrope(
            fontSize: 10,
            letterSpacing: 1.4,
            fontWeight: FontWeight.w600,
            color: scheme.onSurfaceVariant,
          ),
        ),
        if (section.content != null) ...[
          const SizedBox(height: 8),
          Text(
            section.content!,
            style: GoogleFonts.newsreader(
              fontSize: 17,
              height: 1.35,
              color: scheme.onSurface,
            ),
          ),
        ],
        if (section.items.isNotEmpty) ...[
          const SizedBox(height: 12),
          for (final item in section.items)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item.icon != null) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Icon(
                        lucideIconFor(item.icon!),
                        size: 14,
                        color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: Text(
                      item.text,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.45,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }
}

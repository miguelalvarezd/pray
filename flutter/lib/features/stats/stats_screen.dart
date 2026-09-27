import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/icons.dart';
import '../../core/widgets/round_icon_button.dart';
import '../../core/nav/scroll_notifier.dart' show scrollTriggersProvider;
import '../../core/time/current_date_provider.dart';
import '../../data/models/daily_log.dart';
import '../../data/repositories/logs_repo.dart';
import '../../domain/defaults.dart';
import '../../domain/streaks_logic.dart';
import 'widgets/heatmap_calendar.dart';
import 'widgets/monthly_goal_card.dart';
import 'widgets/prayer_progress.dart';
import 'widgets/streak_card.dart';
import 'widgets/streak_details_modal.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  DateTime? _month;
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      scrollTriggersProvider.select((m) => m[3] ?? 0),
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
    final today = ref.watch(currentDateProvider);
    final month = _month ??= DateTime(today.year, today.month);
    final logs = ref.watch(logsProvider);

    final overall = calculateStreak(logs, isPrayedDay, today);
    final perPrayer = {
      for (final p in kDefaultPrayers)
        p.id: calculateStreak(logs, hasPrayerCompleted(p.id), today),
    };

    final monthly = _computeMonthlyStats(logs, month, today);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          controller: _scrollController,

          cacheExtent: 300,
          padding: const EdgeInsets.fromLTRB(20, 40, 20, 96),
          children: [
            _Header(scheme: scheme),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: StreakCard(
                    label: 'Current Streak',
                    value: overall.current,
                    icon: Icons.local_fire_department,
                    bg: scheme.secondaryContainer,
                    fg: scheme.onSecondaryContainer,
                    numberColor: scheme.onSecondaryContainer,
                    onTap: () => showStreakDetails(
                      context,
                      kind: StreakDetailKind.current,
                      perPrayer: perPrayer,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StreakCard(
                    label: 'Best Streak',
                    value: overall.best,
                    icon: Icons.trending_up,
                    bg: scheme.surfaceContainerLow,
                    fg: scheme.onSurfaceVariant,
                    numberColor: scheme.primary,
                    onTap: () => showStreakDetails(
                      context,
                      kind: StreakDetailKind.best,
                      perPrayer: perPrayer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            MonthlyGoalCard(
              activeDays: monthly.activeDays,
              daysPassed: monthly.daysPassed,
              averagePerDay: monthly.averagePerDay,
            ),
            const SizedBox(height: 20),
            HeatmapCalendar(logs: logs, year: today.year),
            const SizedBox(height: 28),
            _MonthNav(
              month: month,
              today: today,
              onPrev: () =>
                  setState(() => _month = DateTime(month.year, month.month - 1)),
              onNext: _canGoNext(month, today)
                  ? () => setState(
                      () => _month = DateTime(month.year, month.month + 1))
                  : null,
            ),
            const SizedBox(height: 16),
            for (var i = 0; i < kDefaultPrayers.length; i++) ...[
              PrayerProgressBar(
                label: kDefaultPrayers[i].title,
                count: monthly.perPrayer[kDefaultPrayers[i].id] ?? 0,
                total: monthly.daysPassed,
              ),
              if (i < kDefaultPrayers.length - 1) const SizedBox(height: 18),
            ],
            if (monthly.totalNovenas > 0) ...[
              const SizedBox(height: 18),
              PrayerProgressBar(
                label: 'Novenas',
                count: monthly.totalNovenas,
                total: monthly.daysPassed,
                icon: lucideIconFor('BookHeart'),
                barColor: scheme.tertiary,
              ),
            ],
            if (monthly.totalActivities > 0) ...[
              const SizedBox(height: 18),
              PrayerProgressBar(
                label: 'Activities',
                count: monthly.totalActivities,
                total: monthly.daysPassed,
                icon: Icons.auto_awesome,
                suffix: 'total',
              ),
            ],
          ],
        ),
      ),
    );
  }

  bool _canGoNext(DateTime month, DateTime today) {
    if (month.year == today.year && month.month == today.month) return false;
    final next = DateTime(month.year, month.month + 1);
    return !next.isAfter(DateTime(today.year, today.month));
  }
}

class _MonthlyStats {
  final Map<String, int> perPrayer;
  final int totalNovenas;
  final int totalActivities;
  final double averagePerDay;
  final int activeDays;
  final int daysPassed;

  const _MonthlyStats({
    required this.perPrayer,
    required this.totalNovenas,
    required this.totalActivities,
    required this.averagePerDay,
    required this.activeDays,
    required this.daysPassed,
  });
}

_MonthlyStats _computeMonthlyStats(
  Map<String, DailyLog> logs,
  DateTime month,
  DateTime today,
) {
  final fmt = DateFormat('yyyy-MM-dd');
  final monthStart = DateTime(month.year, month.month, 1);
  final monthEnd = DateTime(month.year, month.month + 1, 0);
  final todayDate = DateTime(today.year, today.month, today.day);

  final perPrayer = {for (final p in kDefaultPrayers) p.id: 0};
  int totalPrayers = 0;
  int totalNovenas = 0;
  int totalActivities = 0;
  int activeDays = 0;

  for (var d = monthStart;
      !d.isAfter(monthEnd);
      d = d.add(const Duration(days: 1))) {
    if (d.isAfter(todayDate)) break;
    final log = logs[fmt.format(d)];
    if (log != null && isPrayedDay(log)) {
      activeDays++;
      totalPrayers += log.completedPrayers.length;
      for (final pid in log.completedPrayers) {
        if (perPrayer.containsKey(pid)) {
          perPrayer[pid] = (perPrayer[pid] ?? 0) + 1;
        }
      }
      totalNovenas += log.completedNovenas?.length ?? 0;
      totalActivities += log.completedActivities?.length ?? 0;
    }
  }

  final daysInMonth = monthEnd.day;
  int daysPassed;
  if (month.year == today.year && month.month == today.month) {
    daysPassed = today.day;
  } else if (DateTime(month.year, month.month).isAfter(DateTime(today.year, today.month))) {
    daysPassed = 0;
  } else {
    daysPassed = daysInMonth;
  }

  final avg = daysPassed > 0
      ? (totalPrayers + totalNovenas) / daysPassed
      : 0.0;

  return _MonthlyStats(
    perPrayer: perPrayer,
    totalNovenas: totalNovenas,
    totalActivities: totalActivities,
    averagePerDay: avg,
    activeDays: activeDays,
    daysPassed: daysPassed,
  );
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
          'GROW IN GRACE AND KNOWLEDGE',
          style: GoogleFonts.manrope(
            fontSize: 11,
            letterSpacing: 1.6,
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Stats',
          style: GoogleFonts.newsreader(
            fontSize: 38,
            height: 1.05,
            fontWeight: FontWeight.w500,
            color: scheme.onSurface,
          ),
        ),
      ],
    );
  }
}

class _MonthNav extends StatelessWidget {
  const _MonthNav({
    required this.month,
    required this.today,
    required this.onPrev,
    required this.onNext,
  });

  final DateTime month;
  final DateTime today;
  final VoidCallback onPrev;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: Text(
            month.year == today.year
                ? '${DateFormat('MMMM').format(month)} Agenda'
                : '${DateFormat('MMMM yyyy').format(month)} Agenda',
            style: GoogleFonts.newsreader(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: scheme.onSurface,
            ),
          ),
        ),
        RoundIconButton(icon: Icons.chevron_left, onPressed: onPrev),
        const SizedBox(width: 8),
        RoundIconButton(icon: Icons.chevron_right, onPressed: onNext),
      ],
    );
  }
}

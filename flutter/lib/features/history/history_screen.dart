import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/nav/scroll_notifier.dart' show scrollTriggersProvider;
import '../../core/widgets/round_icon_button.dart';
import '../../core/time/current_date_provider.dart';
import '../../core/time/logical_day.dart';
import '../../data/models/novena.dart';
import '../../data/repositories/logs_repo.dart';
import '../../data/repositories/novenas_repo.dart';
import 'widgets/day_card.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  DateTime? _month;
  String? _expandedDay;
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      scrollTriggersProvider.select((m) => m[2] ?? 0),
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
    final novenas = ref.watch(novenasProvider);

    final days = _daysToShow(month, today);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          controller: _scrollController,

          cacheExtent: 300,
          padding: const EdgeInsets.fromLTRB(20, 40, 20, 96),
          children: [
            _Header(scheme: scheme),
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
            const SizedBox(height: 20),
            if (days.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: Center(
                  child: Text(
                    'No history for this month.',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            else
              for (var i = 0; i < days.length; i++) ...[
                _buildDay(days[i], today, logs, novenas),
                if (i < days.length - 1) const SizedBox(height: 12),
              ],
          ],
        ),
      ),
    );
  }

  Widget _buildDay(
    DateTime day,
    DateTime today,
    Map<String, dynamic> logs,
    List<Novena> novenas,
  ) {
    final dateStr = formatLogDate(day);
    final log = logs[dateStr];
    final dayMidnight = DateTime(day.year, day.month, day.day);
    final activeNovenas = novenas.where((n) {
      final start = DateTime.parse(n.startDate);
      final diff = dayMidnight.difference(start).inDays;
      return diff >= 0 && diff <= 8;
    }).toList();
    return DayCard(
      day: day,
      log: log,
      activeNovenas: activeNovenas,
      isToday: dateStr == formatLogDate(today),
      expanded: _expandedDay == dateStr,
      onToggleExpand: () => setState(() {
        _expandedDay = _expandedDay == dateStr ? null : dateStr;
      }),
    );
  }

  /// Reverse-chronological list of days in [month] up to [today].
  List<DateTime> _daysToShow(DateTime month, DateTime today) {
    final start = DateTime(month.year, month.month, 1);
    final lastOfMonth = DateTime(month.year, month.month + 1, 0);
    final todayDate = DateTime(today.year, today.month, today.day);
    final end = lastOfMonth.isAfter(todayDate) ? todayDate : lastOfMonth;
    if (end.isBefore(start)) return const [];
    final days = <DateTime>[];
    for (var d = end; !d.isBefore(start); d = d.subtract(const Duration(days: 1))) {
      days.add(d);
    }
    return days;
  }

  bool _canGoNext(DateTime month, DateTime today) {
    if (month.year == today.year && month.month == today.month) return false;
    final next = DateTime(month.year, month.month + 1);
    return !next.isAfter(DateTime(today.year, today.month));
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
          'HE WHO BEGAN A GOOD WORK WILL CARRY IT ON',
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
              const TextSpan(text: 'Your Journey of\n'),
              TextSpan(
                text: 'Devotion',
                style: GoogleFonts.newsreader(
                  fontSize: 38,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                  color: scheme.secondary,
                ),
              ),
            ],
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
                ? DateFormat('MMMM').format(month)
                : DateFormat('MMMM yyyy').format(month),
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

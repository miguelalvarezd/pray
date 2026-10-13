import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/icons.dart';
import '../../core/nav/scroll_notifier.dart' show scrollTriggersProvider;
import '../../core/widgets/expandable_fab.dart';
import '../../core/time/current_date_provider.dart';
import '../../core/time/logical_day.dart';
import '../../data/repositories/logs_repo.dart';
import '../../domain/defaults.dart';
import 'widgets/active_novenas.dart';
import 'widgets/daily_prayer_list.dart';
import 'widgets/daily_reflection.dart';
import 'widgets/gratitude_entry.dart';
import 'widgets/today_activities.dart';
import 'widgets/streak_bar.dart';
import 'widgets/today_intentions.dart';

class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({super.key});

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen> {
  bool _fabOpen = false;
  final _scrollController = ScrollController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!TickerMode.valuesOf(context).enabled && _fabOpen) {
      setState(() => _fabOpen = false);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      scrollTriggersProvider.select((m) => m[0] ?? 0),
      (_, _) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOutCubicEmphasized,
        );
      }
    });

    final date = ref.watch(currentDateProvider);
    final dateStr = formatLogDate(date);
    final logs = ref.watch(logsProvider);
    final log = logs[dateStr];

    final completedPrayers = log?.completedPrayers.length ?? 0;
    final totalPrayers = kDefaultPrayers.length;

    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      floatingActionButton: ExpandableFab(
        isOpen: _fabOpen,
        onToggle: () => setState(() => _fabOpen = !_fabOpen),
        actions: [
          FabAction(
            heroTag: 'fab-mass',
            icon: lucideIconFor('Church'),
            label: 'Mass',
            onPressed: () => context.push('/mass'),
          ),
          FabAction(
            heroTag: 'fab-rosary',
            icon: lucideIconFor('Crown'),
            label: 'Rosary',
            onPressed: () => context.push('/rosary'),
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
            _Header(date: date, scheme: scheme),
            const SizedBox(height: 28),
            StreakBar(completed: completedPrayers, total: totalPrayers),
            const SizedBox(height: 28),
            const DailyPrayerList(),
            const SizedBox(height: 28),
            const ActiveNovenas(),
            const SizedBox(height: 28),
            const TodayIntentionsList(),
            const SizedBox(height: 28),
            const TodayActivities(),
            const SizedBox(height: 28),
            const GratitudeEntry(),
            const SizedBox(height: 28),
            DailyReflection(date: date),
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
}

class _Header extends StatelessWidget {
  const _Header({required this.date, required this.scheme});
  final DateTime date;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final dateLabel =
        DateFormat('EEEE, MMMM ').format(date) + _ordinal(date.day);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          dateLabel.toUpperCase(),
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
              const TextSpan(text: "Today's\n"),
              TextSpan(
                text: 'Intentions',
                style: GoogleFonts.newsreader(
                  fontSize: 38,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                  color: scheme.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String _ordinal(int n) {
    if (n >= 11 && n <= 13) return '${n}th';
    switch (n % 10) {
      case 1:
        return '${n}st';
      case 2:
        return '${n}nd';
      case 3:
        return '${n}rd';
      default:
        return '${n}th';
    }
  }
}

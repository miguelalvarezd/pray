import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/widgets/round_icon_button.dart';
import '../../../data/models/activity_category.dart';
import '../../../data/models/daily_log.dart';
import '../../../domain/defaults.dart';
import '../../../services/api/litcal_client.dart';

enum HeatmapFilter { all, prayers, novenas, activities }

class HeatmapCalendar extends ConsumerStatefulWidget {
  const HeatmapCalendar({
    super.key,
    required this.logs,
    required this.year,
  });

  final Map<String, DailyLog> logs;
  final int year;

  @override
  ConsumerState<HeatmapCalendar> createState() => _HeatmapCalendarState();
}

class _HeatmapCalendarState extends ConsumerState<HeatmapCalendar> {
  HeatmapFilter _filter = HeatmapFilter.all;
  String? _prayerSub;
  ActivityCategory? _activitySub;
  late int _year;

  @override
  void initState() {
    super.initState();
    _year = widget.year;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    final litcalClient = ref.watch(litCalClientProvider);

    // Per-cell color override: only active when mass sub-filter is selected.
    Color? Function(String dateStr)? colorOverride;
    if (_filter == HeatmapFilter.prayers && _prayerSub == 'mass') {
      colorOverride = (dateStr) {
        final log = widget.logs[dateStr];
        if (log == null || !log.completedPrayers.contains('mass')) return null;
        return _litColor(litcalClient.colorSyncFor(dateStr), brightness, scheme);
      };
    }

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(28),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '$_year',
                        style: GoogleFonts.newsreader(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: scheme.onSurface,
                        ),
                      ),
                      TextSpan(
                        text: ' Activity',
                        style: GoogleFonts.newsreader(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                          color: scheme.onSurface.withValues(alpha: 0.35),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              RoundIconButton(
                icon: Icons.chevron_left,
                onPressed: () => setState(() => _year--),
              ),
              const SizedBox(width: 8),
              RoundIconButton(
                icon: Icons.chevron_right,
                onPressed: _year < widget.year
                    ? () => setState(() => _year++)
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _ChipRow(
            children: [
              for (final f in HeatmapFilter.values)
                ChoiceChip(
                  label: Text(_labelFor(f)),
                  selected: _filter == f,
                  onSelected: (_) => setState(() {
                    _filter = f;
                    _prayerSub = null;
                    _activitySub = null;
                  }),
                  visualDensity: VisualDensity.compact,
                  labelStyle: const TextStyle(fontSize: 11),
                ),
            ],
          ),
          if (_filter == HeatmapFilter.prayers) ...[
            const SizedBox(height: 8),
            _ChipRow(
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: _prayerSub == null,
                  onSelected: (_) => setState(() => _prayerSub = null),
                  visualDensity: VisualDensity.compact,
                  labelStyle: const TextStyle(fontSize: 11),
                ),
                for (final p in kDefaultPrayers)
                  ChoiceChip(
                    label: Text(p.title),
                    selected: _prayerSub == p.id,
                    onSelected: (_) => setState(() => _prayerSub = p.id),
                    visualDensity: VisualDensity.compact,
                    labelStyle: const TextStyle(fontSize: 11),
                  ),
              ],
            ),
          ],
          if (_filter == HeatmapFilter.activities) ...[
            const SizedBox(height: 8),
            _ChipRow(
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: _activitySub == null,
                  onSelected: (_) => setState(() => _activitySub = null),
                  visualDensity: VisualDensity.compact,
                  labelStyle: const TextStyle(fontSize: 11),
                ),
                for (final cat in ActivityCategory.values)
                  ChoiceChip(
                    label: Text(_categoryLabel(cat)),
                    selected: _activitySub == cat,
                    onSelected: (_) => setState(() => _activitySub = cat),
                    visualDensity: VisualDensity.compact,
                    labelStyle: const TextStyle(fontSize: 11),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: _Grid(
              year: _year,
              logs: widget.logs,
              intensityFor: _buildIntensityFn(),
              colorOverride: colorOverride,
              scheme: scheme,
            ),
          ),
          const SizedBox(height: 12),
          _Legend(scheme: scheme),
        ],
      ),
    );
  }

  int Function(DailyLog?) _buildIntensityFn() {
    switch (_filter) {
      case HeatmapFilter.all:
        return (log) {
          if (log == null) return 0;
          final v = log.completedPrayers.length +
              (log.completedNovenas?.length ?? 0) +
              (log.completedActivities?.length ?? 0);
          return _clamp(v);
        };
      case HeatmapFilter.prayers:
        if (_prayerSub != null) {
          final id = _prayerSub!;
          return (log) =>
              (log?.completedPrayers.contains(id) ?? false) ? 4 : 0;
        }
        return (log) {
          final n = log?.completedPrayers.length ?? 0;
          if (n <= 0) return 0;
          if (n == 1) return 1;
          if (n <= 3) return 2;
          if (n == 4) return 3;
          return 4;
        };
      case HeatmapFilter.novenas:
        return (log) => _clamp(log?.completedNovenas?.length ?? 0);
      case HeatmapFilter.activities:
        if (_activitySub != null) {
          final cat = _activitySub!;
          final ids = kDefaultActivities
              .where((a) => a.category == cat)
              .map((a) => a.id)
              .toSet();
          return (log) => _clamp(
              log?.completedActivities?.where(ids.contains).length ?? 0);
        }
        return (log) => _clamp(log?.completedActivities?.length ?? 0);
    }
  }

  static int _clamp(int v) {
    if (v <= 0) return 0;
    if (v == 1) return 1;
    if (v == 2) return 2;
    if (v == 3) return 3;
    return 4;
  }

  static String _labelFor(HeatmapFilter f) => switch (f) {
        HeatmapFilter.all => 'All',
        HeatmapFilter.prayers => 'Prayers',
        HeatmapFilter.novenas => 'Novenas',
        HeatmapFilter.activities => 'Activities',
      };

  static String _categoryLabel(ActivityCategory cat) => switch (cat) {
        ActivityCategory.sacramental => 'Sacramental',
        ActivityCategory.devotional => 'Devotional',
        ActivityCategory.service => 'Service',
        ActivityCategory.spiritual => 'Spiritual',
      };
}

/// Maps a litcal color name to the appropriate hue for the heatmap cell,
/// respecting light/dark mode. Falls back to theme secondary (ordinary time).
Color _litColor(String? name, Brightness brightness, ColorScheme scheme) {
  final dark = brightness == Brightness.dark;
  switch (name) {
    case 'purple': return dark ? const Color(0xFFBFA1CE) : const Color(0xFF6B4C7A);
    case 'red':    return dark ? const Color(0xFFD98F8F) : const Color(0xFF8B3A3A);
    case 'rose':   return dark ? const Color(0xFFE6A8BB) : const Color(0xFFBF6B84);
    case 'white':  return dark ? const Color(0xFFD1CAAD) : const Color(0xFFE8E2C8);
    default:       return scheme.secondary; // green / unknown → ordinary time
  }
}

class _ChipRow extends StatelessWidget {
  const _ChipRow({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: children.length,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (_, i) => children[i],
      ),
    );
  }
}

/// Describes one rendered column: a [week] index and the inclusive day-of-week
/// range [startDay]..[endDay] (0 = Monday … 6 = Sunday, ISO week order) that
/// is visible. Days outside the range are transparent spacers that keep rows
/// aligned when a straddling week is split across two month columns.
class _Slice {
  const _Slice(this.week, this.startDay, this.endDay);
  final int week;
  final int startDay;
  final int endDay;
}

class _Grid extends StatelessWidget {
  const _Grid({
    required this.year,
    required this.logs,
    required this.intensityFor,
    required this.scheme,
    this.colorOverride,
  });

  final int year;
  final Map<String, DailyLog> logs;
  final int Function(DailyLog?) intensityFor;
  final Color? Function(String dateStr)? colorOverride;
  final ColorScheme scheme;

  static const _cell = 11.0;
  static const _gap = 3.0;
  static const _monthGap = 9.0;
  static const _fmt = 'yyyy-MM-dd';
  // Height reserved for the month-name row above the grid.
  static const _labelH = 13.0;

  @override
  Widget build(BuildContext context) {
    final yearStart = DateTime(year, 1, 1);
    final yearEnd = DateTime(year, 12, 31);
    // Monday-first: Dart weekday Mon=1…Sun=7 → (weekday-1)%7 gives Mon=0…Sun=6.
    final leadingPadDays = (yearStart.weekday - 1) % 7;
    final totalDays = yearEnd.difference(yearStart).inDays + 1;
    final totalCells = leadingPadDays + totalDays;
    final weeks = (totalCells / 7).ceil();

    // Build column slices. Straddling weeks are split so each month's days
    // always land on the correct side of the month gap.
    final slices = <_Slice>[];
    for (var w = 0; w < weeks; w++) {
      final split = _splitDay(yearStart, leadingPadDays, w, yearEnd);
      if (split != null) {
        slices.add(_Slice(w, 0, split - 1));  // old-month half
        slices.add(_Slice(w, split, 6));       // new-month half
      } else {
        slices.add(_Slice(w, 0, 6));
      }
    }

    // Precompute month index and inter-column gap for each slice pair.
    final months = [
      for (final s in slices) _monthOf(s, yearStart, leadingPadDays, yearEnd),
    ];
    final gaps = [
      for (var i = 1; i < slices.length; i++)
        months[i] != months[i - 1] ? _monthGap : _gap,
    ];

    // Helper: build a Row of per-slice widgets separated by precomputed gaps.
    Row sliceRow(Widget Function(int i, _Slice s) builder) => Row(
          children: [
            for (var i = 0; i < slices.length; i++) ...[
              if (i > 0) SizedBox(width: gaps[i - 1]),
              builder(i, slices[i]),
            ],
          ],
        );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Weekday labels (Mon … Sun), offset below the month-name row ──
        Padding(
          padding: const EdgeInsets.only(top: _labelH + 4),
          child: Column(
            children: [
              for (var d = 0; d < 7; d++)
                Padding(
                  padding: EdgeInsets.only(bottom: d == 6 ? 0 : _gap),
                  child: SizedBox(
                    width: 9,
                    height: _cell,
                    child: Text(
                      _weekdayLabel(d),
                      style: TextStyle(
                        fontSize: 8,
                        color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 5),
        // ── Month labels + cell grid ──
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month abbreviations: shown above the first slice of each month.
            sliceRow((i, s) {
              final showLabel = i == 0 || months[i] != months[i - 1];
              return SizedBox(
                width: _cell,
                height: _labelH,
                child: showLabel
                    ? _monthLabel(s, yearStart, leadingPadDays, yearEnd)
                    : null,
              );
            }),
            const SizedBox(height: 4),
            // Cell grid.
            sliceRow((_, s) => _buildSlice(s, yearStart, leadingPadDays, yearEnd)),
          ],
        ),
      ],
    );
  }

  Widget _buildSlice(
      _Slice slice, DateTime yearStart, int leadingPadDays, DateTime yearEnd) {
    return Column(
      children: [
        for (var d = 0; d < 7; d++)
          Padding(
            padding: EdgeInsets.only(bottom: d == 6 ? 0 : _gap),
            child: (d >= slice.startDay && d <= slice.endDay)
                ? _cellFor(yearStart, leadingPadDays, slice.week, d, yearEnd)
                : SizedBox(width: _cell, height: _cell),
          ),
      ],
    );
  }

  Widget _monthLabel(
      _Slice slice, DateTime yearStart, int leadingPadDays, DateTime yearEnd) {
    final date = _firstDate(slice, yearStart, leadingPadDays, yearEnd);
    if (date == null) return const SizedBox.shrink();
    return Text(
      DateFormat('MMM').format(date),
      style: TextStyle(fontSize: 9, color: scheme.onSurfaceVariant),
      overflow: TextOverflow.visible,
      softWrap: false,
    );
  }

  /// Month of the first real day in [slice]; null if all padding/out-of-range.
  int? _monthOf(
      _Slice slice, DateTime yearStart, int leadingPadDays, DateTime yearEnd) {
    return _firstDate(slice, yearStart, leadingPadDays, yearEnd)?.month;
  }

  /// First real calendar date covered by [slice].
  DateTime? _firstDate(
      _Slice slice, DateTime yearStart, int leadingPadDays, DateTime yearEnd) {
    for (var d = slice.startDay; d <= slice.endDay; d++) {
      final dayOffset = slice.week * 7 + d - leadingPadDays;
      if (dayOffset < 0) continue;
      final date = yearStart.add(Duration(days: dayOffset));
      if (date.isAfter(yearEnd)) return null;
      return date;
    }
    return null;
  }

  /// Day-of-week index (0=Mon … 6=Sun) where the month changes within [week];
  /// null if the week is entirely within one month.
  int? _splitDay(
      DateTime yearStart, int leadingPadDays, int week, DateTime yearEnd) {
    int? prevMonth;
    for (var d = 0; d < 7; d++) {
      final dayOffset = week * 7 + d - leadingPadDays;
      if (dayOffset < 0) continue;
      final date = yearStart.add(Duration(days: dayOffset));
      if (date.isAfter(yearEnd)) break;
      if (prevMonth != null && date.month != prevMonth) return d;
      prevMonth = date.month;
    }
    return null;
  }

  Widget _cellFor(
    DateTime yearStart,
    int leadingPad,
    int week,
    int dayOfWeek,
    DateTime yearEnd,
  ) {
    final cellIndex = week * 7 + dayOfWeek;
    final dayOffset = cellIndex - leadingPad;
    if (dayOffset < 0) return SizedBox(width: _cell, height: _cell);
    final date = yearStart.add(Duration(days: dayOffset));
    if (date.isAfter(yearEnd)) return SizedBox(width: _cell, height: _cell);

    final dateStr = DateFormat(_fmt).format(date);
    final log = logs[dateStr];
    final intensity = intensityFor(log);
    final overrideColor = colorOverride?.call(dateStr);

    return Tooltip(
      message: '$dateStr  ·  ${_intensityLabel(intensity)}',
      child: Container(
        width: _cell,
        height: _cell,
        decoration: BoxDecoration(
          color: overrideColor ?? _colorFor(intensity),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  // M, W, F, S shown on Mon/Wed/Fri/Sun rows; others blank.
  static String _weekdayLabel(int d) =>
      const ['M', 'T', 'W', 'T', 'F', 'S', 'S'][d];

  String _intensityLabel(int i) =>
      i == 0 ? 'no activity' : '$i ${i == 1 ? "entry" : "entries"}';

  Color _colorFor(int i) => switch (i) {
        0 => scheme.surfaceContainerHigh,
        1 => scheme.primary.withValues(alpha: 0.30),
        2 => scheme.primary.withValues(alpha: 0.55),
        3 => scheme.primary.withValues(alpha: 0.80),
        _ => scheme.primary,
      };
}

class _Legend extends StatelessWidget {
  const _Legend({required this.scheme});
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text('Less',
            style: TextStyle(fontSize: 10, color: scheme.onSurfaceVariant)),
        const SizedBox(width: 6),
        for (var i = 0; i <= 4; i++) ...[
          Container(
            width: 11,
            height: 11,
            decoration: BoxDecoration(
              color: switch (i) {
                0 => scheme.surfaceContainerHigh,
                1 => scheme.primary.withValues(alpha: 0.30),
                2 => scheme.primary.withValues(alpha: 0.55),
                3 => scheme.primary.withValues(alpha: 0.80),
                _ => scheme.primary,
              },
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 3),
        ],
        const SizedBox(width: 3),
        Text('More',
            style: TextStyle(fontSize: 10, color: scheme.onSurfaceVariant)),
      ],
    );
  }
}

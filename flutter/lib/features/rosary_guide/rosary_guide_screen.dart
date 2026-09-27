import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/time/current_date_provider.dart';
import '../../core/time/logical_day.dart';
import '../../data/repositories/logs_repo.dart';
import '../../domain/rosary_engine.dart';
import 'widgets/bead_row.dart';
import 'widgets/step_view.dart';

// Persists the user's position within the rosary across screen pops.
// Cleared when the rosary is marked as complete.
typedef _RosaryProgress = ({MysteryType type, int index});

class _RosaryProgressNotifier extends Notifier<_RosaryProgress?> {
  @override
  _RosaryProgress? build() => null;

  void save(MysteryType type, int index) => state = (type: type, index: index);
  void clear() => state = null;
}

final _rosaryProgressProvider =
    NotifierProvider<_RosaryProgressNotifier, _RosaryProgress?>(
  _RosaryProgressNotifier.new,
);

class RosaryGuideScreen extends ConsumerStatefulWidget {
  const RosaryGuideScreen({super.key});

  @override
  ConsumerState<RosaryGuideScreen> createState() => _RosaryGuideScreenState();
}

class _RosaryGuideScreenState extends ConsumerState<RosaryGuideScreen> {
  late final List<RosaryStep> _steps;
  late final MysterySet _mysterySet;
  int _index = 0;

  /// Changes whenever the shown prayer changes, which is what triggers the
  /// crossfade. Moving between identical prayers keeps it, so the text stays
  /// put and only the beads move.
  int _prayerKey = 0;

  @override
  void initState() {
    super.initState();
    final today = ref.read(currentDateProvider);
    _mysterySet = getMysterySetForDate(today);
    _steps = generateRosarySteps(_mysterySet);

    final saved = ref.read(_rosaryProgressProvider);
    final resumeIndex =
        saved?.type == _mysterySet.type ? saved!.index : 0;
    _index = resumeIndex;
  }

  void _go(int delta) => _goTo(_index + delta);

  void _goTo(int target) {
    final next = target.clamp(0, _steps.length - 1);
    if (next == _index) return;
    final stepByStep = (next - _index).abs() == 1;
    setState(() {
      if (!stepByStep || !isSamePrayer(_steps[_index], _steps[next])) {
        _prayerKey++;
      }
      _index = next;
    });
    _saveProgress(next);
  }

  void _saveProgress(int index) {
    ref.read(_rosaryProgressProvider.notifier).save(_mysterySet.type, index);
  }

  Future<void> _markComplete() async {
    final today = ref.read(currentDateProvider);
    final dateStr = formatLogDate(today);
    await ref.read(logsProvider.notifier).togglePrayer(dateStr, 'rosary');
    ref.read(_rosaryProgressProvider.notifier).clear();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final step = _steps[_index];
    final isComplete = step.type == StepType.complete;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: GestureDetector(
          onTap: _showStepSheet,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _mysterySet.shortName,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 6),
              Text(
                'Step ${_index + 1} / ${_steps.length}',
                style: TextStyle(
                  fontSize: 12,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.format_list_bulleted),
            tooltip: 'Jump to section',
            onPressed: _showSectionSheet,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (_index + 1) / _steps.length,
              minHeight: 3,
              borderRadius: BorderRadius.circular(8),
              backgroundColor: scheme.surfaceContainerHigh,
              valueColor: AlwaysStoppedAnimation(scheme.primary),
            ),
            const SizedBox(height: 12),
            BeadRow(step: step),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                // Tap anywhere on the prayer to advance. Scrolling a long
                // prayer is a drag, so it never counts as a tap.
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: isComplete ? null : () => _go(1),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: KeyedSubtree(
                      key: ValueKey(_prayerKey),
                      child: RosaryStepView(step: step),
                    ),
                  ),
                ),
              ),
            ),
            _BottomBar(
              onPrev: _index == 0 ? null : () => _go(-1),
              onNext: _index >= _steps.length - 1 ? null : () => _go(1),
              isComplete: isComplete,
              onComplete: _markComplete,
              scheme: scheme,
            ),
          ],
        ),
      ),
    );
  }

  List<_Section> get _sections {
    final out = <_Section>[];

    out.add(_Section(
      label: 'Introduction',
      subtitle: 'Sign of the Cross · Creed · Our Father',
      index: 0,
    ));

    for (var d = 1; d <= 5; d++) {
      final idx = _steps.indexWhere(
        (s) => s.decadeNumber == d && s.type == StepType.mysteryReveal,
      );
      if (idx < 0) continue;
      final m = _mysterySet.mysteries[d - 1];
      out.add(_Section(
        label: '${m.number}. ${m.name}',
        subtitle: m.scripture,
        index: idx,
      ));
    }

    final closingIdx = _steps.indexWhere((s) => s.key == 'hail_holy_queen');
    if (closingIdx >= 0) {
      out.add(_Section(
        label: 'Closing Prayers',
        subtitle: 'Hail Holy Queen · Litany · Pope\'s Intentions',
        index: closingIdx,
      ));
    }

    return out;
  }

  int _activeSectionIndex(List<_Section> sections) {
    for (var i = sections.length - 1; i >= 0; i--) {
      if (_index >= sections[i].index) return i;
    }
    return 0;
  }

  Future<void> _showStepSheet() async {
    final picked = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => _StepListSheet(steps: _steps, current: _index),
    );
    if (picked != null) _goTo(picked);
  }

  Future<void> _showSectionSheet() async {
    final sections = _sections;
    final picked = await showModalBottomSheet<int>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      clipBehavior: Clip.antiAlias,
      builder: (_) => _SectionSheet(
        sections: sections,
        activeSectionIndex: _activeSectionIndex(sections),
      ),
    );
    if (picked != null) _goTo(picked);
  }
}

class _Section {
  const _Section({
    required this.label,
    required this.subtitle,
    required this.index,
  });
  final String label;
  final String subtitle;
  final int index;
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.onPrev,
    required this.onNext,
    required this.isComplete,
    required this.onComplete,
    required this.scheme,
  });

  final VoidCallback? onPrev;
  final VoidCallback? onNext;
  final bool isComplete;
  final VoidCallback onComplete;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: SizedBox(
        height: 56,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: FilledButton.tonal(
                onPressed: onPrev,
                style: FilledButton.styleFrom(padding: EdgeInsets.zero),
                child: const Icon(Icons.chevron_left, size: 28),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: isComplete
                  ? FilledButton.icon(
                      onPressed: onComplete,
                      icon: const Icon(Icons.check),
                      label: const Text('Mark Rosary as prayed'),
                    )
                  : FilledButton.tonal(
                      onPressed: onNext,
                      style: FilledButton.styleFrom(
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                      child: const Text('Next'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionSheet extends StatelessWidget {
  const _SectionSheet({
    required this.sections,
    required this.activeSectionIndex,
  });
  final List<_Section> sections;
  final int activeSectionIndex;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 24),
      shrinkWrap: true,
      itemCount: sections.length,
      itemBuilder: (_, i) => Container(
        decoration: BoxDecoration(
          color: i == activeSectionIndex
              ? scheme.primaryContainer.withValues(alpha: 0.3)
              : null,
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Text(sections[i].label),
          subtitle: Text(
            sections[i].subtitle,
            style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
          ),
          onTap: () => Navigator.of(context).pop(sections[i].index),
        ),
      ),
    );
  }
}

class _StepListSheet extends StatelessWidget {
  const _StepListSheet({required this.steps, required this.current});
  final List<RosaryStep> steps;
  final int current;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: steps.length,
        itemBuilder: (_, i) {
          final step = steps[i];
          final selected = i == current;
          return ListTile(
            dense: true,
            selected: selected,
            selectedTileColor: scheme.primaryContainer.withValues(alpha: 0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            leading: SizedBox(
              width: 28,
              child: Text(
                '${i + 1}',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 11,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
            title: Text(step.prayerTitle, style: const TextStyle(fontSize: 14)),
            subtitle: step.prayerSubtitle == null
                ? null
                : Text(
                    step.prayerSubtitle!,
                    style: TextStyle(
                      fontSize: 11,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
            onTap: () => Navigator.of(context).pop(i),
          );
        },
      ),
    );
  }
}

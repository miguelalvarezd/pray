import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/icons.dart';
import '../../../core/time/current_date_provider.dart';
import '../../../core/time/logical_day.dart';
import '../../../data/models/activity_category.dart';
import '../../../data/models/extra_activity.dart';
import '../../../data/repositories/logs_repo.dart';
import '../../../domain/defaults.dart';

const _categoryLabels = <ActivityCategory, String>{
  ActivityCategory.sacramental: 'Sacramental',
  ActivityCategory.devotional: 'Devotional',
  ActivityCategory.service: 'Service',
  ActivityCategory.spiritual: 'Spiritual',
};

class OtherPrayers extends ConsumerWidget {
  const OtherPrayers({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final date = ref.watch(currentDateProvider);
    final dateStr = formatLogDate(date);
    final logs = ref.watch(logsProvider);
    final completed = logs[dateStr]?.completedActivities ?? const <String>[];

    Future<void> toggle(String id) async {
      final notifier = ref.read(logsProvider.notifier);
      final current = notifier.forDate(dateStr);
      final list = List<String>.from(current.completedActivities ?? const []);
      if (list.contains(id)) {
        list.remove(id);
      } else {
        list.add(id);
      }
      await notifier.save(current.copyWith(completedActivities: list));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Other Prayers',
          style: GoogleFonts.newsreader(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final id in completed)
              if (_findActivity(id) != null)
                _CompletedChip(
                  activity: _findActivity(id)!,
                  onRemove: () => toggle(id),
                ),
            _AddChip(
              onTap: () => _openPicker(context, completed: completed, onToggle: toggle),
            ),
          ],
        ),
      ],
    );
  }

  static ExtraActivity? _findActivity(String id) {
    for (final a in kDefaultExtraActivities) {
      if (a.id == id) return a;
    }
    return null;
  }

  Future<void> _openPicker(
    BuildContext context, {
    required List<String> completed,
    required Future<void> Function(String) onToggle,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (_) => _PickerSheet(
        completed: completed.toSet(),
        onToggle: onToggle,
      ),
    );
  }
}

class _CompletedChip extends StatelessWidget {
  const _CompletedChip({required this.activity, required this.onRemove});
  final ExtraActivity activity;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.primaryContainer,
      shape: const StadiumBorder(),
      child: InkWell(
        onTap: onRemove,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(lucideIconFor(activity.icon), size: 14, color: scheme.onPrimaryContainer),
              const SizedBox(width: 8),
              Text(
                activity.name,
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 0.3,
                  color: scheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.close, size: 12, color: scheme.onPrimaryContainer.withValues(alpha: 0.6)),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddChip extends StatelessWidget {
  const _AddChip({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      shape: StadiumBorder(
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add, size: 14, color: scheme.onSurfaceVariant),
              const SizedBox(width: 6),
              Text(
                'Add',
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 0.3,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PickerSheet extends StatefulWidget {
  const _PickerSheet({required this.completed, required this.onToggle});
  final Set<String> completed;
  final Future<void> Function(String) onToggle;

  @override
  State<_PickerSheet> createState() => _PickerSheetState();
}

class _PickerSheetState extends State<_PickerSheet> {
  late final Set<String> _completed = {...widget.completed};

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final groups = <ActivityCategory, List<ExtraActivity>>{};
    for (final a in kDefaultExtraActivities) {
      groups.putIfAbsent(a.category, () => []).add(a);
    }

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 12, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Other Activities',
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
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              children: [
                for (final entry in groups.entries) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 6),
                    child: Text(
                      _categoryLabels[entry.key]!.toUpperCase(),
                      style: GoogleFonts.manrope(
                        fontSize: 10,
                        letterSpacing: 1.4,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  for (final a in entry.value)
                    _PickerRow(
                      activity: a,
                      added: _completed.contains(a.id),
                      onTap: () async {
                        await widget.onToggle(a.id);
                        if (!mounted) return;
                        setState(() {
                          if (_completed.contains(a.id)) {
                            _completed.remove(a.id);
                          } else {
                            _completed.add(a.id);
                          }
                        });
                      },
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PickerRow extends StatelessWidget {
  const _PickerRow({
    required this.activity,
    required this.added,
    required this.onTap,
  });
  final ExtraActivity activity;
  final bool added;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: added ? scheme.primaryContainer : Colors.transparent,
        shape: const StadiumBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const StadiumBorder(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: added ? scheme.primary : scheme.surfaceContainerHigh,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    lucideIconFor(activity.icon),
                    size: 16,
                    color: added ? scheme.onPrimary : scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    activity.name,
                    style: GoogleFonts.newsreader(
                      fontSize: 16,
                      color: added ? scheme.onPrimaryContainer : scheme.onSurface,
                    ),
                  ),
                ),
                if (added)
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.check, size: 14, color: scheme.onPrimary),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

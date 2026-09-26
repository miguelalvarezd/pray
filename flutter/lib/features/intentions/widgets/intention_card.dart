import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../data/models/intention.dart';
import '../../../data/models/intention_status.dart';
import '../../../data/models/priority.dart';

class IntentionCard extends StatelessWidget {
  const IntentionCard({
    super.key,
    required this.intention,
    required this.urgency,
    required this.prayedCount,
    required this.onAnswer,
    required this.onArchive,
    required this.onRestore,
    required this.onDelete,
  });

  final Intention intention;
  final double urgency;
  final int prayedCount;
  final VoidCallback onAnswer;
  final VoidCallback onArchive;
  final VoidCallback onRestore;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isActive = intention.status == IntentionStatus.active;
    final isAnswered = intention.status == IntentionStatus.answered;
    final isUrgent = urgency > 40 && isActive;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(28),
        border: isUrgent
            ? Border.all(color: scheme.error.withValues(alpha: 0.4))
            : null,
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        intention.title,
                        style: GoogleFonts.newsreader(
                          fontSize: 19,
                          color: scheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (isUrgent) ...[
                      const SizedBox(width: 6),
                      Icon(Icons.error_outline,
                          size: 16, color: scheme.error),
                    ],
                  ],
                ),
                if (intention.description != null &&
                    intention.description!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    intention.description!,
                    style: TextStyle(
                      fontSize: 13,
                      color: scheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (isAnswered && intention.answerNote != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    intention.answerNote!,
                    style: GoogleFonts.newsreader(
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                      color: scheme.onSurface,
                      height: 1.35,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _PriorityChip(priority: intention.priority),
                    if (intention.targetDate != null)
                      _Chip(
                        label:
                            'Target: ${DateFormat('MMM d, yyyy').format(DateTime.parse(intention.targetDate!))}',
                        bg: scheme.surfaceContainer,
                        fg: scheme.onSurfaceVariant,
                      ),
                    if (isAnswered && intention.answeredOn != null)
                      _Chip(
                        label:
                            'Answered ${DateFormat('MMM d, yyyy').format(DateTime.parse(intention.answeredOn!))}',
                        bg: scheme.secondaryContainer,
                        fg: scheme.onSecondaryContainer,
                        icon: Icons.check_circle_outline,
                      ),
                    if (prayedCount > 0)
                      _Chip(
                        label:
                            'Prayed $prayedCount ${prayedCount == 1 ? "day" : "days"}',
                        bg: scheme.primaryContainer.withValues(alpha: 0.7),
                        fg: scheme.onPrimaryContainer,
                        icon: Icons.auto_awesome,
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              if (isActive) ...[
                IconButton(
                  tooltip: 'Mark answered',
                  visualDensity: VisualDensity.compact,
                  onPressed: onAnswer,
                  icon: Icon(Icons.check_circle_outline,
                      size: 20, color: scheme.outline),
                ),
                IconButton(
                  tooltip: 'Archive',
                  visualDensity: VisualDensity.compact,
                  onPressed: onArchive,
                  icon: Icon(Icons.archive_outlined,
                      size: 20, color: scheme.outline),
                ),
              ] else
                IconButton(
                  tooltip: 'Restore',
                  visualDensity: VisualDensity.compact,
                  onPressed: onRestore,
                  icon: Icon(Icons.unarchive_outlined,
                      size: 20, color: scheme.outline),
                ),
              IconButton(
                tooltip: 'Delete',
                visualDensity: VisualDensity.compact,
                onPressed: onDelete,
                icon: Icon(Icons.delete_outline,
                    size: 20, color: scheme.outline),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PriorityChip extends StatelessWidget {
  const _PriorityChip({required this.priority});
  final Priority priority;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (bg, fg) = switch (priority) {
      Priority.high => (scheme.errorContainer.withValues(alpha: 0.4), scheme.error),
      Priority.medium => (scheme.tertiaryContainer, scheme.onTertiaryContainer),
      Priority.low => (scheme.secondaryContainer, scheme.onSecondaryContainer),
    };
    return _Chip(label: priority.name.toUpperCase(), bg: bg, fg: fg);
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.bg,
    required this.fg,
    this.icon,
  });
  final String label;
  final Color bg;
  final Color fg;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.3,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

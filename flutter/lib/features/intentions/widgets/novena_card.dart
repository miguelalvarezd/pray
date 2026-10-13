import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/icons.dart';
import '../../../data/models/novena.dart';
import '../../../domain/novena_logic.dart';

class NovenaCard extends StatelessWidget {
  const NovenaCard({
    super.key,
    required this.novena,
    required this.intentionTitle,
    required this.status,
    required this.onDelete,
  });

  final Novena novena;

  /// Current title of the Intention the Novena is offered for, if any.
  final String? intentionTitle;
  final NovenaStatus status;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final start = DateTime.parse(novena.startDate);
    final isPast = status is NovenaCompleted || status is NovenaIncomplete;

    final (chipBg, chipFg) = switch (status) {
      NovenaInProgress() => (scheme.tertiaryContainer, scheme.onTertiaryContainer),
      NovenaCompleted() => (scheme.secondaryContainer, scheme.onSecondaryContainer),
      NovenaUpcoming() || NovenaIncomplete() =>
        (scheme.surfaceContainer, scheme.onSurfaceVariant),
    };

    final chipLabel = switch (status) {
      NovenaUpcoming() =>
        'STARTS ${DateFormat('MMM d').format(start).toUpperCase()}',
      NovenaInProgress(:final day) => 'DAY $day OF 9',
      NovenaCompleted() => 'COMPLETED',
      NovenaIncomplete(:final daysPrayed) => 'INCOMPLETE · $daysPrayed OF 9',
    };

    return Opacity(
      opacity: isPast ? 0.6 : 1,
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(28),
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
                      Icon(lucideIconFor('BookHeart'),
                          size: 16, color: scheme.tertiary),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          novena.title,
                          style: GoogleFonts.newsreader(
                            fontSize: 19,
                            color: scheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (intentionTitle != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      intentionTitle!,
                      style: TextStyle(
                        fontSize: 13,
                        color: scheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: chipBg,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      chipLabel,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.3,
                        color: chipFg,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              tooltip: 'Delete',
              visualDensity: VisualDensity.compact,
              onPressed: onDelete,
              icon: Icon(Icons.delete_outline,
                  size: 20, color: scheme.outline),
            ),
          ],
        ),
      ),
    );
  }
}

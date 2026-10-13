import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../domain/defaults.dart';
import '../../../domain/streaks_logic.dart';

enum StreakDetailKind { current, best }

Future<void> showStreakDetails(
  BuildContext context, {
  required StreakDetailKind kind,
  required Map<String, StreakResult> perPrayer,
}) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.4),
    builder: (_) => _StreakDetailsDialog(kind: kind, perPrayer: perPrayer),
  );
}

class _StreakDetailsDialog extends StatelessWidget {
  const _StreakDetailsDialog({required this.kind, required this.perPrayer});
  final StreakDetailKind kind;
  final Map<String, StreakResult> perPrayer;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isCurrent = kind == StreakDetailKind.current;
    return Dialog(
      backgroundColor: scheme.surfaceContainerLowest,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isCurrent ? Icons.local_fire_department : Icons.trending_up,
                  size: 22,
                  color: isCurrent ? scheme.secondary : scheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isCurrent ? 'Current Streaks' : 'Best Streaks',
                    style: GoogleFonts.newsreader(
                      fontSize: 20,
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
            const SizedBox(height: 16),
            for (final p in kDefaultPrayers) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        p.title,
                        style: GoogleFonts.manrope(
                          fontSize: 15,
                          color: scheme.onSurface,
                        ),
                      ),
                    ),
                    Text(
                      '${isCurrent ? perPrayer[p.id]?.current ?? 0 : perPrayer[p.id]?.best ?? 0}',
                      style: GoogleFonts.newsreader(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'DAYS',
                      style: GoogleFonts.manrope(
                        fontSize: 10,
                        color: scheme.onSurfaceVariant,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}

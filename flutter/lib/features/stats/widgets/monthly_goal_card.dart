import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MonthlyGoalCard extends StatelessWidget {
  const MonthlyGoalCard({
    super.key,
    required this.activeDays,
    required this.daysPassed,
    required this.averagePerDay,
  });

  final int activeDays;
  final int daysPassed;
  final double averagePerDay;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final pct = daysPassed > 0 ? ((activeDays / daysPassed) * 100).round() : 0;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(28),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'MONTHLY GOAL',
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    letterSpacing: 1.4,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              Text(
                '$pct%',
                style: GoogleFonts.newsreader(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: pct / 100),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (context, v, _) => ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: v,
                minHeight: 6,
                borderRadius: BorderRadius.circular(8),
                backgroundColor: scheme.surfaceContainerHigh,
                valueColor: AlwaysStoppedAnimation(scheme.primary),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$activeDays active days',
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  color: scheme.onSurfaceVariant,
                ),
              ),
              Text(
                '${averagePerDay.toStringAsFixed(1)} avg/day',
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

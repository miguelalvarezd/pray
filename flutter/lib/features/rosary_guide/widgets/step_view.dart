import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../domain/rosary_engine.dart';

class RosaryStepView extends StatelessWidget {
  const RosaryStepView({super.key, required this.step});
  final RosaryStep step;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (step.type == StepType.mysteryReveal) {
      return _MysteryView(step: step, scheme: scheme);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (step.mystery != null)
            _MysteryHeader(mystery: step.mystery!, scheme: scheme),
          if (step.prayerSubtitle != null && step.mystery == null) ...[
            Text(
              step.prayerSubtitle!.toUpperCase(),
              style: GoogleFonts.manrope(
                fontSize: 11,
                letterSpacing: 1.6,
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
          ],
          Text(
            step.prayerTitle,
            style: GoogleFonts.newsreader(
              fontSize: 26,
              fontWeight: FontWeight.w500,
              color: scheme.onSurface,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            step.prayerText,
            style: GoogleFonts.newsreader(
              fontSize: 18,
              height: 1.55,
              color: scheme.onSurface.withValues(alpha: 0.92),
            ),
          ),
        ],
      ),
    );
  }
}

class _MysteryHeader extends StatelessWidget {
  const _MysteryHeader({required this.mystery, required this.scheme});
  final StepMystery mystery;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: scheme.tertiaryContainer,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          '${mystery.number}. ${mystery.name}',
          style: GoogleFonts.manrope(
            fontSize: 10,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w600,
            color: scheme.onTertiaryContainer,
          ),
        ),
      ),
    );
  }
}

class _MysteryView extends StatelessWidget {
  const _MysteryView({required this.step, required this.scheme});
  final RosaryStep step;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final m = step.mystery!;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${m.number}. ${m.name}',
            style: GoogleFonts.newsreader(
              fontSize: 28,
              fontWeight: FontWeight.w500,
              color: scheme.onSurface,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            m.scripture,
            style: GoogleFonts.newsreader(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              m.reading,
              style: GoogleFonts.newsreader(
                fontSize: 14,
                height: 1.5,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'REFLECTION',
            style: GoogleFonts.manrope(
              fontSize: 11,
              letterSpacing: 1.6,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            m.reflection,
            style: GoogleFonts.newsreader(
              fontSize: 17,
              height: 1.5,
              color: scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

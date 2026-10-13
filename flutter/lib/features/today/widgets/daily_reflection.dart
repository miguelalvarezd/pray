import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../domain/reflections.dart';

class DailyReflection extends StatelessWidget {
  const DailyReflection({super.key, required this.date});
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final reflection = reflectionForDate(date);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '"${reflection.text}"',
            textAlign: TextAlign.center,
            style: GoogleFonts.newsreader(
              fontSize: 18,
              height: 1.4,
              fontStyle: FontStyle.italic,
              color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '— ${reflection.citation}'.toUpperCase(),
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 10,
              letterSpacing: 1.5,
              color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StreakCard extends StatelessWidget {
  const StreakCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.bg,
    required this.fg,
    required this.numberColor,
    required this.onTap,
  });

  final String label;
  final int value;
  final IconData icon;
  final Color bg;
  final Color fg;
  final Color numberColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: GoogleFonts.manrope(
                      fontSize: 10,
                      letterSpacing: 1.4,
                      color: fg.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$value',
                        style: GoogleFonts.newsreader(
                          fontSize: 44,
                          fontWeight: FontWeight.w700,
                          color: numberColor,
                          height: 1,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          'days',
                          style: GoogleFonts.newsreader(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            color: numberColor.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(icon, size: 14, color: fg),
                  const SizedBox(width: 6),
                  Text(
                    'Tap for details',
                    style: GoogleFonts.manrope(
                      fontSize: 10,
                      letterSpacing: 0.6,
                      color: fg.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class PrayerProgressBar extends StatelessWidget {
  const PrayerProgressBar({
    super.key,
    required this.label,
    required this.count,
    required this.total,
    this.icon,
    this.barColor,
    this.suffix = 'days',
  });

  final String label;
  final int count;
  final int total;
  final IconData? icon;
  final Color? barColor;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final pct = total > 0 ? (count / total).clamp(0.0, 1.0) : 0.0;
    final color = barColor ?? scheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16, color: color),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Text(
              total > 0 ? '$count/$total $suffix' : '$count $suffix',
              style: TextStyle(
                fontSize: 12,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: pct),
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutCubic,
          builder: (context, v, _) => ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: v,
              minHeight: 6,
              borderRadius: BorderRadius.circular(8),
              backgroundColor: scheme.surfaceContainerHigh,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
      ],
    );
  }
}

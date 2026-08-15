import 'package:flutter/material.dart';

import '../../../domain/rosary_engine.dart';

/// Horizontal bead track shown above the prayer content. Represents one phase
/// of the rosary at a time:
///
/// - **Intro phase** (5 beads): crucifix → Our Father large bead → 3 Hail
///   Mary small beads.
/// - **Decade phase** (11 beads): 1 Our Father large bead → 10 Hail Mary
///   small beads.
class BeadRow extends StatelessWidget {
  const BeadRow({super.key, required this.step});

  final RosaryStep step;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final track = step.track;

    if (track == null) return const SizedBox(height: 32);

    final beads = _beadsForPhase(track);
    return SizedBox(
      height: 36,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (var i = 0; i < beads.length; i++) ...[
            _Bead(
              key: ValueKey('${track.phase.name}_$i'),
              kind: beads[i],
              active: i == track.position,
              scheme: scheme,
            ),
            if (i < beads.length - 1) const SizedBox(width: 7),
          ],
        ],
      ),
    );
  }

  static List<BeadType> _beadsForPhase(StepTrack track) {
    if (track.phase == TrackPhase.intro) {
      return const [
        BeadType.crucifix,
        BeadType.large,
        BeadType.small,
        BeadType.small,
        BeadType.small,
        BeadType.large, // Glory Be / transition to decade 1
      ];
    }
    return const [
      BeadType.large, // Our Father
      BeadType.small,
      BeadType.small,
      BeadType.small,
      BeadType.small,
      BeadType.small,
      BeadType.small,
      BeadType.small,
      BeadType.small,
      BeadType.small,
      BeadType.small,
      BeadType.large, // Glory Be + Fatima / transition to next decade
    ];
  }
}

class _Bead extends StatelessWidget {
  const _Bead({
    super.key,
    required this.kind,
    required this.active,
    required this.scheme,
  });
  final BeadType kind;
  final bool active;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final accent = scheme.primary;
    final inactive = scheme.outlineVariant.withValues(alpha: 0.6);
    final fg = active ? accent : inactive;

    if (kind == BeadType.crucifix) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 18,
        height: 22,
        decoration: BoxDecoration(
          color: active ? accent : Colors.transparent,
          border: Border.all(color: fg, width: active ? 0 : 1.5),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Icon(
          Icons.add,
          size: 14,
          color: active ? scheme.onPrimary : fg,
        ),
      );
    }

    final size = switch (kind) {
      BeadType.large => 15.0,
      BeadType.small => 10.0,
      BeadType.none => 8.0,
      BeadType.crucifix => 18.0,
    };

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: active ? accent : Colors.transparent,
        border: Border.all(
          color: fg,
          width: active ? 0 : 1.5,
        ),
        shape: BoxShape.circle,
      ),
    );
  }
}

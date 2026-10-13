import 'dart:math' show pi;
import 'package:flutter/material.dart';

class FabAction {
  const FabAction({
    required this.heroTag,
    required this.icon,
    required this.label,
    required this.onPressed,
  });
  final Object heroTag;
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
}

/// A FAB that reveals labelled child FABs above it when tapped.
///
/// Closed state: larger square with rounded corners (M3 Expressive style).
/// Open state: shrinks to a standard round FAB showing ×, anchored top-right.
/// Sub-FABs reveal leftward (width expand from right edge) staggered bottom-first.
/// Pair with [FabScrim] in the Scaffold body to dismiss on outside tap.
class ExpandableFab extends StatefulWidget {
  const ExpandableFab({
    super.key,
    required this.isOpen,
    required this.onToggle,
    required this.actions,
  });

  final bool isOpen;
  final VoidCallback onToggle;
  final List<FabAction> actions;

  @override
  State<ExpandableFab> createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _shapeAnim;
  late final List<Animation<double>> _widthAnims;

  static const double _gap = 6;
  static const double _closedSize = 80;
  static const double _openSize = 56;
  static const double _closedRadius = 20;
  static const double _openRadius = 28;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
      value: widget.isOpen ? 1.0 : 0.0,
    );
    _shapeAnim = CurvedAnimation(
      parent: _ctrl,
      curve: Curves.easeInOutCubic,
    );

    // i=0 (bottommost sub-FAB) starts immediately; each step up adds 0.25.
    const stagger = 0.25;
    _widthAnims = List.generate(widget.actions.length, (i) {
      final start = (i * stagger).clamp(0.0, 0.5);
      final end = (start + 0.75).clamp(0.0, 1.0);
      return CurvedAnimation(
        parent: _ctrl,
        curve: Interval(start, end, curve: Curves.easeOutBack),
        reverseCurve: Interval(start, end, curve: Curves.easeInCubic),
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Snap closed instantly when tickers are disabled (e.g. tab goes inactive)
    // so the reverse animation doesn't resume and play on the way back.
    if (!TickerMode.valuesOf(context).enabled && _ctrl.value != 0.0) {
      _ctrl.value = 0.0;
    }
  }

  @override
  void didUpdateWidget(ExpandableFab old) {
    super.didUpdateWidget(old);
    // Guard: onTap already starts the animation; only drive here if the
    // open state changed via an external source (e.g. FabScrim tap).
    if (widget.isOpen != old.isOpen) {
      if (widget.isOpen && _ctrl.status != AnimationStatus.forward) {
        _ctrl.forward();
      } else if (!widget.isOpen && _ctrl.status != AnimationStatus.reverse) {
        _ctrl.reverse();
      }
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    // Start the animation immediately on tap — before the parent rebuild
    // arrives — so the shape and icon rotation begin on the same frame.
    widget.isOpen ? _ctrl.reverse() : _ctrl.forward();
    widget.onToggle();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (int i = widget.actions.length - 1; i >= 0; i--)
          Padding(
            padding: const EdgeInsets.only(bottom: _gap),
            child: IgnorePointer(
              ignoring: !widget.isOpen,
              child: AnimatedBuilder(
                animation: _widthAnims[i],
                builder: (context, child) {
                  final v = _widthAnims[i].value;
                  // Clamp widthFactor so the reveal stays within [0,1].
                  // Let scaleX carry the overshoot so the bounce is visible.
                  return Transform.scale(
                    scaleX: v > 1.0 ? v : 1.0,
                    alignment: Alignment.centerRight,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Align(
                        alignment: Alignment.centerRight,
                        widthFactor: v.clamp(0.0, 1.0),
                        child: child,
                      ),
                    ),
                  );
                },
                child: FloatingActionButton.extended(
                  heroTag: widget.actions[i].heroTag,
                  onPressed: () {
                    widget.onToggle();
                    widget.actions[i].onPressed();
                  },
                  icon: Icon(widget.actions[i].icon),
                  label: Text(widget.actions[i].label),
                ),
              ),
            ),
          ),
        AnimatedBuilder(
          animation: _shapeAnim,
          builder: (context, _) {
            final t = _shapeAnim.value;
            final size = _closedSize + (_openSize - _closedSize) * t;
            final radius = _closedRadius + (_openRadius - _closedRadius) * t;
            return SizedBox(
              width: _closedSize,
              height: _closedSize,
              child: Align(
                alignment: Alignment.topRight,
                child: SizedBox(
                  width: size,
                  height: size,
                  child: Material(
                    color: colorScheme.primaryContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(radius),
                    ),
                    elevation: 0,
                    child: InkWell(
                      onTap: _toggle,
                      customBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(radius),
                      ),
                      child: Center(
                        // Rotation driven from _shapeAnim so it stays
                        // frame-perfect with the size/radius morph.
                        child: Transform.rotate(
                          angle: t * pi / 4,
                          child: Icon(
                            Icons.add,
                            color: colorScheme.onPrimaryContainer,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Full-screen overlay in the Scaffold body Stack that dismisses the FAB on
/// outside tap. Always stays in the tree — opacity-animates and is
/// pointer-transparent when invisible.
class FabScrim extends StatelessWidget {
  const FabScrim({super.key, required this.visible, required this.onDismiss});
  final bool visible;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedOpacity(
        opacity: visible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: GestureDetector(
          onTap: onDismiss,
          behavior: HitTestBehavior.opaque,
          child: ColoredBox(
            color: Theme.of(context).colorScheme.scrim.withValues(alpha: 0.32),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }
}

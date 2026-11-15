import 'package:flutter/widgets.dart';

/// Fades and slides [child] in as [animation] goes from 0 to 1.
class RevealTransition extends StatelessWidget {
  const RevealTransition({
    super.key,
    required this.animation,
    required this.child,
    this.offset = const Offset(0, 0.12),
  });

  final Animation<double> animation;
  final Widget child;
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        // Mirrors horizontal offsets in right-to-left languages.
        textDirection: Directionality.of(context),
        position: Tween(begin: offset, end: Offset.zero).animate(animation),
        child: child,
      ),
    );
  }
}

extension StaggerAnimation on Animation<double> {
  /// A sub-range of this animation, e.g. `interval(0.2, 0.6)`.
  Animation<double> interval(
    double begin,
    double end, {
    Curve curve = Curves.easeOutCubic,
  }) => drive(
    CurveTween(
      curve: Interval(begin.clamp(0, 1), end.clamp(0, 1), curve: curve),
    ),
  );
}

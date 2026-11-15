import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// "Drawing the teams" suspense animation: a spinning ball and three kit
/// dots bouncing in turn.
class DrawingView extends StatefulWidget {
  const DrawingView({
    super.key,
    required this.message,
    required this.subtitle,
  });

  final String message;
  final String subtitle;

  @override
  State<DrawingView> createState() => _DrawingViewState();
}

class _DrawingViewState extends State<DrawingView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RotationTransition(
            turns: _controller,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.4),
                    blurRadius: 40,
                  ),
                ],
              ),
              child: const Icon(
                Icons.sports_soccer_rounded,
                size: 84,
                color: AppColors.accentBright,
              ),
            ),
          ),
          const SizedBox(height: 28),
          Text(widget.message, style: theme.textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            widget.subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 22),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < AppColors.teamKits.length; i++)
                  Transform.translate(
                    offset: Offset(
                      0,
                      -8 *
                          math
                              .sin((_controller.value - i / 3) * 2 * math.pi)
                              .clamp(0.0, 1.0),
                    ),
                    child: Container(
                      width: 12,
                      height: 12,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        color: AppColors.teamKits[i],
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

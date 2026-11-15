import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Large gradient call-to-action button.
///
/// [enabled] only changes the look: a dimmed button can still be tapped so
/// the screen can explain *why* the action isn't available yet.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool enabled;

  static const _radius = BorderRadius.all(Radius.circular(18));

  @override
  Widget build(BuildContext context) {
    final active = enabled && onPressed != null;
    final textStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      color: AppColors.onAccent,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.4,
    );

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 220),
      opacity: active ? 1 : 0.45,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: _radius,
          gradient: const LinearGradient(
            colors: [AppColors.accentBright, AppColors.accent],
          ),
          boxShadow: [
            if (active)
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.35),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: _radius,
            onTap: onPressed,
            child: SizedBox(
              height: 58,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: AppColors.onAccent, size: 22),
                      const SizedBox(width: 10),
                    ],
                    Flexible(
                      child: Text(
                        label,
                        style: textStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

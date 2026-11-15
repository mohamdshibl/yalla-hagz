import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Glowing football badge used as the app's logo.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 120});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.06),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.accentBright.withValues(alpha: 0.35),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.35),
            blurRadius: size * 0.4,
            spreadRadius: size * 0.02,
          ),
        ],
      ),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.accentBright, AppColors.accent, AppColors.pitch],
          ),
        ),
        child: Icon(
          Icons.sports_soccer_rounded,
          size: size * 0.58,
          color: AppColors.onAccent,
        ),
      ),
    );
  }
}

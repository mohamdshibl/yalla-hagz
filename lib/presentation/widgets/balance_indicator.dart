import 'package:flutter/material.dart';

import '../../domain/models/team_generation_result.dart';
import '../l10n/l10n_extensions.dart';
import '../theme/app_colors.dart';

/// Summary card comparing the three teams' total strength.
class BalanceIndicator extends StatelessWidget {
  const BalanceIndicator({super.key, required this.result});

  final TeamGenerationResult result;

  Color get _ratingColor => switch (result.rating) {
    BalanceRating.perfect => AppColors.accentBright,
    BalanceRating.excellent => AppColors.accent,
    BalanceRating.good => AppColors.warning,
    BalanceRating.bestPossible => const Color(0xFFFB923C),
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final rating = result.rating;
    final spread = result.strengthSpread;
    final maxStrength = result.maxStrength;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _ratingColor.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                rating == BalanceRating.perfect
                    ? Icons.verified_rounded
                    : Icons.balance_rounded,
                color: _ratingColor,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rating.title(l10n),
                      style: theme.textTheme.titleMedium,
                    ),
                    Text(
                      rating.description(l10n),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _PercentBadge(
                percent: result.balancePercent,
                color: _ratingColor,
              ),
            ],
          ),
          const SizedBox(height: 18),
          for (final team in result.teams)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  SizedBox(
                    width: 22,
                    child: Text(
                      team.localizedLabel(l10n),
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: AppColors.teamColor(team.index),
                      ),
                    ),
                  ),
                  Expanded(
                    child: _StrengthBar(
                      fraction: maxStrength == 0
                          ? 0
                          : team.totalStrength / maxStrength,
                      color: AppColors.teamColor(team.index),
                    ),
                  ),
                  SizedBox(
                    width: 34,
                    child: Text(
                      '${team.totalStrength}',
                      textAlign: TextAlign.end,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.insights_rounded,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  l10n.strengthGap(spread),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StrengthBar extends StatelessWidget {
  const _StrengthBar({required this.fraction, required this.color});

  final double fraction;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        height: 10,
        child: LayoutBuilder(
          builder: (context, box) => Stack(
            children: [
              const Positioned.fill(
                child: ColoredBox(color: AppColors.outline),
              ),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: fraction),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) => Container(
                  width: box.maxWidth * value,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    gradient: LinearGradient(
                      colors: [color.withValues(alpha: 0.6), color],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PercentBadge extends StatelessWidget {
  const _PercentBadge({required this.percent, required this.color});

  final double percent;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            '${percent.toStringAsFixed(0)}%',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          Text(
            context.l10n.balanceLabel,
            style: TextStyle(
              fontSize: 9,
              letterSpacing: context.tracking(1.2),
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

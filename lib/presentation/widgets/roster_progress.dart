import 'package:flutter/material.dart';

import '../../domain/models/skill_level.dart';
import '../l10n/l10n_extensions.dart';
import '../theme/app_colors.dart';

/// Header card with an animated "12/18 selected" ring, the pool size and the
/// rank mix of the selected players.
class RosterProgress extends StatelessWidget {
  const RosterProgress({
    super.key,
    required this.selected,
    required this.required,
    required this.poolSize,
    required this.distribution,
  });

  final int selected;
  final int required;
  final int poolSize;
  final Map<SkillLevel, int> distribution;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final complete = selected == required;

    final (title, subtitle) = switch (poolSize) {
      _ when complete => (
        l10n.lineupReadyTitle,
        l10n.lineupReadyMessage(required, poolSize),
      ),
      _ when poolSize < required => (
        l10n.buildPoolTitle,
        l10n.buildPoolMessage(required - poolSize),
      ),
      _ => (
        l10n.pickPlayersTitle,
        l10n.pickPlayersMessage(required - selected, poolSize),
      ),
    };

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: complete
              ? AppColors.accent.withValues(alpha: 0.5)
              : AppColors.outline,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(end: required == 0 ? 0 : selected / required),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) => SizedBox.square(
                  dimension: 66,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: value,
                        strokeWidth: 6,
                        strokeCap: StrokeCap.round,
                        backgroundColor: AppColors.outline,
                        color: complete
                            ? AppColors.accentBright
                            : AppColors.accent,
                      ),
                      Center(
                        child: Text.rich(
                          TextSpan(
                            text: '$selected',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                            children: [
                              TextSpan(
                                text: '/$required',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SkillDistributionBar(distribution: distribution, capacity: required),
        ],
      ),
    );
  }
}

/// Segmented bar + legend showing how many players there are per rank.
class SkillDistributionBar extends StatelessWidget {
  const SkillDistributionBar({
    super.key,
    required this.distribution,
    required this.capacity,
  });

  final Map<SkillLevel, int> distribution;
  final int capacity;

  @override
  Widget build(BuildContext context) {
    final filled = distribution.values.fold(0, (a, b) => a + b);
    final empty = (capacity - filled).clamp(0, capacity);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: 8,
            child: Row(
              children: [
                for (final level in SkillLevel.values)
                  if ((distribution[level] ?? 0) > 0)
                    Expanded(
                      flex: distribution[level]!,
                      child: ColoredBox(color: level.color),
                    ),
                if (empty > 0)
                  Expanded(
                    flex: empty,
                    child: const ColoredBox(color: AppColors.outline),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 12,
          runSpacing: 6,
          children: [
            for (final level in SkillLevel.values)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: level.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    context.l10n.rankCount(
                      level.rank,
                      distribution[level] ?? 0,
                    ),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/models/skill_level.dart';
import '../l10n/l10n_extensions.dart';
import '../theme/app_colors.dart';

/// Row of six tappable rank tiles (1 = strongest … 6 = weakest).
class SkillSelector extends StatelessWidget {
  const SkillSelector({
    super.key,
    required this.selected,
    required this.onChanged,
    this.errorText,
  });

  final SkillLevel? selected;
  final ValueChanged<SkillLevel> onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final current = selected;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            for (final level in SkillLevel.values)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: _SkillTile(
                    level: level,
                    isSelected: level == current,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onChanged(level);
                    },
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            current == null
                ? l10n.skillHint
                : l10n.skillSelectedSummary(
                    current.rank,
                    current.label(l10n),
                    current.score,
                  ),
            key: ValueKey(current),
            style: theme.textTheme.bodySmall?.copyWith(
              color: current?.color ?? AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Text(
            errorText!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.danger,
            ),
          ),
        ],
      ],
    );
  }
}

class _SkillTile extends StatelessWidget {
  const _SkillTile({
    required this.level,
    required this.isSelected,
    required this.onTap,
  });

  final SkillLevel level;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = level.color;
    return Semantics(
      button: true,
      selected: isSelected,
      label: context.l10n.skillSemantics(
        level.rank,
        level.label(context.l10n),
      ),
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          height: 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? color : AppColors.surfaceRaised,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? color : AppColors.outline,
              width: 1.4,
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Text(
            '${level.rank}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: isSelected ? AppColors.onAccent : color,
            ),
          ),
        ),
      ),
    );
  }
}

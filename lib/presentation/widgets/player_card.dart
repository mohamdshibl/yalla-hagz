import 'package:flutter/material.dart';

import '../../domain/models/player.dart';
import '../l10n/l10n_extensions.dart';
import '../theme/app_colors.dart';
import 'skill_badge.dart';

/// Row card for a player in the pool. Tapping toggles whether the player is
/// selected for the next match; the pencil opens the editor.
class PlayerCard extends StatelessWidget {
  const PlayerCard({
    super.key,
    required this.player,
    required this.isSelected,
    this.isDuplicateName = false,
    this.onToggleSelected,
    this.onEdit,
  });

  final Player player;
  final bool isSelected;
  final bool isDuplicateName;
  final VoidCallback? onToggleSelected;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final skill = player.skill;

    return Semantics(
      selected: isSelected,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isSelected ? 1 : 0.62,
        child: Material(
          color: isSelected
              ? AppColors.surfaceRaised
              : AppColors.surface.withValues(alpha: 0.8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(
              color: isSelected
                  ? AppColors.accent.withValues(alpha: 0.55)
                  : AppColors.outline,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onToggleSelected,
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(12, 10, 4, 10),
              child: Row(
                children: [
                  _SelectionMark(isSelected: isSelected),
                  const SizedBox(width: 12),
                  SkillBadge(skill: skill, size: 40),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          player.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                l10n.skillSummary(
                                  skill.label(l10n),
                                  skill.score,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            if (isDuplicateName) ...[
                              const SizedBox(width: 8),
                              const _DuplicateTag(),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.editPlayerTooltip(player.name),
                    onPressed: onEdit,
                    icon: const Icon(
                      Icons.edit_outlined,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectionMark extends StatelessWidget {
  const _SelectionMark({required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? AppColors.accent : Colors.transparent,
        border: Border.all(
          color: isSelected ? AppColors.accent : AppColors.textSecondary,
          width: 2,
        ),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 150),
        transitionBuilder: (child, animation) =>
            ScaleTransition(scale: animation, child: child),
        child: isSelected
            ? const Icon(
                Icons.check_rounded,
                key: ValueKey(true),
                size: 17,
                color: AppColors.onAccent,
              )
            : const SizedBox.shrink(key: ValueKey(false)),
      ),
    );
  }
}

class _DuplicateTag extends StatelessWidget {
  const _DuplicateTag();

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: context.l10n.sameNameTooltip,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          context.l10n.sameName,
          style: const TextStyle(
            color: AppColors.warning,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

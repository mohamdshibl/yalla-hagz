import 'package:flutter/material.dart';

import '../../domain/models/skill_level.dart';
import '../l10n/l10n_extensions.dart';
import '../theme/app_colors.dart';

/// Coloured square showing a player's rank (1 = strongest).
class SkillBadge extends StatelessWidget {
  const SkillBadge({super.key, required this.skill, this.size = 36});

  final SkillLevel skill;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = skill.color;
    return Semantics(
      label: context.l10n.skillSemantics(
        skill.rank,
        skill.label(context.l10n),
      ),
      excludeSemantics: true,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(size * 0.32),
          border: Border.all(color: color.withValues(alpha: 0.75), width: 1.5),
        ),
        child: Text(
          '${skill.rank}',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w900,
            fontSize: size * 0.45,
            height: 1,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../domain/models/player.dart';
import '../../domain/models/team.dart';
import '../l10n/l10n_extensions.dart';
import '../theme/app_colors.dart';
import 'reveal_transition.dart';
import 'skill_badge.dart';

/// A team "kit card": coloured header with strength, followed by players
/// that pop in one after another as [reveal] runs.
class TeamCard extends StatelessWidget {
  const TeamCard({
    super.key,
    required this.team,
    required this.color,
    required this.displayNameOf,
    required this.reveal,
  });

  final Team team;
  final Color color;
  final String Function(Player player) displayNameOf;
  final Animation<double> reveal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 18, 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: AlignmentDirectional.centerStart,
                end: AlignmentDirectional.centerEnd,
                colors: [
                  color.withValues(alpha: 0.30),
                  color.withValues(alpha: 0.04),
                ],
              ),
            ),
            child: Row(
              children: [
                _Crest(label: team.localizedLabel(l10n), color: color),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        team.localizedName(l10n),
                        style: theme.textTheme.titleLarge,
                      ),
                      Text(
                        l10n.teamSubtitle(
                          team.averageRank.toStringAsFixed(1),
                          team.players.length,
                        ),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${team.totalStrength}',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      l10n.strengthLabel,
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: context.tracking(1.6),
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              children: [
                for (var i = 0; i < team.players.length; i++)
                  RevealTransition(
                    offset: const Offset(0.08, 0),
                    animation: reveal.interval(0.25 + i * 0.1, 0.6 + i * 0.1),
                    child: _TeamPlayerRow(
                      number: i + 1,
                      name: displayNameOf(team.players[i]),
                      player: team.players[i],
                      color: color,
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

class _Crest extends StatelessWidget {
  const _Crest({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
          bottomLeft: Radius.circular(23),
          bottomRight: Radius.circular(23),
        ),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 12),
        ],
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w900,
          color: AppColors.onAccent,
        ),
      ),
    );
  }
}

class _TeamPlayerRow extends StatelessWidget {
  const _TeamPlayerRow({
    required this.number,
    required this.name,
    required this.player,
    required this.color,
  });

  final int number;
  final String name;
  final Player player;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.14),
              border: Border.all(color: color.withValues(alpha: 0.6)),
            ),
            child: Text(
              '$number',
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            player.skill.label(context.l10n),
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 10),
          SkillBadge(skill: player.skill, size: 30),
        ],
      ),
    );
  }
}

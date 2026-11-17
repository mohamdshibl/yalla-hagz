import 'package:flutter/material.dart';

import '../../domain/models/player.dart';
import '../l10n/l10n_extensions.dart';
import '../theme/app_colors.dart';
import 'skill_badge.dart';

/// Bottom sheet listing bench players who can come in for [outgoing].
/// Resolves to the chosen player, or `null` if dismissed.
Future<Player?> showSubstituteSheet(
  BuildContext context, {
  required Player outgoing,
  required List<Player> bench,
  required String Function(Player player) displayNameOf,
}) {
  return showModalBottomSheet<Player>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => _SubstituteSheet(
      outgoing: outgoing,
      bench: bench,
      displayNameOf: displayNameOf,
    ),
  );
}

class _SubstituteSheet extends StatelessWidget {
  const _SubstituteSheet({
    required this.outgoing,
    required this.bench,
    required this.displayNameOf,
  });

  final Player outgoing;
  final List<Player> bench;
  final String Function(Player player) displayNameOf;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.75,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.substituteTitle(displayNameOf(outgoing)),
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.substituteSubtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (bench.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              child: Row(
                children: [
                  const Icon(
                    Icons.event_seat_outlined,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.benchEmpty,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.only(bottom: 16),
                itemCount: bench.length,
                itemBuilder: (context, i) {
                  final player = bench[i];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    leading: SkillBadge(skill: player.skill, size: 34),
                    title: Text(
                      displayNameOf(player),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(player.skill.label(l10n)),
                    trailing: _StrengthDelta(
                      delta: player.score - outgoing.score,
                    ),
                    onTap: () => Navigator.of(context).pop(player),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

/// How the team's strength changes if this player comes in.
class _StrengthDelta extends StatelessWidget {
  const _StrengthDelta({required this.delta});

  final int delta;

  @override
  Widget build(BuildContext context) {
    final color = delta == 0
        ? AppColors.accent
        : delta > 0
        ? AppColors.warning
        : AppColors.danger;
    final text = delta == 0
        ? '='
        : delta > 0
        ? '+$delta'
        : '−${-delta}';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        textDirection: TextDirection.ltr,
        style: TextStyle(color: color, fontWeight: FontWeight.w800),
      ),
    );
  }
}

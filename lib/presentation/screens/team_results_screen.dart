import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/models/player.dart';
import '../../domain/models/team_generation_result.dart';
import '../../domain/services/team_balancer.dart';
import '../controllers/roster_controller.dart';
import '../controllers/roster_scope.dart';
import '../l10n/l10n_extensions.dart';
import '../theme/app_colors.dart';
import '../widgets/balance_indicator.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/drawing_view.dart';
import '../widgets/pitch_background.dart';
import '../widgets/primary_button.dart';
import '../widgets/reveal_transition.dart';
import '../widgets/substitute_sheet.dart';
import '../widgets/team_card.dart';

class TeamResultsScreen extends StatefulWidget {
  const TeamResultsScreen({super.key});

  @override
  State<TeamResultsScreen> createState() => _TeamResultsScreenState();
}

class _TeamResultsScreenState extends State<TeamResultsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _reveal = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1900),
  );

  TeamGenerationResult? _result;
  bool _isDrawing = true;
  int _drawCount = 0;

  /// Player picked as the first half of a swap.
  String? _swapSourceId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _draw());
  }

  @override
  void dispose() {
    _reveal.dispose();
    super.dispose();
  }

  RosterController get _roster => RosterScope.read(context);

  Future<void> _draw() async {
    setState(() => _isDrawing = true);

    final TeamGenerationResult result;
    try {
      result = _roster.generateTeams();
    } on TeamGenerationException catch (error) {
      if (!mounted) return;
      final l10n = context.l10n;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.issue?.message(l10n) ?? l10n.generationFailed),
        ),
      );
      Navigator.of(context).pop();
      return;
    }

    // A short "draw" moment builds anticipation before the reveal.
    await Future<void>.delayed(
      Duration(milliseconds: _drawCount == 0 ? 1300 : 800),
    );
    if (!mounted) return;

    HapticFeedback.mediumImpact();
    setState(() {
      _result = result;
      _isDrawing = false;
      _swapSourceId = null;
      _drawCount++;
    });
    _reveal.forward(from: 0);
  }

  Player? _findPlayer(String? id) {
    final result = _result;
    if (id == null || result == null) return null;
    for (final team in result.teams) {
      for (final player in team.players) {
        if (player.id == id) return player;
      }
    }
    return null;
  }

  void _onPlayerTap(Player player) {
    final result = _result;
    if (result == null) return;
    final sourceId = _swapSourceId;

    // First pick, re-pick within the same team, or un-pick.
    if (sourceId == null ||
        sourceId == player.id ||
        result.teamIndexOf(sourceId) == result.teamIndexOf(player.id)) {
      HapticFeedback.selectionClick();
      setState(() => _swapSourceId = sourceId == player.id ? null : player.id);
      return;
    }
    _swap(result, sourceId, player.id, showUndo: true);
  }

  void _swap(
    TeamGenerationResult result,
    String firstId,
    String secondId, {
    required bool showUndo,
  }) {
    final edited = _roster.swapPlayers(result, firstId, secondId);
    HapticFeedback.lightImpact();
    setState(() {
      _result = edited;
      _swapSourceId = null;
    });
    if (!showUndo) return;

    final l10n = context.l10n;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            l10n.playersSwapped(
              _roster.displayNameOf(_findPlayer(firstId)!),
              _roster.displayNameOf(_findPlayer(secondId)!),
            ),
          ),
          action: SnackBarAction(
            label: l10n.undo,
            onPressed: () {
              // Only undo if nothing else changed the line-up meanwhile.
              if (!mounted || !identical(_result, edited)) return;
              _swap(edited, firstId, secondId, showUndo: false);
            },
          ),
        ),
      );
  }

  Future<void> _openSubstitute(Player outgoing) async {
    final result = _result;
    if (result == null) return;
    HapticFeedback.selectionClick();
    setState(() => _swapSourceId = null);

    final incoming = await showSubstituteSheet(
      context,
      outgoing: outgoing,
      bench: _roster.benchFor(result, outgoing),
      displayNameOf: _roster.displayNameOf,
    );
    // Ignore if dismissed or the line-up changed while the sheet was open.
    if (incoming == null || !mounted || !identical(_result, result)) return;
    _substitute(result, outgoing.id, incoming.id, showUndo: true);
  }

  void _substitute(
    TeamGenerationResult result,
    String outgoingId,
    String incomingId, {
    required bool showUndo,
  }) {
    final outgoing = _findPlayer(outgoingId)!;
    final edited = _roster.substitutePlayer(result, outgoingId, incomingId);
    HapticFeedback.lightImpact();
    setState(() {
      _result = edited;
      _swapSourceId = null;
    });
    if (!showUndo) return;

    final l10n = context.l10n;
    final incoming = _findPlayer(incomingId)!;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            l10n.playerSubstituted(
              _roster.displayNameOf(incoming),
              _roster.displayNameOf(outgoing),
            ),
          ),
          action: SnackBarAction(
            label: l10n.undo,
            onPressed: () {
              if (!mounted || !identical(_result, edited)) return;
              _substitute(edited, incomingId, outgoingId, showUndo: false);
            },
          ),
        ),
      );
  }

  Future<void> _reset() async {
    final l10n = context.l10n;
    final confirmed = await showConfirmDialog(
      context,
      title: l10n.resetTitle,
      message: l10n.resetMessage(_roster.requiredCount),
      confirmLabel: l10n.reset,
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    _roster.clearSelection();
    Navigator.of(context).pop();
  }

  Future<void> _copyTeams() async {
    final result = _result;
    if (result == null) return;
    final l10n = context.l10n;
    final buffer = StringBuffer('${l10n.copyHeader}\n');
    for (final team in result.teams) {
      final teamLine = l10n.copyTeamLine(
        team.localizedName(l10n),
        team.totalStrength,
      );
      buffer.writeln('\n$teamLine');
      for (final player in team.players) {
        final line = l10n.copyPlayerLine(
          _roster.displayNameOf(player),
          player.skill.rank,
        );
        buffer.writeln('  • $line');
      }
    }
    await Clipboard.setData(ClipboardData(text: buffer.toString().trim()));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.teamsCopied)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final result = _result;
    final showResults = !_isDrawing && result != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.matchDay),
        leading: IconButton(
          tooltip: l10n.editPlayers,
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            tooltip: l10n.copyTeams,
            icon: const Icon(Icons.copy_all_rounded),
            onPressed: showResults ? _copyTeams : null,
          ),
        ],
      ),
      body: PitchBackground(
        glow: false,
        lineOpacity: 0.035,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: showResults
              ? _ResultsList(
                  key: ValueKey(_drawCount),
                  result: result,
                  reveal: _reveal,
                  displayNameOf: _roster.displayNameOf,
                  selectedPlayerId: _swapSourceId,
                  swapSourceName: switch (_findPlayer(_swapSourceId)) {
                    final player? => _roster.displayNameOf(player),
                    null => null,
                  },
                  onPlayerTap: _onPlayerTap,
                  onPlayerLongPress: _openSubstitute,
                  onSubstituteSelected: () {
                    final player = _findPlayer(_swapSourceId);
                    if (player != null) _openSubstitute(player);
                  },
                  onCancelSwap: () => setState(() => _swapSourceId = null),
                )
              : DrawingView(
                  key: const ValueKey('drawing'),
                  message: l10n.drawingTitle,
                  subtitle: l10n.drawingSubtitle,
                ),
        ),
      ),
      bottomNavigationBar: _ResultsActions(
        enabled: showResults,
        onReset: _reset,
        onEdit: () => Navigator.of(context).pop(),
        onRegenerate: _draw,
      ),
    );
  }
}

class _ResultsList extends StatelessWidget {
  const _ResultsList({
    super.key,
    required this.result,
    required this.reveal,
    required this.displayNameOf,
    required this.selectedPlayerId,
    required this.swapSourceName,
    required this.onPlayerTap,
    required this.onPlayerLongPress,
    required this.onSubstituteSelected,
    required this.onCancelSwap,
  });

  final TeamGenerationResult result;
  final Animation<double> reveal;
  final String Function(Player player) displayNameOf;
  final String? selectedPlayerId;
  final String? swapSourceName;
  final ValueChanged<Player> onPlayerTap;
  final ValueChanged<Player> onPlayerLongPress;
  final VoidCallback onSubstituteSelected;
  final VoidCallback onCancelSwap;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        RevealTransition(
          animation: reveal.interval(0, 0.3),
          child: BalanceIndicator(result: result),
        ),
        const SizedBox(height: 12),
        RevealTransition(
          animation: reveal.interval(0.1, 0.35),
          child: _SwapHint(
            sourceName: swapSourceName,
            onSubstitute: onSubstituteSelected,
            onCancel: onCancelSwap,
          ),
        ),
        const SizedBox(height: 12),
        for (final team in result.teams)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Builder(
              builder: (context) {
                final teamReveal = reveal.interval(
                  0.12 + team.index * 0.16,
                  0.6 + team.index * 0.16,
                );
                return RevealTransition(
                  animation: teamReveal,
                  offset: const Offset(0, 0.18),
                  child: TeamCard(
                    team: team,
                    color: AppColors.teamColor(team.index),
                    displayNameOf: displayNameOf,
                    reveal: teamReveal,
                    selectedPlayerId: selectedPlayerId,
                    onPlayerTap: onPlayerTap,
                    onPlayerLongPress: onPlayerLongPress,
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _SwapHint extends StatelessWidget {
  const _SwapHint({
    required this.sourceName,
    required this.onSubstitute,
    required this.onCancel,
  });

  final String? sourceName;
  final VoidCallback onSubstitute;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final name = sourceName;
    final active = name != null;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      constraints: const BoxConstraints(minHeight: 48),
      padding: const EdgeInsetsDirectional.fromSTEB(14, 4, 4, 4),
      decoration: BoxDecoration(
        color: active
            ? AppColors.accent.withValues(alpha: 0.12)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: active
              ? AppColors.accent.withValues(alpha: 0.5)
              : AppColors.outline,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.swap_horiz_rounded,
            size: 20,
            color: active ? AppColors.accent : AppColors.textSecondary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              active ? l10n.swapPickTarget(name) : l10n.swapHint,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: active ? null : AppColors.textSecondary,
              ),
            ),
          ),
          if (active)
            TextButton.icon(
              onPressed: onSubstitute,
              icon: const Icon(Icons.event_seat_rounded, size: 18),
              label: Text(l10n.substitute),
            ),
          if (active)
            IconButton(
              tooltip: l10n.cancelSwap,
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.close_rounded, size: 18),
              onPressed: onCancel,
            ),
        ],
      ),
    );
  }
}

class _ResultsActions extends StatelessWidget {
  const _ResultsActions({
    required this.enabled,
    required this.onReset,
    required this.onEdit,
    required this.onRegenerate,
  });

  final bool enabled;
  final VoidCallback onReset;
  final VoidCallback onEdit;
  final VoidCallback onRegenerate;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.outline)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              SizedBox.square(
                dimension: 58,
                child: IconButton.outlined(
                  tooltip: l10n.reset,
                  onPressed: enabled ? onReset : null,
                  style: IconButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: const BorderSide(color: AppColors.outline),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.restart_alt_rounded),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 58,
                child: OutlinedButton.icon(
                  onPressed: enabled ? onEdit : null,
                  icon: const Icon(Icons.edit_note_rounded),
                  label: Text(l10n.edit),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: PrimaryButton(
                  label: l10n.regenerate,
                  icon: Icons.shuffle_rounded,
                  enabled: enabled,
                  onPressed: enabled ? onRegenerate : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

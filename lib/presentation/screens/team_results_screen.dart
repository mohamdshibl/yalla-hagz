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
      _drawCount++;
    });
    _reveal.forward(from: 0);
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
  });

  final TeamGenerationResult result;
  final Animation<double> reveal;
  final String Function(Player player) displayNameOf;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        RevealTransition(
          animation: reveal.interval(0, 0.3),
          child: BalanceIndicator(result: result),
        ),
        const SizedBox(height: 16),
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
                  ),
                );
              },
            ),
          ),
      ],
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

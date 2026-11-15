import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/models/player.dart';
import '../../domain/services/player_display_names.dart';
import '../controllers/roster_controller.dart';
import '../controllers/roster_scope.dart';
import '../l10n/l10n_extensions.dart';
import '../navigation/fade_slide_route.dart';
import '../theme/app_colors.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/pitch_background.dart';
import '../widgets/player_card.dart';
import '../widgets/player_form_sheet.dart';
import '../widgets/primary_button.dart';
import '../widgets/roster_progress.dart';
import 'team_results_screen.dart';

enum _MenuAction { fillSample, sortBySkill, clearSelection, deleteAll }

enum _PoolFilter { all, selected, bench }

/// Manage the saved player pool and pick exactly 18 players for the match.
class PlayersSetupScreen extends StatefulWidget {
  const PlayersSetupScreen({super.key});

  @override
  State<PlayersSetupScreen> createState() => _PlayersSetupScreenState();
}

class _PlayersSetupScreenState extends State<PlayersSetupScreen> {
  final _searchController = TextEditingController();
  _PoolFilter _filter = _PoolFilter.all;
  String _query = '';

  RosterController get _roster => RosterScope.read(context);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  void _addPlayer() {
    final roster = _roster;
    PlayerFormSheet.show(
      context,
      onSubmit: (name, skill) => roster.addPlayer(name: name, skill: skill),
      isDuplicateName: roster.hasDuplicateName,
    );
  }

  void _editPlayer(Player player) {
    final roster = _roster;
    PlayerFormSheet.show(
      context,
      initial: player,
      onSubmit: (name, skill) =>
          roster.updatePlayer(player.id, name: name, skill: skill),
      isDuplicateName: (name) =>
          roster.hasDuplicateName(name, excludingId: player.id),
    );
  }

  void _toggle(Player player) {
    final change = _roster.toggleSelection(player.id);
    if (change == SelectionChange.limitReached) {
      HapticFeedback.heavyImpact();
      _showMessage(
        context.l10n.selectionLimitReached(_roster.requiredCount),
        isError: true,
      );
    } else {
      HapticFeedback.selectionClick();
    }
  }

  void _removePlayer(Player player) {
    final roster = _roster;
    final wasSelected = roster.isSelected(player);
    final index = roster.removePlayer(player.id);
    if (index < 0) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(context.l10n.playerDeleted(player.name)),
          action: SnackBarAction(
            label: context.l10n.undo,
            onPressed: () =>
                roster.restorePlayer(player, index, select: wasSelected),
          ),
        ),
      );
  }

  Future<void> _onMenuSelected(_MenuAction action) async {
    final roster = _roster;
    final l10n = context.l10n;
    switch (action) {
      case _MenuAction.fillSample:
        final added = roster.fillWithSampleSquad(
          names: l10n.sampleNames.split(','),
        );
        _showMessage(l10n.sampleAdded(added));
      case _MenuAction.sortBySkill:
        roster.sortBySkill();
      case _MenuAction.clearSelection:
        roster.clearSelection();
      case _MenuAction.deleteAll:
        final confirmed = await showConfirmDialog(
          context,
          title: l10n.deleteAllTitle,
          message: l10n.deleteAllMessage(roster.poolSize),
          confirmLabel: l10n.deleteAllConfirm,
          destructive: true,
        );
        if (confirmed) roster.clearAll();
    }
  }

  void _generateTeams() {
    final blocker = _roster.generationBlocker;
    if (blocker != null) {
      _showMessage(blocker.message(context.l10n), isError: true);
      return;
    }
    Navigator.of(context).push(fadeSlideRoute(const TeamResultsScreen()));
  }

  void _showMessage(String text, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isError ? Icons.info_outline_rounded : Icons.check_rounded,
                color: isError ? AppColors.warning : AppColors.accent,
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(text)),
            ],
          ),
        ),
      );
  }

  List<Player> _visiblePlayers(RosterController roster) {
    final query = normalizeName(_query);
    return roster.players.where((p) {
      final matchesFilter = switch (_filter) {
        _PoolFilter.all => true,
        _PoolFilter.selected => roster.isSelected(p),
        _PoolFilter.bench => !roster.isSelected(p),
      };
      return matchesFilter &&
          (query.isEmpty || normalizeName(p.name).contains(query));
    }).toList();
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final roster = RosterScope.of(context);
    final visible = _visiblePlayers(roster);
    final hasPlayers = roster.poolSize > 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.playersTitle),
        actions: [
          PopupMenuButton<_MenuAction>(
            tooltip: l10n.menuMore,
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: _onMenuSelected,
            itemBuilder: (_) => [
              PopupMenuItem(
                value: _MenuAction.fillSample,
                enabled: !roster.isSelectionFull,
                child: ListTile(
                  leading: const Icon(Icons.auto_fix_high_rounded),
                  title: Text(l10n.menuFillSample),
                ),
              ),
              PopupMenuItem(
                value: _MenuAction.sortBySkill,
                enabled: roster.poolSize > 1,
                child: ListTile(
                  leading: const Icon(Icons.sort_rounded),
                  title: Text(l10n.menuSortBySkill),
                ),
              ),
              PopupMenuItem(
                value: _MenuAction.clearSelection,
                enabled: roster.selectedCount > 0,
                child: ListTile(
                  leading: const Icon(Icons.deselect_rounded),
                  title: Text(l10n.menuClearSelection),
                ),
              ),
              PopupMenuItem(
                value: _MenuAction.deleteAll,
                enabled: hasPlayers,
                child: ListTile(
                  leading: const Icon(
                    Icons.delete_sweep_rounded,
                    color: AppColors.danger,
                  ),
                  title: Text(l10n.menuDeleteAll),
                ),
              ),
            ],
          ),
        ],
      ),
      body: PitchBackground(
        glow: false,
        lineOpacity: 0.035,
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              sliver: SliverToBoxAdapter(
                child: RosterProgress(
                  selected: roster.selectedCount,
                  required: roster.requiredCount,
                  poolSize: roster.poolSize,
                  distribution: roster.selectedSkillDistribution,
                ),
              ),
            ),
            if (!hasPlayers)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyPool(
                  onAdd: _addPlayer,
                  onFillSample: () => _onMenuSelected(_MenuAction.fillSample),
                ),
              )
            else ...[
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                sliver: SliverToBoxAdapter(
                  child: _PoolToolbar(
                    searchController: _searchController,
                    onQueryChanged: (value) => setState(() => _query = value),
                    filter: _filter,
                    onFilterChanged: (value) => setState(() => _filter = value),
                    total: roster.poolSize,
                    selected: roster.selectedCount,
                  ),
                ),
              ),
              if (visible.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      l10n.noPlayersMatch,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  sliver: SliverList.separated(
                    itemCount: visible.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final player = visible[index];
                      return Dismissible(
                        key: ValueKey(player.id),
                        direction: DismissDirection.endToStart,
                        background: const _DeleteBackground(),
                        onDismissed: (_) => _removePlayer(player),
                        child: PlayerCard(
                          player: player,
                          isSelected: roster.isSelected(player),
                          isDuplicateName: roster.isDuplicate(player),
                          onToggleSelected: () => _toggle(player),
                          onEdit: () => _editPlayer(player),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: _SetupActions(
        isReady: roster.isReadyToGenerate,
        selected: roster.selectedCount,
        required: roster.requiredCount,
        onAdd: _addPlayer,
        onGenerate: _generateTeams,
      ),
    );
  }
}

class _PoolToolbar extends StatelessWidget {
  const _PoolToolbar({
    required this.searchController,
    required this.onQueryChanged,
    required this.filter,
    required this.onFilterChanged,
    required this.total,
    required this.selected,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onQueryChanged;
  final _PoolFilter filter;
  final ValueChanged<_PoolFilter> onFilterChanged;
  final int total;
  final int selected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final labels = {
      _PoolFilter.all: l10n.filterAll(total),
      _PoolFilter.selected: l10n.filterSelected(selected),
      _PoolFilter.bench: l10n.filterBench(total - selected),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: searchController,
          onChanged: onQueryChanged,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: l10n.searchPlayers,
            prefixIcon: const Icon(Icons.search_rounded),
            isDense: true,
            suffixIcon: searchController.text.isEmpty
                ? null
                : IconButton(
                    tooltip: l10n.clearSearch,
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () {
                      searchController.clear();
                      onQueryChanged('');
                    },
                  ),
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final entry in labels.entries)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(entry.value),
                    selected: filter == entry.key,
                    onSelected: (_) => onFilterChanged(entry.key),
                    showCheckmark: false,
                    selectedColor: AppColors.accent.withValues(alpha: 0.22),
                    backgroundColor: AppColors.surface,
                    side: BorderSide(
                      color: filter == entry.key
                          ? AppColors.accent
                          : AppColors.outline,
                    ),
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: filter == entry.key
                          ? AppColors.accentBright
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.poolHint,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _SetupActions extends StatelessWidget {
  const _SetupActions({
    required this.isReady,
    required this.selected,
    required this.required,
    required this.onAdd,
    required this.onGenerate,
  });

  final bool isReady;
  final int selected;
  final int required;
  final VoidCallback onAdd;
  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
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
              SizedBox(
                height: 58,
                child: OutlinedButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.person_add_alt_1_rounded),
                  label: Text(context.l10n.add),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PrimaryButton(
                  label: isReady
                      ? context.l10n.generateTeams
                      : context.l10n.generateProgress(selected, required),
                  icon: Icons.auto_awesome_rounded,
                  enabled: isReady,
                  onPressed: onGenerate,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyPool extends StatelessWidget {
  const _EmptyPool({required this.onAdd, required this.onFillSample});

  final VoidCallback onAdd;
  final VoidCallback onFillSample;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.groups_2_outlined,
            size: 72,
            color: AppColors.textSecondary.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 16),
          Text(l10n.emptyTitle, style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            l10n.emptyMessage(AppConstants.rosterSize),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.person_add_alt_1_rounded),
            label: Text(l10n.addFirstPlayer),
          ),
          TextButton(
            onPressed: onFillSample,
            child: Text(l10n.trySample),
          ),
        ],
      ),
    );
  }
}

class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: AlignmentDirectional.centerEnd,
      padding: const EdgeInsetsDirectional.only(end: 24),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            context.l10n.delete,
            style: const TextStyle(
              color: AppColors.danger,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
        ],
      ),
    );
  }
}

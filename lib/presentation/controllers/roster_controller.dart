import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../core/constants/app_constants.dart';
import '../../data/repositories/player_repository.dart';
import '../../domain/models/player.dart';
import '../../domain/models/skill_level.dart';
import '../../domain/models/team_generation_result.dart';
import '../../domain/services/player_display_names.dart';
import '../../domain/services/team_balancer.dart';
import '../../domain/validation/player_validator.dart';

enum SelectionChange { selected, deselected, limitReached }

/// Holds the saved player pool (any size) and the players selected for the
/// next match (exactly [requiredCount]), and bridges the UI with the
/// balancer and the repository.
class RosterController extends ChangeNotifier {
  RosterController({
    required PlayerRepository repository,
    required TeamBalancer balancer,
    Random? random,
  }) : _repository = repository,
       _balancer = balancer,
       _random = random ?? Random();

  final PlayerRepository _repository;
  final TeamBalancer _balancer;
  final Random _random;

  final List<Player> _players = [];
  final Set<String> _selectedIds = {};
  Map<String, String> _displayNames = const {};
  TeamGenerationResult? _lastResult;
  int _idCounter = 0;

  // ---------------------------------------------------------------------------
  // Read-only state
  // ---------------------------------------------------------------------------

  /// The whole saved pool, in the user's order.
  UnmodifiableListView<Player> get players => UnmodifiableListView(_players);
  int get poolSize => _players.length;

  /// Players picked for the next match, in pool order.
  List<Player> get selectedPlayers =>
      List.unmodifiable(_players.where((p) => _selectedIds.contains(p.id)));
  int get selectedCount => _selectedIds.length;
  int get requiredCount => AppConstants.rosterSize;
  int get remainingSelections => max(0, requiredCount - selectedCount);
  bool get isSelectionFull => selectedCount >= requiredCount;
  bool isSelected(Player player) => _selectedIds.contains(player.id);

  /// Why teams can't be generated yet, or `null` when the line-up is ready.
  SelectionIssue? get generationBlocker =>
      PlayerValidator.validateSelectionForGeneration(
        selectedPlayers,
        poolSize: poolSize,
      );
  bool get isReadyToGenerate => generationBlocker == null;

  TeamGenerationResult? get lastResult => _lastResult;

  String displayNameOf(Player player) =>
      _displayNames[player.id] ?? player.name;

  /// Rank mix of the *selected* players.
  Map<SkillLevel, int> get selectedSkillDistribution {
    final selected = selectedPlayers;
    return {
      for (final level in SkillLevel.values)
        level: selected.where((p) => p.skill == level).length,
    };
  }

  bool isDuplicate(Player player) =>
      hasDuplicateName(player.name, excludingId: player.id);

  bool hasDuplicateName(String name, {String? excludingId}) {
    final key = normalizeName(name);
    if (key.isEmpty) return false;
    return _players.any(
      (p) => p.id != excludingId && normalizeName(p.name) == key,
    );
  }

  // ---------------------------------------------------------------------------
  // Pool mutations
  // ---------------------------------------------------------------------------

  Future<void> load() async {
    try {
      final stored = await _repository.loadPlayers();
      final seenIds = <String>{};
      _players
        ..clear()
        ..addAll(stored.where((p) => seenIds.add(p.id)));

      final savedSelection = await _repository.loadSelectedIds();
      _selectedIds
        ..clear()
        ..addAll(
          _players
              .where((p) => savedSelection.contains(p.id))
              .take(requiredCount)
              .map((p) => p.id),
        );
    } catch (error) {
      debugPrint('Could not load saved players: $error');
    }
    _onChanged(persist: false);
  }

  /// Adds a player to the pool. While fewer than [requiredCount] players are
  /// selected, the new player is selected automatically.
  Player addPlayer({required String name, required SkillLevel skill}) {
    final player = Player(
      id: _generateId(),
      name: _requireValidName(name),
      skill: skill,
    );
    _players.add(player);
    if (!isSelectionFull) _selectedIds.add(player.id);
    _onChanged();
    return player;
  }

  void updatePlayer(
    String id, {
    required String name,
    required SkillLevel skill,
  }) {
    final index = _players.indexWhere((p) => p.id == id);
    if (index < 0) return;
    _players[index] = _players[index].copyWith(
      name: _requireValidName(name),
      skill: skill,
    );
    _onChanged();
  }

  /// Removes a player from the pool and returns its former index, or -1.
  int removePlayer(String id) {
    final index = _players.indexWhere((p) => p.id == id);
    if (index < 0) return -1;
    _players.removeAt(index);
    _selectedIds.remove(id);
    _onChanged();
    return index;
  }

  /// Undo for [removePlayer].
  void restorePlayer(Player player, int index, {bool select = false}) {
    if (_players.any((p) => p.id == player.id)) return;
    _players.insert(index.clamp(0, _players.length), player);
    if (select && !isSelectionFull) _selectedIds.add(player.id);
    _onChanged();
  }

  void sortBySkill() {
    _players.sort((a, b) {
      final byRank = a.skill.rank.compareTo(b.skill.rank);
      return byRank != 0
          ? byRank
          : a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    _onChanged();
  }

  /// Deletes every saved player.
  void clearAll() {
    _players.clear();
    _selectedIds.clear();
    _onChanged();
  }

  static const _defaultSampleNames = [
    'Ahmed', 'Omar', 'Youssef', 'Karim', 'Mostafa', 'Hassan', 'Ali', //
    'Mahmoud', 'Tarek', 'Amr', 'Khaled', 'Ziad', 'Hamza', 'Adam', //
    'Nour', 'Seif', 'Yassin', 'Marwan', 'Hesham', 'Sherif', 'Fady', //
    'Bassem', 'Walid', 'Ibrahim', 'Mazen', 'Hady', 'Ramy', 'Sameh', //
  ];

  /// Adds sample players until [requiredCount] are selected, using [names]
  /// (e.g. localised) when given. Returns how many players were added.
  int fillWithSampleSquad({List<String>? names}) {
    final candidates = (names ?? _defaultSampleNames)
        .map(PlayerValidator.sanitizeName)
        .where((n) => PlayerValidator.validateName(n) == null)
        .toSet();
    const rankPattern = [1, 1, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 5, 5, 5, 6, 6, 6];

    final ranks = List.of(rankPattern)..shuffle(_random);
    final available = candidates.where((n) => !hasDuplicateName(n)).toList()
      ..shuffle(_random);

    var added = 0;
    while (!isSelectionFull && added < available.length) {
      final player = Player(
        id: _generateId(),
        name: available[added],
        skill: SkillLevel.fromRank(ranks[added % ranks.length])!,
      );
      _players.add(player);
      _selectedIds.add(player.id);
      added++;
    }
    if (added > 0) _onChanged();
    return added;
  }

  // ---------------------------------------------------------------------------
  // Selection
  // ---------------------------------------------------------------------------

  SelectionChange toggleSelection(String id) {
    if (_selectedIds.remove(id)) {
      _onChanged();
      return SelectionChange.deselected;
    }
    if (isSelectionFull) return SelectionChange.limitReached;
    if (!_players.any((p) => p.id == id)) return SelectionChange.deselected;
    _selectedIds.add(id);
    _onChanged();
    return SelectionChange.selected;
  }

  void clearSelection() {
    if (_selectedIds.isEmpty) return;
    _selectedIds.clear();
    _onChanged();
  }

  // ---------------------------------------------------------------------------
  // Teams
  // ---------------------------------------------------------------------------

  /// Balances the selected players. Repeated calls try to return a
  /// different line-up.
  TeamGenerationResult generateTeams() {
    final blocker = generationBlocker;
    if (blocker != null) {
      throw TeamGenerationException(blocker.toString(), issue: blocker);
    }
    final result = _balancer.generate(selectedPlayers, avoid: _lastResult);
    _lastResult = result;
    return result;
  }

  /// Swaps two players between teams in [result] (normally [lastResult])
  /// and remembers the edited line-up, so "Regenerate" avoids it.
  TeamGenerationResult swapPlayers(
    TeamGenerationResult result,
    String firstId,
    String secondId,
  ) {
    final edited = result.swapPlayers(firstId, secondId);
    _lastResult = edited;
    return edited;
  }

  // ---------------------------------------------------------------------------
  // Internals
  // ---------------------------------------------------------------------------

  String _requireValidName(String raw) {
    final issue = PlayerValidator.validateName(raw);
    if (issue != null) throw ArgumentError.value(raw, 'name', issue.name);
    return PlayerValidator.sanitizeName(raw);
  }

  String _generateId() =>
      '${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}'
      '-${(_idCounter++).toRadixString(36)}'
      '-${_random.nextInt(0x7fffffff).toRadixString(36)}';

  void _onChanged({bool persist = true}) {
    _lastResult = null;
    _displayNames = buildDisplayNames(_players);
    notifyListeners();
    if (persist) unawaited(_persist());
  }

  Future<void> _persist() async {
    try {
      await _repository.savePlayers(List.of(_players));
      await _repository.saveSelectedIds(Set.of(_selectedIds));
    } catch (error) {
      debugPrint('Could not save players: $error');
    }
  }
}

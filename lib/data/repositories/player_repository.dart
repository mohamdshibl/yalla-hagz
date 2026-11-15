import '../../domain/models/player.dart';

/// Storage abstraction for the player pool and the current match selection,
/// so the UI/controller never depends on a concrete persistence technology.
abstract interface class PlayerRepository {
  Future<List<Player>> loadPlayers();

  Future<void> savePlayers(List<Player> players);

  /// Ids of the players picked for the next match.
  Future<Set<String>> loadSelectedIds();

  Future<void> saveSelectedIds(Set<String> ids);
}

/// Non-persistent implementation, handy for tests and previews.
class InMemoryPlayerRepository implements PlayerRepository {
  InMemoryPlayerRepository([
    List<Player> initial = const [],
    Set<String> selected = const {},
  ]) : _players = List.of(initial),
       _selectedIds = Set.of(selected);

  List<Player> _players;
  Set<String> _selectedIds;

  @override
  Future<List<Player>> loadPlayers() async => List.of(_players);

  @override
  Future<void> savePlayers(List<Player> players) async {
    _players = List.of(players);
  }

  @override
  Future<Set<String>> loadSelectedIds() async => Set.of(_selectedIds);

  @override
  Future<void> saveSelectedIds(Set<String> ids) async {
    _selectedIds = Set.of(ids);
  }
}

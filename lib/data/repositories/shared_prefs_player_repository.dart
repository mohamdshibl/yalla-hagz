import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/player.dart';
import 'player_repository.dart';

/// Persists the player pool (as JSON) and the match selection locally so
/// both survive app restarts.
class SharedPrefsPlayerRepository implements PlayerRepository {
  static const String _playersKey = 'kora.players.v1';
  static const String _selectionKey = 'kora.selection.v1';

  @override
  Future<List<Player>> loadPlayers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_playersKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      // Corrupt or invalid entries (e.g. rank outside 1–6) are skipped.
      return decoded.map(Player.tryFromJson).whereType<Player>().toList();
    } on FormatException {
      return [];
    }
  }

  @override
  Future<void> savePlayers(List<Player> players) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _playersKey,
      jsonEncode([for (final p in players) p.toJson()]),
    );
  }

  @override
  Future<Set<String>> loadSelectedIds() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_selectionKey) ?? const []).toSet();
  }

  @override
  Future<void> saveSelectedIds(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_selectionKey, ids.toList());
  }
}

import 'package:flutter/foundation.dart' show immutable;

import 'player.dart';
import 'skill_level.dart';

@immutable
class Team {
  Team({required this.index, required List<Player> players})
    : players = List.unmodifiable(players);

  /// Zero-based position: 0 → Team A, 1 → Team B, …
  final int index;
  final List<Player> players;

  String get label => String.fromCharCode('A'.codeUnitAt(0) + index);
  String get name => 'Team $label';

  int get totalStrength => players.fold(0, (sum, p) => sum + p.score);

  double get averageRank => players.isEmpty
      ? 0
      : players.fold(0, (sum, p) => sum + p.skill.rank) / players.length;

  int countOf(SkillLevel level) =>
      players.where((p) => p.skill == level).length;
}

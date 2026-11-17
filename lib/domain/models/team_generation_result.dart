import 'dart:math';

import 'package:flutter/foundation.dart' show immutable;

import 'player.dart';
import 'team.dart';

/// How close the team strengths are. Labels are localised in the UI.
enum BalanceRating { perfect, excellent, good, bestPossible, uneven }

@immutable
class TeamGenerationResult {
  TeamGenerationResult({
    required List<Team> teams,
    required this.generatedAt,
    this.isEdited = false,
  }) : teams = List.unmodifiable(teams);

  final List<Team> teams;
  final DateTime generatedAt;

  /// `true` once players were moved by hand, so the split is no longer
  /// guaranteed to be the optimal one.
  final bool isEdited;

  Iterable<int> get _totals => teams.map((t) => t.totalStrength);

  int get maxStrength => _totals.reduce(max);
  int get minStrength => _totals.reduce(min);

  /// Difference between the strongest and the weakest team.
  int get strengthSpread => maxStrength - minStrength;

  /// 100% means all teams are identical in strength.
  double get balancePercent =>
      maxStrength == 0 ? 100 : minStrength / maxStrength * 100;

  BalanceRating get rating => switch (strengthSpread) {
    0 => BalanceRating.perfect,
    1 => BalanceRating.excellent,
    <= 3 => BalanceRating.good,
    _ => isEdited ? BalanceRating.uneven : BalanceRating.bestPossible,
  };

  /// Index of the team [playerId] plays for, or -1.
  int teamIndexOf(String playerId) =>
      teams.indexWhere((t) => t.players.any((p) => p.id == playerId));

  /// Returns a copy where the two players trade places. Team sizes stay the
  /// same. Throws [ArgumentError] if either player is missing or both are
  /// on the same team.
  TeamGenerationResult swapPlayers(String firstId, String secondId) {
    final firstTeam = teamIndexOf(firstId);
    final secondTeam = teamIndexOf(secondId);
    if (firstTeam < 0 || secondTeam < 0) {
      throw ArgumentError('Both players must be in a team.');
    }
    if (firstTeam == secondTeam) {
      throw ArgumentError('Players are already on the same team.');
    }
    final first = teams[firstTeam].players.firstWhere((p) => p.id == firstId);
    final second = teams[secondTeam].players.firstWhere(
      (p) => p.id == secondId,
    );

    List<Player> replace(Team team, String id, Player incoming) => [
      for (final p in team.players) p.id == id ? incoming : p,
    ];

    return TeamGenerationResult(
      teams: [
        for (final team in teams)
          if (team.index == teams[firstTeam].index)
            Team(index: team.index, players: replace(team, firstId, second))
          else if (team.index == teams[secondTeam].index)
            Team(index: team.index, players: replace(team, secondId, first))
          else
            team,
      ],
      generatedAt: generatedAt,
      isEdited: true,
    );
  }

  /// Label-independent fingerprint of who plays with whom. Two results with
  /// the same signature contain the same groups of players.
  String get signature {
    final groups =
        teams
            .map((t) => (t.players.map((p) => p.id).toList()..sort()).join(','))
            .toList()
          ..sort();
    return groups.join('|');
  }
}

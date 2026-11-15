import 'dart:math';

import 'package:flutter/foundation.dart' show immutable;

import 'team.dart';

/// How close the team strengths are. Labels are localised in the UI.
enum BalanceRating { perfect, excellent, good, bestPossible }

@immutable
class TeamGenerationResult {
  TeamGenerationResult({required List<Team> teams, required this.generatedAt})
    : teams = List.unmodifiable(teams);

  final List<Team> teams;
  final DateTime generatedAt;

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
    _ => BalanceRating.bestPossible,
  };

  /// Label-independent fingerprint of who plays with whom. Two results with
  /// the same signature contain the same groups of players.
  String get signature {
    final groups = teams
        .map((t) => (t.players.map((p) => p.id).toList()..sort()).join(','))
        .toList()
      ..sort();
    return groups.join('|');
  }
}

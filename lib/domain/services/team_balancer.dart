import 'dart:math';

import '../../core/constants/app_constants.dart';
import '../models/player.dart';
import '../models/skill_level.dart';
import '../models/team.dart';
import '../models/team_generation_result.dart';
import '../validation/player_validator.dart';

class TeamGenerationException implements Exception {
  const TeamGenerationException(this.message, {this.issue});

  /// Developer-facing description (not shown to users).
  final String message;

  /// The user-fixable cause, when known, so the UI can show a localised hint.
  final SelectionIssue? issue;

  @override
  String toString() => 'TeamGenerationException: $message';
}

/// Splits a squad into equally sized teams with the most even total strength.
///
/// ## How it works
/// Players of the same rank are interchangeable for strength purposes, so
/// rather than trying every one of the ~2.8 million ways to split 18 players,
/// the balancer enumerates every way to split each rank's *head-count*
/// across the teams (respecting the team size). That search is exhaustive,
/// so the chosen split is provably optimal, yet it runs in milliseconds.
///
/// Candidate splits are compared lexicographically by:
/// 1. **Strength spread** – strongest team total minus weakest team total.
/// 2. **Strength variance** – how far each team is from the average.
/// 3. **Rank spread** – how unevenly each rank is shared between teams, so
///    strong (or weak) players are not stacked on one team.
///
/// Among equally optimal splits one is chosen at random and players inside
/// each rank are shuffled, so regenerating yields a different – but equally
/// fair – line-up.
class TeamBalancer {
  TeamBalancer({
    Random? random,
    this.teamCount = AppConstants.teamCount,
    this.playersPerTeam = AppConstants.playersPerTeam,
  }) : assert(teamCount > 1 && playersPerTeam > 0),
       _random = random ?? Random();

  final int teamCount;
  final int playersPerTeam;
  final Random _random;

  static const int _maxRepeatAttempts = 12;

  int get requiredPlayers => teamCount * playersPerTeam;

  /// Generates balanced teams. When [avoid] is given, the balancer tries to
  /// return a different grouping of players (useful for "Regenerate").
  TeamGenerationResult generate(
    List<Player> players, {
    TeamGenerationResult? avoid,
  }) {
    _validateInput(players);

    final tiers = _groupByTier(players);
    final plans = _findOptimalPlans(tiers);

    late TeamGenerationResult result;
    for (var attempt = 0; attempt < _maxRepeatAttempts; attempt++) {
      final plan = plans[_random.nextInt(plans.length)];
      result = _buildResult(tiers, plan);
      if (avoid == null || result.signature != avoid.signature) break;
    }

    _verifyResult(players, result);
    return result;
  }

  // ---------------------------------------------------------------------------
  // Validation
  // ---------------------------------------------------------------------------

  void _validateInput(List<Player> players) {
    if (players.length != requiredPlayers) {
      throw TeamGenerationException(
        'Exactly $requiredPlayers players are required '
        '(currently ${players.length}).',
      );
    }
    final ids = <String>{};
    for (final player in players) {
      if (player.name.trim().isEmpty) {
        throw const TeamGenerationException('Every player needs a name.');
      }
      if (!ids.add(player.id)) {
        throw TeamGenerationException(
          'Player "${player.name}" appears more than once.',
        );
      }
    }
  }

  /// Safety net: every player must appear in exactly one team.
  void _verifyResult(List<Player> players, TeamGenerationResult result) {
    final assigned = <String>{};
    for (final team in result.teams) {
      if (team.players.length != playersPerTeam) {
        throw StateError('${team.name} has ${team.players.length} players.');
      }
      for (final player in team.players) {
        if (!assigned.add(player.id)) {
          throw StateError('${player.name} was assigned twice.');
        }
      }
    }
    if (assigned.length != players.length ||
        !players.every((p) => assigned.contains(p.id))) {
      throw StateError('Not every player was assigned to a team.');
    }
  }

  // ---------------------------------------------------------------------------
  // Search
  // ---------------------------------------------------------------------------

  List<_Tier> _groupByTier(List<Player> players) => [
    for (final level in SkillLevel.values)
      if (players.any((p) => p.skill == level))
        _Tier(level, players.where((p) => p.skill == level).toList()),
  ];

  /// Returns every allocation plan with the lowest cost.
  /// A plan is `plan[tierIndex][teamIndex] = number of players`.
  List<List<List<int>>> _findOptimalPlans(List<_Tier> tiers) {
    final capacity = List<int>.filled(teamCount, playersPerTeam);
    final totals = List<int>.filled(teamCount, 0);
    final allocations = <List<int>>[];

    _Cost? best;
    final bestPlans = <List<List<int>>>[];

    void visitTier(int tierIndex) {
      if (tierIndex == tiers.length) {
        final cost = _evaluate(tiers, allocations, totals);
        final comparison = best == null ? -1 : cost.compareTo(best!);
        if (comparison < 0) {
          best = cost;
          bestPlans.clear();
        }
        if (comparison <= 0) {
          bestPlans.add([for (final a in allocations) List.of(a)]);
        }
        return;
      }

      final tier = tiers[tierIndex];
      final allocation = List<int>.filled(teamCount, 0);

      void distribute(int team, int remaining) {
        if (team == teamCount) {
          if (remaining != 0) return;
          for (var i = 0; i < teamCount; i++) {
            capacity[i] -= allocation[i];
            totals[i] += allocation[i] * tier.level.score;
          }
          allocations.add(List.of(allocation));
          visitTier(tierIndex + 1);
          allocations.removeLast();
          for (var i = 0; i < teamCount; i++) {
            capacity[i] += allocation[i];
            totals[i] -= allocation[i] * tier.level.score;
          }
          return;
        }
        var laterCapacity = 0;
        for (var i = team + 1; i < teamCount; i++) {
          laterCapacity += capacity[i];
        }
        final lowest = max(0, remaining - laterCapacity);
        final highest = min(remaining, capacity[team]);
        for (var n = lowest; n <= highest; n++) {
          allocation[team] = n;
          distribute(team + 1, remaining - n);
        }
      }

      distribute(0, tier.players.length);
    }

    visitTier(0);
    return bestPlans;
  }

  _Cost _evaluate(
    List<_Tier> tiers,
    List<List<int>> allocations,
    List<int> totals,
  ) {
    final sum = totals.fold(0, (a, b) => a + b);
    var deviation = 0;
    for (final total in totals) {
      final d = teamCount * total - sum; // scaled to stay in integers
      deviation += d * d;
    }

    var tierImbalance = 0;
    for (var t = 0; t < tiers.length; t++) {
      final n = tiers[t].players.length;
      for (final count in allocations[t]) {
        final d = teamCount * count - n;
        tierImbalance += d * d;
      }
    }

    return _Cost(totals.reduce(max) - totals.reduce(min), deviation,
        tierImbalance);
  }

  // ---------------------------------------------------------------------------
  // Result
  // ---------------------------------------------------------------------------

  TeamGenerationResult _buildResult(List<_Tier> tiers, List<List<int>> plan) {
    final rosters = List.generate(teamCount, (_) => <Player>[]);
    for (var t = 0; t < tiers.length; t++) {
      final pool = List.of(tiers[t].players)..shuffle(_random);
      var cursor = 0;
      for (var team = 0; team < teamCount; team++) {
        final count = plan[t][team];
        rosters[team].addAll(pool.sublist(cursor, cursor + count));
        cursor += count;
      }
    }

    return TeamGenerationResult(
      teams: [
        for (var i = 0; i < teamCount; i++)
          Team(index: i, players: rosters[i]..sort(_byStrengthThenName)),
      ],
      generatedAt: DateTime.now(),
    );
  }

  static int _byStrengthThenName(Player a, Player b) {
    final byRank = a.skill.rank.compareTo(b.skill.rank);
    return byRank != 0
        ? byRank
        : a.name.toLowerCase().compareTo(b.name.toLowerCase());
  }
}

class _Tier {
  _Tier(this.level, this.players);

  final SkillLevel level;
  final List<Player> players;
}

final class _Cost implements Comparable<_Cost> {
  const _Cost(this.spread, this.deviation, this.tierImbalance);

  final int spread;
  final int deviation;
  final int tierImbalance;

  @override
  int compareTo(_Cost other) {
    if (spread != other.spread) return spread.compareTo(other.spread);
    if (deviation != other.deviation) {
      return deviation.compareTo(other.deviation);
    }
    return tierImbalance.compareTo(other.tierImbalance);
  }
}

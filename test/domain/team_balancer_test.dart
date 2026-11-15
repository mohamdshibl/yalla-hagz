import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:kora/domain/models/player.dart';
import 'package:kora/domain/models/skill_level.dart';
import 'package:kora/domain/services/team_balancer.dart';

List<Player> rosterFromRanks(List<int> ranks) => [
  for (var i = 0; i < ranks.length; i++)
    Player(id: 'p$i', name: 'Player $i', skill: SkillLevel.fromRank(ranks[i])!),
];

List<int> randomRanks(Random random) =>
    List.generate(18, (_) => 1 + random.nextInt(6));

/// Exhaustive reference: tries every possible assignment of players.
int bruteForceMinSpread(List<Player> players) {
  final totals = [0, 0, 0];
  final sizes = [0, 0, 0];
  var best = 1 << 30;

  void assign(int i) {
    if (i == players.length) {
      final spread = totals.reduce(max) - totals.reduce(min);
      if (spread < best) best = spread;
      return;
    }
    // Player 0 always goes to team 0 (removes label symmetry).
    final teams = i == 0 ? 1 : 3;
    for (var t = 0; t < teams; t++) {
      if (sizes[t] == 6) continue;
      sizes[t]++;
      totals[t] += players[i].score;
      assign(i + 1);
      sizes[t]--;
      totals[t] -= players[i].score;
    }
  }

  assign(0);
  return best;
}

void main() {
  group('TeamBalancer', () {
    test('every player appears in exactly one team of six', () {
      final random = Random(7);
      final balancer = TeamBalancer(random: Random(1));
      for (var run = 0; run < 200; run++) {
        final players = rosterFromRanks(randomRanks(random));
        final result = balancer.generate(players);

        expect(result.teams, hasLength(3));
        final ids = <String>[];
        for (final team in result.teams) {
          expect(team.players, hasLength(6));
          ids.addAll(team.players.map((p) => p.id));
        }
        expect(ids.toSet(), players.map((p) => p.id).toSet());
        expect(ids, hasLength(18));
      }
    });

    test('matches the exhaustive brute-force optimum', () {
      final random = Random(42);
      final balancer = TeamBalancer(random: Random(3));
      for (var run = 0; run < 3; run++) {
        final players = rosterFromRanks(randomRanks(random));
        expect(
          balancer.generate(players).strengthSpread,
          bruteForceMinSpread(players),
        );
      }
    });

    test('three of each rank → identical teams with one of each rank', () {
      final players = rosterFromRanks([
        for (var r = 1; r <= 6; r++) ...[r, r, r],
      ]);
      final result = TeamBalancer(random: Random(5)).generate(players);

      expect(result.strengthSpread, 0);
      for (final team in result.teams) {
        for (final level in SkillLevel.values) {
          expect(team.countOf(level), 1);
        }
      }
    });

    test('does not stack top players on one team', () {
      // Three elite players and fifteen average ones.
      final players = rosterFromRanks([1, 1, 1, ...List.filled(15, 4)]);
      final result = TeamBalancer(random: Random(9)).generate(players);
      for (final team in result.teams) {
        expect(team.countOf(SkillLevel.elite), 1);
      }
    });

    test('regenerating produces a different but equally fair line-up', () {
      final players = rosterFromRanks([
        1, 1, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 5, 5, 5, 6, 6, 6, //
      ]);
      final balancer = TeamBalancer(random: Random(11));
      final first = balancer.generate(players);
      final second = balancer.generate(players, avoid: first);

      expect(second.signature, isNot(first.signature));
      expect(second.strengthSpread, first.strengthSpread);
    });

    test('rejects rosters that are not exactly 18 players', () {
      final balancer = TeamBalancer();
      expect(
        () => balancer.generate(rosterFromRanks(List.filled(17, 3))),
        throwsA(isA<TeamGenerationException>()),
      );
      expect(
        () => balancer.generate(rosterFromRanks(List.filled(19, 3))),
        throwsA(isA<TeamGenerationException>()),
      );
    });

    test('rejects the same player entered twice', () {
      final players = rosterFromRanks(List.filled(17, 3));
      players.add(players.first);
      expect(
        () => TeamBalancer().generate(players),
        throwsA(isA<TeamGenerationException>()),
      );
    });
  });
}

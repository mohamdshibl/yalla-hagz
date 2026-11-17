import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:kora/domain/models/player.dart';
import 'package:kora/domain/models/skill_level.dart';
import 'package:kora/domain/models/team_generation_result.dart';
import 'package:kora/domain/services/team_balancer.dart';

List<Player> rosterFromRanks(List<int> ranks) => [
  for (var i = 0; i < ranks.length; i++)
    Player(id: 'p$i', name: 'Player $i', skill: SkillLevel.fromRank(ranks[i])!),
];

void main() {
  late TeamGenerationResult result;

  setUp(() {
    final players = rosterFromRanks([
      for (var r = 1; r <= 6; r++) ...[r, r, r],
    ]);
    result = TeamBalancer(random: Random(5)).generate(players);
  });

  test('swapping trades two players between teams and keeps sizes', () {
    final a = result.teams[0].players.first; // rank 1
    final b = result.teams[1].players.last; // rank 6
    final edited = result.swapPlayers(a.id, b.id);

    expect(edited.isEdited, isTrue);
    expect(result.isEdited, isFalse);
    expect(edited.teamIndexOf(a.id), 1);
    expect(edited.teamIndexOf(b.id), 0);
    for (final team in edited.teams) {
      expect(team.players, hasLength(6));
    }
    expect(edited.teams[2].players, result.teams[2].players);
    expect(edited.strengthSpread, 10);
    expect(edited.rating, BalanceRating.uneven);
  });

  test('swapping back restores the original grouping', () {
    final a = result.teams[0].players.first.id;
    final b = result.teams[2].players.first.id;
    final back = result.swapPlayers(a, b).swapPlayers(a, b);
    expect(back.signature, result.signature);
  });

  test('rejects swaps within a team or with unknown players', () {
    final team = result.teams[0].players;
    expect(
      () => result.swapPlayers(team[0].id, team[1].id),
      throwsArgumentError,
    );
    expect(() => result.swapPlayers(team[0].id, 'nope'), throwsArgumentError);
  });
}

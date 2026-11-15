import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:kora/data/repositories/player_repository.dart';
import 'package:kora/domain/models/skill_level.dart';
import 'package:kora/domain/services/team_balancer.dart';
import 'package:kora/domain/validation/player_validator.dart';
import 'package:kora/presentation/controllers/roster_controller.dart';

RosterController newController([PlayerRepository? repository]) =>
    RosterController(
      repository: repository ?? InMemoryPlayerRepository(),
      balancer: TeamBalancer(random: Random(1)),
      random: Random(2),
    );

void addPlayers(RosterController c, int n) {
  for (var i = 0; i < n; i++) {
    c.addPlayer(name: 'P$i', skill: SkillLevel.fromRank(1 + i % 6)!);
  }
}

void main() {
  test('pool can hold more than 18 players; first 18 auto-selected', () {
    final c = newController();
    addPlayers(c, 25);
    expect(c.poolSize, 25);
    expect(c.selectedCount, 18);
    expect(c.isReadyToGenerate, isTrue);
  });

  test('cannot select a 19th player', () {
    final c = newController();
    addPlayers(c, 20);
    final bench = c.players.firstWhere((p) => !c.isSelected(p));
    expect(c.toggleSelection(bench.id), SelectionChange.limitReached);
    expect(c.selectedCount, 18);
  });

  test('teams are generated only from selected players', () {
    final c = newController();
    addPlayers(c, 24);
    // Swap: drop the first selected player, pick a bench player instead.
    final dropped = c.players.first;
    final picked = c.players.last;
    c.toggleSelection(dropped.id);
    c.toggleSelection(picked.id);

    final ids = c.generateTeams().teams
        .expand((t) => t.players)
        .map((p) => p.id)
        .toSet();
    expect(ids, hasLength(18));
    expect(ids, contains(picked.id));
    expect(ids, isNot(contains(dropped.id)));
    expect(ids, c.selectedPlayers.map((p) => p.id).toSet());
  });

  test('generation is blocked unless exactly 18 are selected', () {
    final c = newController();
    addPlayers(c, 20);
    c.toggleSelection(c.players.first.id);
    expect(
      c.generationBlocker,
      isA<NeedMoreSelected>().having((i) => i.missing, 'missing', 1),
    );
    expect(c.generateTeams, throwsA(isA<TeamGenerationException>()));
  });

  test('pool and selection survive a restart', () async {
    final repo = InMemoryPlayerRepository();
    final first = newController(repo);
    addPlayers(first, 22);
    first.toggleSelection(first.players.first.id);
    first.toggleSelection(first.players.last.id);
    await Future<void>.delayed(Duration.zero); // let async saves finish

    final second = newController(repo);
    await second.load();
    expect(second.poolSize, 22);
    expect(
      second.selectedPlayers.map((p) => p.id).toSet(),
      first.selectedPlayers.map((p) => p.id).toSet(),
    );
  });

  test('deleting a selected player frees a slot; undo restores it', () {
    final c = newController();
    addPlayers(c, 18);
    final player = c.players[3];
    final index = c.removePlayer(player.id);
    expect(c.selectedCount, 17);
    c.restorePlayer(player, index, select: true);
    expect(c.isSelected(player), isTrue);
    expect(c.players[3], player);
  });
}

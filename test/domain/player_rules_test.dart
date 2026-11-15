import 'package:flutter_test/flutter_test.dart';
import 'package:kora/domain/models/player.dart';
import 'package:kora/domain/models/skill_level.dart';
import 'package:kora/domain/services/player_display_names.dart';
import 'package:kora/domain/validation/player_validator.dart';

void main() {
  group('SkillLevel', () {
    test('rank 1 scores highest, rank 6 lowest', () {
      expect(SkillLevel.fromRank(1)!.score, 6);
      expect(SkillLevel.fromRank(6)!.score, 1);
    });

    test('invalid ranks are rejected', () {
      expect(SkillLevel.fromRank(0), isNull);
      expect(SkillLevel.fromRank(7), isNull);
      expect(SkillLevel.fromRank(null), isNull);
    });
  });

  group('PlayerValidator', () {
    test('empty or whitespace names are invalid', () {
      expect(PlayerValidator.validateName(''), isNotNull);
      expect(PlayerValidator.validateName('   '), isNotNull);
      expect(PlayerValidator.validateName(null), isNotNull);
      expect(PlayerValidator.validateName('Salah'), isNull);
    });

    test('too-long names are invalid', () {
      expect(PlayerValidator.validateName('x' * 40), NameIssue.tooLong);
      expect(PlayerValidator.validateName(' '), NameIssue.empty);
    });

    test('names are trimmed and whitespace collapsed', () {
      expect(PlayerValidator.sanitizeName('  Abou   Trika '), 'Abou Trika');
    });
  });

  group('Player JSON', () {
    test('round-trips and drops invalid entries', () {
      const player = Player(id: 'a', name: 'Ali', skill: SkillLevel.good);
      expect(Player.tryFromJson(player.toJson()), player);
      expect(Player.tryFromJson({'id': 'b', 'name': 'X', 'rank': 9}), isNull);
      expect(Player.tryFromJson({'id': 'c', 'name': ' ', 'rank': 2}), isNull);
      expect(Player.tryFromJson('garbage'), isNull);
    });
  });

  test('duplicate names get numbered display names', () {
    final names = buildDisplayNames(const [
      Player(id: '1', name: 'Ali', skill: SkillLevel.good),
      Player(id: '2', name: 'Omar', skill: SkillLevel.good),
      Player(id: '3', name: 'ALI', skill: SkillLevel.elite),
    ]);
    expect(names, {'1': 'Ali', '2': 'Omar', '3': 'ALI (2)'});
  });
}

import 'package:flutter/foundation.dart' show immutable;

import 'skill_level.dart';

/// A football player in the squad. Identity is the [id], so two players may
/// share the same name.
@immutable
class Player {
  const Player({required this.id, required this.name, required this.skill});

  final String id;
  final String name;
  final SkillLevel skill;

  int get score => skill.score;

  Player copyWith({String? name, SkillLevel? skill}) =>
      Player(id: id, name: name ?? this.name, skill: skill ?? this.skill);

  Map<String, Object?> toJson() => {'id': id, 'name': name, 'rank': skill.rank};

  /// Parses a stored player. Returns `null` for corrupt or invalid entries
  /// (missing id, empty name, rank outside 1–6) instead of throwing.
  static Player? tryFromJson(Object? json) {
    if (json is! Map) return null;
    final id = json['id'];
    final name = json['name'];
    final rank = json['rank'];
    final skill = SkillLevel.fromRank(rank is int ? rank : null);
    if (id is! String || id.isEmpty) return null;
    if (name is! String || name.trim().isEmpty) return null;
    if (skill == null) return null;
    return Player(id: id, name: name.trim(), skill: skill);
  }

  @override
  bool operator ==(Object other) =>
      other is Player &&
      other.id == id &&
      other.name == name &&
      other.skill == skill;

  @override
  int get hashCode => Object.hash(id, name, skill);

  @override
  String toString() => 'Player($name, rank ${skill.rank})';
}

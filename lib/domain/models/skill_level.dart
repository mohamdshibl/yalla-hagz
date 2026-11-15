/// Skill ranking of a player. Rank 1 is the strongest, rank 6 the weakest.
///
/// Display labels are localised in the presentation layer.
enum SkillLevel {
  elite(1),
  excellent(2),
  good(3),
  average(4),
  developing(5),
  beginner(6);

  const SkillLevel(this.rank);

  final int rank;

  static const int strongestRank = 1;
  static const int weakestRank = 6;

  /// Numeric strength used by the balancer: stronger players score higher.
  /// Rank 1 → 6 points … rank 6 → 1 point.
  int get score => weakestRank + 1 - rank;

  /// Returns the level for [rank], or `null` if the rank is outside 1–6.
  static SkillLevel? fromRank(int? rank) {
    for (final level in values) {
      if (level.rank == rank) return level;
    }
    return null;
  }
}

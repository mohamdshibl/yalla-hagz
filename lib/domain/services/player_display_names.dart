import '../models/player.dart';

/// Normalises a name for duplicate comparison ("  ali " == "Ali").
String normalizeName(String name) =>
    name.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

/// Builds a display name per player id. Duplicate names are allowed but get a
/// numeric suffix in insertion order so they stay distinguishable:
/// `Ali`, `Ali (2)`, `Ali (3)`.
Map<String, String> buildDisplayNames(Iterable<Player> players) {
  final totals = <String, int>{};
  for (final p in players) {
    totals.update(normalizeName(p.name), (n) => n + 1, ifAbsent: () => 1);
  }

  final seen = <String, int>{};
  return {
    for (final p in players)
      p.id: () {
        final key = normalizeName(p.name);
        if ((totals[key] ?? 0) < 2) return p.name;
        final occurrence = seen.update(key, (n) => n + 1, ifAbsent: () => 1);
        return occurrence == 1 ? p.name : '${p.name} ($occurrence)';
      }(),
  };
}

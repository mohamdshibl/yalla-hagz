import '../../core/constants/app_constants.dart';
import '../models/player.dart';

/// Why a player name is invalid. Messages are localised in the UI.
enum NameIssue { empty, tooLong }

/// Why the current selection can't be balanced yet.
sealed class SelectionIssue {
  const SelectionIssue();
}

/// The saved pool has fewer players than a match needs.
final class PoolTooSmall extends SelectionIssue {
  const PoolTooSmall(this.missing);
  final int missing;

  @override
  String toString() => 'Add $missing more player(s) to the pool.';
}

/// Not enough players are selected.
final class NeedMoreSelected extends SelectionIssue {
  const NeedMoreSelected({required this.missing, required this.selected});
  final int missing;
  final int selected;

  @override
  String toString() => 'Select $missing more player(s) ($selected selected).';
}

/// Too many players are selected.
final class TooManySelected extends SelectionIssue {
  const TooManySelected(this.extra);
  final int extra;

  @override
  String toString() => 'Deselect $extra player(s).';
}

/// A selected player has an invalid name (e.g. corrupted data).
final class InvalidSelectedName extends SelectionIssue {
  const InvalidSelectedName();

  @override
  String toString() => 'A selected player has an invalid name.';
}

abstract final class PlayerValidator {
  /// Trims and collapses inner whitespace.
  static String sanitizeName(String raw) =>
      raw.trim().replaceAll(RegExp(r'\s+'), ' ');

  static NameIssue? validateName(String? raw) {
    final name = sanitizeName(raw ?? '');
    if (name.isEmpty) return NameIssue.empty;
    if (name.length > AppConstants.maxNameLength) return NameIssue.tooLong;
    return null;
  }

  /// Returns why the [selected] players can't be balanced yet, or `null`
  /// when exactly the right number is selected. [poolSize] is the number of
  /// saved players, used for a more helpful hint.
  static SelectionIssue? validateSelectionForGeneration(
    List<Player> selected, {
    required int poolSize,
  }) {
    const required = AppConstants.rosterSize;
    final count = selected.length;

    if (poolSize < required) return PoolTooSmall(required - poolSize);
    if (count < required) {
      return NeedMoreSelected(missing: required - count, selected: count);
    }
    if (count > required) return TooManySelected(count - required);
    if (selected.any((p) => validateName(p.name) != null)) {
      return const InvalidSelectedName();
    }
    return null;
  }
}

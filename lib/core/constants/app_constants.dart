/// App-wide constants. Changing [teamCount] or [playersPerTeam] reshapes the
/// whole app (validation, balancing, UI) without further code changes.
abstract final class AppConstants {
  static const String appName = 'Kora Balance';

  static const int teamCount = 3;
  static const int playersPerTeam = 6;
  static const int rosterSize = teamCount * playersPerTeam;

  static const int maxNameLength = 24;
}

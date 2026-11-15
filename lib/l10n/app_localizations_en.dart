// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Kora Balance';

  @override
  String get brandName => 'KORA';

  @override
  String get brandTagline => 'TEAM BALANCER';

  @override
  String homeIntro(int rosterSize, int teamCount, int teamSize) {
    return 'Rank your $rosterSize players from 1 to 6 and get $teamCount evenly matched teams of $teamSize. No more one-sided games.';
  }

  @override
  String get statPlayers => 'Players';

  @override
  String get statTeams => 'Teams';

  @override
  String get statSkillRanks => 'Skill ranks';

  @override
  String get start => 'Start';

  @override
  String get continueReady => 'Continue – line-up ready';

  @override
  String continueSelected(int selected, int required) {
    return 'Continue ($selected/$required selected)';
  }

  @override
  String playersSaved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count players saved on this device',
      one: '1 player saved on this device',
    );
    return '$_temp0';
  }

  @override
  String get switchLanguage => 'العربية';

  @override
  String get changeLanguage => 'Change language';

  @override
  String get playersTitle => 'Players';

  @override
  String get menuMore => 'More';

  @override
  String get menuFillSample => 'Fill with sample players';

  @override
  String get menuSortBySkill => 'Sort by skill';

  @override
  String get menuClearSelection => 'Clear selection';

  @override
  String get menuDeleteAll => 'Delete all players';

  @override
  String selectionLimitReached(int required) {
    return '$required players are already selected. Deselect someone first.';
  }

  @override
  String playerDeleted(String name) {
    return '$name deleted from the pool';
  }

  @override
  String get undo => 'UNDO';

  @override
  String sampleAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Added $count sample players.',
      one: 'Added 1 sample player.',
      zero: 'No sample players added.',
    );
    return '$_temp0';
  }

  @override
  String get deleteAllTitle => 'Delete all players?';

  @override
  String deleteAllMessage(int count) {
    return 'All $count saved players will be removed from this device.';
  }

  @override
  String get deleteAllConfirm => 'Delete all';

  @override
  String get cancel => 'Cancel';

  @override
  String get noPlayersMatch => 'No players match.';

  @override
  String get searchPlayers => 'Search players';

  @override
  String get clearSearch => 'Clear search';

  @override
  String filterAll(int count) {
    return 'All $count';
  }

  @override
  String filterSelected(int count) {
    return 'Selected $count';
  }

  @override
  String filterBench(int count) {
    return 'Not selected $count';
  }

  @override
  String get poolHint => 'Tap a player to select or deselect · swipe to delete';

  @override
  String get add => 'Add';

  @override
  String get generateTeams => 'Generate Teams';

  @override
  String generateProgress(int selected, int required) {
    return 'Generate ($selected/$required)';
  }

  @override
  String get emptyTitle => 'No players yet';

  @override
  String emptyMessage(int required) {
    return 'Add everyone who plays with you and rank them from 1 (strongest) to 6. Each match, pick $required of them.';
  }

  @override
  String get addFirstPlayer => 'Add first player';

  @override
  String get trySample => 'or try a sample squad';

  @override
  String get delete => 'Delete';

  @override
  String editPlayerTooltip(String name) {
    return 'Edit $name';
  }

  @override
  String get sameName => 'Same name';

  @override
  String get sameNameTooltip =>
      'Another player has the same name. They will be numbered in the teams.';

  @override
  String skillSummary(String label, int points) {
    return '$label · $points pts';
  }

  @override
  String get lineupReadyTitle => 'Line-up ready!';

  @override
  String lineupReadyMessage(int required, int poolSize) {
    return '$required of your $poolSize players selected. Ready to kick off.';
  }

  @override
  String get buildPoolTitle => 'Build your player pool';

  @override
  String buildPoolMessage(int missing) {
    String _temp0 = intl.Intl.pluralLogic(
      missing,
      locale: localeName,
      other: 'Add $missing more players. You can save as many as you like.',
      one: 'Add 1 more player. You can save as many as you like.',
    );
    return '$_temp0';
  }

  @override
  String get pickPlayersTitle => 'Pick today’s players';

  @override
  String pickPlayersMessage(int missing, int poolSize) {
    return 'Select $missing more from your pool of $poolSize players.';
  }

  @override
  String rankCount(int rank, int count) {
    return 'R$rank ×$count';
  }

  @override
  String get addPlayerTitle => 'Add player';

  @override
  String get editPlayerTitle => 'Edit player';

  @override
  String get editPlayerSubtitle => 'Update the name or skill level.';

  @override
  String get addPlayerSubtitle =>
      'Saved to your player pool for future matches.';

  @override
  String get playerNameLabel => 'Player name';

  @override
  String duplicateNameHelper(String name) {
    return 'This name is already in the squad. That’s fine – they’ll be numbered, e.g. “$name (2)”.';
  }

  @override
  String get skillLevelLabel => 'Skill level';

  @override
  String get saveAndAddNext => 'Save & add next';

  @override
  String get saveChanges => 'Save changes';

  @override
  String playerAdded(String name) {
    return '$name added to the pool';
  }

  @override
  String get nameErrorEmpty => 'Please enter the player’s name';

  @override
  String nameErrorTooLong(int max) {
    return 'Keep it under $max characters';
  }

  @override
  String get skillErrorMissing => 'Pick a skill level from 1 (strongest) to 6';

  @override
  String get skillHint => '1 = strongest  ·  6 = weakest';

  @override
  String skillSelectedSummary(int rank, String label, int points) {
    return 'Rank $rank · $label · $points strength pts';
  }

  @override
  String skillSemantics(int rank, String label) {
    return 'Rank $rank, $label';
  }

  @override
  String get skillElite => 'Elite';

  @override
  String get skillExcellent => 'Excellent';

  @override
  String get skillGood => 'Good';

  @override
  String get skillAverage => 'Average';

  @override
  String get skillDeveloping => 'Developing';

  @override
  String get skillBeginner => 'Beginner';

  @override
  String get matchDay => 'Match Day';

  @override
  String get editPlayers => 'Edit players';

  @override
  String get copyTeams => 'Copy teams';

  @override
  String get teamsCopied => 'Teams copied to clipboard';

  @override
  String get resetTitle => 'Pick a new line-up?';

  @override
  String resetMessage(int required) {
    return 'This clears the current selection of $required players so you can choose again. Your saved players are kept.';
  }

  @override
  String get reset => 'Reset';

  @override
  String get edit => 'Edit';

  @override
  String get regenerate => 'Regenerate';

  @override
  String get copyHeader => '⚽ Kora – Match Day';

  @override
  String copyTeamLine(String team, int strength) {
    return '$team (strength $strength)';
  }

  @override
  String copyPlayerLine(String name, int rank) {
    return '$name – rank $rank';
  }

  @override
  String get generationFailed =>
      'Couldn’t generate teams. Please check the selected players.';

  @override
  String issuePoolTooSmall(int missing, int required, int teamCount) {
    String _temp0 = intl.Intl.pluralLogic(
      missing,
      locale: localeName,
      other:
          'Add $missing more players – $required are needed for $teamCount teams.',
      one: 'Add 1 more player – $required are needed for $teamCount teams.',
    );
    return '$_temp0';
  }

  @override
  String issueSelectMore(int missing, int selected, int required) {
    String _temp0 = intl.Intl.pluralLogic(
      missing,
      locale: localeName,
      other: 'Select $missing more players ($selected/$required selected).',
      one: 'Select 1 more player ($selected/$required selected).',
    );
    return '$_temp0';
  }

  @override
  String issueTooMany(int extra, int required) {
    return 'Deselect $extra player(s) – exactly $required are needed.';
  }

  @override
  String get issueInvalidName =>
      'One of the selected players has an invalid name.';

  @override
  String get drawingTitle => 'Balancing the squads…';

  @override
  String get drawingSubtitle => 'Comparing every fair combination';

  @override
  String teamName(String letter) {
    return 'Team $letter';
  }

  @override
  String teamLetter(String index) {
    String _temp0 = intl.Intl.selectLogic(index, {
      '0': 'A',
      '1': 'B',
      '2': 'C',
      '3': 'D',
      '4': 'E',
      'other': '?',
    });
    return '$_temp0';
  }

  @override
  String teamSubtitle(String average, int count) {
    return 'Avg rank $average · $count players';
  }

  @override
  String get strengthLabel => 'STRENGTH';

  @override
  String get ratingPerfectTitle => 'Perfect Balance';

  @override
  String get ratingPerfectDescription =>
      'All teams have exactly the same strength.';

  @override
  String get ratingExcellentTitle => 'Excellent Balance';

  @override
  String get ratingExcellentDescription =>
      'Teams are separated by a single point.';

  @override
  String get ratingGoodTitle => 'Good Balance';

  @override
  String get ratingGoodDescription =>
      'Only a small strength gap between teams.';

  @override
  String get ratingBestPossibleTitle => 'Best Possible Balance';

  @override
  String get ratingBestPossibleDescription =>
      'This squad’s skill mix doesn’t allow a closer split.';

  @override
  String get balanceLabel => 'BALANCE';

  @override
  String strengthGap(int spread) {
    String _temp0 = intl.Intl.pluralLogic(
      spread,
      locale: localeName,
      other: 'Strength gap: $spread pts · mathematically optimal split',
      one: 'Strength gap: 1 pt · mathematically optimal split',
    );
    return '$_temp0';
  }

  @override
  String get sampleNames =>
      'Ahmed,Omar,Youssef,Karim,Mostafa,Hassan,Ali,Mahmoud,Tarek,Amr,Khaled,Ziad,Hamza,Adam,Nour,Seif,Yassin,Marwan,Hesham,Sherif,Fady,Bassem,Walid,Ibrahim,Mazen,Hady,Ramy,Sameh';
}

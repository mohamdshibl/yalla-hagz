import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Kora Balance'**
  String get appTitle;

  /// No description provided for @brandName.
  ///
  /// In en, this message translates to:
  /// **'KORA'**
  String get brandName;

  /// No description provided for @brandTagline.
  ///
  /// In en, this message translates to:
  /// **'TEAM BALANCER'**
  String get brandTagline;

  /// No description provided for @homeIntro.
  ///
  /// In en, this message translates to:
  /// **'Rank your {rosterSize} players from 1 to 6 and get {teamCount} evenly matched teams of {teamSize}. No more one-sided games.'**
  String homeIntro(int rosterSize, int teamCount, int teamSize);

  /// No description provided for @statPlayers.
  ///
  /// In en, this message translates to:
  /// **'Players'**
  String get statPlayers;

  /// No description provided for @statTeams.
  ///
  /// In en, this message translates to:
  /// **'Teams'**
  String get statTeams;

  /// No description provided for @statSkillRanks.
  ///
  /// In en, this message translates to:
  /// **'Skill ranks'**
  String get statSkillRanks;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @continueReady.
  ///
  /// In en, this message translates to:
  /// **'Continue – line-up ready'**
  String get continueReady;

  /// No description provided for @continueSelected.
  ///
  /// In en, this message translates to:
  /// **'Continue ({selected}/{required} selected)'**
  String continueSelected(int selected, int required);

  /// No description provided for @playersSaved.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 player saved on this device} other{{count} players saved on this device}}'**
  String playersSaved(int count);

  /// No description provided for @switchLanguage.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get switchLanguage;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change language'**
  String get changeLanguage;

  /// No description provided for @playersTitle.
  ///
  /// In en, this message translates to:
  /// **'Players'**
  String get playersTitle;

  /// No description provided for @menuMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get menuMore;

  /// No description provided for @menuFillSample.
  ///
  /// In en, this message translates to:
  /// **'Fill with sample players'**
  String get menuFillSample;

  /// No description provided for @menuSortBySkill.
  ///
  /// In en, this message translates to:
  /// **'Sort by skill'**
  String get menuSortBySkill;

  /// No description provided for @menuClearSelection.
  ///
  /// In en, this message translates to:
  /// **'Clear selection'**
  String get menuClearSelection;

  /// No description provided for @menuDeleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete all players'**
  String get menuDeleteAll;

  /// No description provided for @selectionLimitReached.
  ///
  /// In en, this message translates to:
  /// **'{required} players are already selected. Deselect someone first.'**
  String selectionLimitReached(int required);

  /// No description provided for @playerDeleted.
  ///
  /// In en, this message translates to:
  /// **'{name} deleted from the pool'**
  String playerDeleted(String name);

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'UNDO'**
  String get undo;

  /// No description provided for @sampleAdded.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No sample players added.} =1{Added 1 sample player.} other{Added {count} sample players.}}'**
  String sampleAdded(int count);

  /// No description provided for @deleteAllTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete all players?'**
  String get deleteAllTitle;

  /// No description provided for @deleteAllMessage.
  ///
  /// In en, this message translates to:
  /// **'All {count} saved players will be removed from this device.'**
  String deleteAllMessage(int count);

  /// No description provided for @deleteAllConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete all'**
  String get deleteAllConfirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @noPlayersMatch.
  ///
  /// In en, this message translates to:
  /// **'No players match.'**
  String get noPlayersMatch;

  /// No description provided for @searchPlayers.
  ///
  /// In en, this message translates to:
  /// **'Search players'**
  String get searchPlayers;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearch;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All {count}'**
  String filterAll(int count);

  /// No description provided for @filterSelected.
  ///
  /// In en, this message translates to:
  /// **'Selected {count}'**
  String filterSelected(int count);

  /// No description provided for @filterBench.
  ///
  /// In en, this message translates to:
  /// **'Not selected {count}'**
  String filterBench(int count);

  /// No description provided for @poolHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a player to select or deselect · swipe to delete'**
  String get poolHint;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @generateTeams.
  ///
  /// In en, this message translates to:
  /// **'Generate Teams'**
  String get generateTeams;

  /// No description provided for @generateProgress.
  ///
  /// In en, this message translates to:
  /// **'Generate ({selected}/{required})'**
  String generateProgress(int selected, int required);

  /// No description provided for @emptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No players yet'**
  String get emptyTitle;

  /// No description provided for @emptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Add everyone who plays with you and rank them from 1 (strongest) to 6. Each match, pick {required} of them.'**
  String emptyMessage(int required);

  /// No description provided for @addFirstPlayer.
  ///
  /// In en, this message translates to:
  /// **'Add first player'**
  String get addFirstPlayer;

  /// No description provided for @trySample.
  ///
  /// In en, this message translates to:
  /// **'or try a sample squad'**
  String get trySample;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @editPlayerTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit {name}'**
  String editPlayerTooltip(String name);

  /// No description provided for @sameName.
  ///
  /// In en, this message translates to:
  /// **'Same name'**
  String get sameName;

  /// No description provided for @sameNameTooltip.
  ///
  /// In en, this message translates to:
  /// **'Another player has the same name. They will be numbered in the teams.'**
  String get sameNameTooltip;

  /// No description provided for @skillSummary.
  ///
  /// In en, this message translates to:
  /// **'{label} · {points} pts'**
  String skillSummary(String label, int points);

  /// No description provided for @lineupReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Line-up ready!'**
  String get lineupReadyTitle;

  /// No description provided for @lineupReadyMessage.
  ///
  /// In en, this message translates to:
  /// **'{required} of your {poolSize} players selected. Ready to kick off.'**
  String lineupReadyMessage(int required, int poolSize);

  /// No description provided for @buildPoolTitle.
  ///
  /// In en, this message translates to:
  /// **'Build your player pool'**
  String get buildPoolTitle;

  /// No description provided for @buildPoolMessage.
  ///
  /// In en, this message translates to:
  /// **'{missing, plural, =1{Add 1 more player. You can save as many as you like.} other{Add {missing} more players. You can save as many as you like.}}'**
  String buildPoolMessage(int missing);

  /// No description provided for @pickPlayersTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick today’s players'**
  String get pickPlayersTitle;

  /// No description provided for @pickPlayersMessage.
  ///
  /// In en, this message translates to:
  /// **'Select {missing} more from your pool of {poolSize} players.'**
  String pickPlayersMessage(int missing, int poolSize);

  /// No description provided for @rankCount.
  ///
  /// In en, this message translates to:
  /// **'R{rank} ×{count}'**
  String rankCount(int rank, int count);

  /// No description provided for @addPlayerTitle.
  ///
  /// In en, this message translates to:
  /// **'Add player'**
  String get addPlayerTitle;

  /// No description provided for @editPlayerTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit player'**
  String get editPlayerTitle;

  /// No description provided for @editPlayerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Update the name or skill level.'**
  String get editPlayerSubtitle;

  /// No description provided for @addPlayerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Saved to your player pool for future matches.'**
  String get addPlayerSubtitle;

  /// No description provided for @playerNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Player name'**
  String get playerNameLabel;

  /// No description provided for @duplicateNameHelper.
  ///
  /// In en, this message translates to:
  /// **'This name is already in the squad. That’s fine – they’ll be numbered, e.g. “{name} (2)”.'**
  String duplicateNameHelper(String name);

  /// No description provided for @skillLevelLabel.
  ///
  /// In en, this message translates to:
  /// **'Skill level'**
  String get skillLevelLabel;

  /// No description provided for @saveAndAddNext.
  ///
  /// In en, this message translates to:
  /// **'Save & add next'**
  String get saveAndAddNext;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @playerAdded.
  ///
  /// In en, this message translates to:
  /// **'{name} added to the pool'**
  String playerAdded(String name);

  /// No description provided for @nameErrorEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter the player’s name'**
  String get nameErrorEmpty;

  /// No description provided for @nameErrorTooLong.
  ///
  /// In en, this message translates to:
  /// **'Keep it under {max} characters'**
  String nameErrorTooLong(int max);

  /// No description provided for @skillErrorMissing.
  ///
  /// In en, this message translates to:
  /// **'Pick a skill level from 1 (strongest) to 6'**
  String get skillErrorMissing;

  /// No description provided for @skillHint.
  ///
  /// In en, this message translates to:
  /// **'1 = strongest  ·  6 = weakest'**
  String get skillHint;

  /// No description provided for @skillSelectedSummary.
  ///
  /// In en, this message translates to:
  /// **'Rank {rank} · {label} · {points} strength pts'**
  String skillSelectedSummary(int rank, String label, int points);

  /// No description provided for @skillSemantics.
  ///
  /// In en, this message translates to:
  /// **'Rank {rank}, {label}'**
  String skillSemantics(int rank, String label);

  /// No description provided for @skillElite.
  ///
  /// In en, this message translates to:
  /// **'Elite'**
  String get skillElite;

  /// No description provided for @skillExcellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get skillExcellent;

  /// No description provided for @skillGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get skillGood;

  /// No description provided for @skillAverage.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get skillAverage;

  /// No description provided for @skillDeveloping.
  ///
  /// In en, this message translates to:
  /// **'Developing'**
  String get skillDeveloping;

  /// No description provided for @skillBeginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get skillBeginner;

  /// No description provided for @matchDay.
  ///
  /// In en, this message translates to:
  /// **'Match Day'**
  String get matchDay;

  /// No description provided for @editPlayers.
  ///
  /// In en, this message translates to:
  /// **'Edit players'**
  String get editPlayers;

  /// No description provided for @copyTeams.
  ///
  /// In en, this message translates to:
  /// **'Copy teams'**
  String get copyTeams;

  /// No description provided for @teamsCopied.
  ///
  /// In en, this message translates to:
  /// **'Teams copied to clipboard'**
  String get teamsCopied;

  /// No description provided for @resetTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a new line-up?'**
  String get resetTitle;

  /// No description provided for @resetMessage.
  ///
  /// In en, this message translates to:
  /// **'This clears the current selection of {required} players so you can choose again. Your saved players are kept.'**
  String resetMessage(int required);

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @regenerate.
  ///
  /// In en, this message translates to:
  /// **'Regenerate'**
  String get regenerate;

  /// No description provided for @copyHeader.
  ///
  /// In en, this message translates to:
  /// **'⚽ Kora – Match Day'**
  String get copyHeader;

  /// No description provided for @copyTeamLine.
  ///
  /// In en, this message translates to:
  /// **'{team} (strength {strength})'**
  String copyTeamLine(String team, int strength);

  /// No description provided for @copyPlayerLine.
  ///
  /// In en, this message translates to:
  /// **'{name} – rank {rank}'**
  String copyPlayerLine(String name, int rank);

  /// No description provided for @generationFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t generate teams. Please check the selected players.'**
  String get generationFailed;

  /// No description provided for @issuePoolTooSmall.
  ///
  /// In en, this message translates to:
  /// **'{missing, plural, =1{Add 1 more player – {required} are needed for {teamCount} teams.} other{Add {missing} more players – {required} are needed for {teamCount} teams.}}'**
  String issuePoolTooSmall(int missing, int required, int teamCount);

  /// No description provided for @issueSelectMore.
  ///
  /// In en, this message translates to:
  /// **'{missing, plural, =1{Select 1 more player ({selected}/{required} selected).} other{Select {missing} more players ({selected}/{required} selected).}}'**
  String issueSelectMore(int missing, int selected, int required);

  /// No description provided for @issueTooMany.
  ///
  /// In en, this message translates to:
  /// **'Deselect {extra} player(s) – exactly {required} are needed.'**
  String issueTooMany(int extra, int required);

  /// No description provided for @issueInvalidName.
  ///
  /// In en, this message translates to:
  /// **'One of the selected players has an invalid name.'**
  String get issueInvalidName;

  /// No description provided for @drawingTitle.
  ///
  /// In en, this message translates to:
  /// **'Balancing the squads…'**
  String get drawingTitle;

  /// No description provided for @drawingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Comparing every fair combination'**
  String get drawingSubtitle;

  /// No description provided for @teamName.
  ///
  /// In en, this message translates to:
  /// **'Team {letter}'**
  String teamName(String letter);

  /// No description provided for @teamLetter.
  ///
  /// In en, this message translates to:
  /// **'{index, select, 0{A} 1{B} 2{C} 3{D} 4{E} other{?}}'**
  String teamLetter(String index);

  /// No description provided for @teamSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Avg rank {average} · {count} players'**
  String teamSubtitle(String average, int count);

  /// No description provided for @strengthLabel.
  ///
  /// In en, this message translates to:
  /// **'STRENGTH'**
  String get strengthLabel;

  /// No description provided for @ratingPerfectTitle.
  ///
  /// In en, this message translates to:
  /// **'Perfect Balance'**
  String get ratingPerfectTitle;

  /// No description provided for @ratingPerfectDescription.
  ///
  /// In en, this message translates to:
  /// **'All teams have exactly the same strength.'**
  String get ratingPerfectDescription;

  /// No description provided for @ratingExcellentTitle.
  ///
  /// In en, this message translates to:
  /// **'Excellent Balance'**
  String get ratingExcellentTitle;

  /// No description provided for @ratingExcellentDescription.
  ///
  /// In en, this message translates to:
  /// **'Teams are separated by a single point.'**
  String get ratingExcellentDescription;

  /// No description provided for @ratingGoodTitle.
  ///
  /// In en, this message translates to:
  /// **'Good Balance'**
  String get ratingGoodTitle;

  /// No description provided for @ratingGoodDescription.
  ///
  /// In en, this message translates to:
  /// **'Only a small strength gap between teams.'**
  String get ratingGoodDescription;

  /// No description provided for @ratingBestPossibleTitle.
  ///
  /// In en, this message translates to:
  /// **'Best Possible Balance'**
  String get ratingBestPossibleTitle;

  /// No description provided for @ratingBestPossibleDescription.
  ///
  /// In en, this message translates to:
  /// **'This squad’s skill mix doesn’t allow a closer split.'**
  String get ratingBestPossibleDescription;

  /// No description provided for @balanceLabel.
  ///
  /// In en, this message translates to:
  /// **'BALANCE'**
  String get balanceLabel;

  /// No description provided for @strengthGap.
  ///
  /// In en, this message translates to:
  /// **'{spread, plural, =1{Strength gap: 1 pt · mathematically optimal split} other{Strength gap: {spread} pts · mathematically optimal split}}'**
  String strengthGap(int spread);

  /// No description provided for @sampleNames.
  ///
  /// In en, this message translates to:
  /// **'Ahmed,Omar,Youssef,Karim,Mostafa,Hassan,Ali,Mahmoud,Tarek,Amr,Khaled,Ziad,Hamza,Adam,Nour,Seif,Yassin,Marwan,Hesham,Sherif,Fady,Bassem,Walid,Ibrahim,Mazen,Hady,Ramy,Sameh'**
  String get sampleNames;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

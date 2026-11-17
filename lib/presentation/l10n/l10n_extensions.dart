import 'package:flutter/widgets.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/models/skill_level.dart';
import '../../domain/models/team.dart';
import '../../domain/models/team_generation_result.dart';
import '../../domain/validation/player_validator.dart';
import '../../l10n/app_localizations.dart';

export '../../l10n/app_localizations.dart';

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  bool get isArabic => Localizations.localeOf(this).languageCode == 'ar';

  /// Letter-spacing breaks Arabic letter joining, so it is disabled there.
  double tracking(double value) => isArabic ? 0 : value;
}

extension SkillLevelL10n on SkillLevel {
  String label(AppLocalizations l10n) => switch (this) {
    SkillLevel.elite => l10n.skillElite,
    SkillLevel.excellent => l10n.skillExcellent,
    SkillLevel.good => l10n.skillGood,
    SkillLevel.average => l10n.skillAverage,
    SkillLevel.developing => l10n.skillDeveloping,
    SkillLevel.beginner => l10n.skillBeginner,
  };
}

extension BalanceRatingL10n on BalanceRating {
  String title(AppLocalizations l10n) => switch (this) {
    BalanceRating.perfect => l10n.ratingPerfectTitle,
    BalanceRating.excellent => l10n.ratingExcellentTitle,
    BalanceRating.good => l10n.ratingGoodTitle,
    BalanceRating.bestPossible => l10n.ratingBestPossibleTitle,
    BalanceRating.uneven => l10n.ratingUnevenTitle,
  };

  String description(AppLocalizations l10n) => switch (this) {
    BalanceRating.perfect => l10n.ratingPerfectDescription,
    BalanceRating.excellent => l10n.ratingExcellentDescription,
    BalanceRating.good => l10n.ratingGoodDescription,
    BalanceRating.bestPossible => l10n.ratingBestPossibleDescription,
    BalanceRating.uneven => l10n.ratingUnevenDescription,
  };
}

extension TeamL10n on Team {
  /// "A" / "أ"
  String localizedLabel(AppLocalizations l10n) => l10n.teamLetter('$index');

  /// "Team A" / "الفريق أ"
  String localizedName(AppLocalizations l10n) =>
      l10n.teamName(localizedLabel(l10n));
}

extension NameIssueL10n on NameIssue {
  String message(AppLocalizations l10n) => switch (this) {
    NameIssue.empty => l10n.nameErrorEmpty,
    NameIssue.tooLong => l10n.nameErrorTooLong(AppConstants.maxNameLength),
  };
}

extension SelectionIssueL10n on SelectionIssue {
  String message(AppLocalizations l10n) => switch (this) {
    PoolTooSmall(:final missing) => l10n.issuePoolTooSmall(
      missing,
      AppConstants.rosterSize,
      AppConstants.teamCount,
    ),
    NeedMoreSelected(:final missing, :final selected) => l10n.issueSelectMore(
      missing,
      selected,
      AppConstants.rosterSize,
    ),
    TooManySelected(:final extra) => l10n.issueTooMany(
      extra,
      AppConstants.rosterSize,
    ),
    InvalidSelectedName() => l10n.issueInvalidName,
  };
}

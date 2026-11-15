# Kora – Football Team Balancer ⚽

A Flutter app (Android & iOS) that splits **18 players into 3 balanced teams of 6**
based on a 1–6 skill ranking (1 = strongest, 6 = weakest).

Keep a saved **player pool of any size**. Before each match, tick the 18 players
who are playing, and only those players are balanced.

## Run it

```bash
flutter pub get
flutter run            # with an emulator / device connected
flutter test           # unit + widget tests
```

Requires Flutter 3.38+ (Dart 3.10). The only extra dependency is the official
`shared_preferences` package, which saves the squad on the device.

## Features

- **Home**: animated logo, short intro, Start/Continue button.
- **Players**: an unlimited, saved pool. Tap a player to select or deselect them for the
  match (the 19th selection is refused), use the pencil to edit, and swipe to delete (with
  undo). A live `12/18 selected` ring shows progress, and the rank bar shows the mix of the
  selected players. Includes search, All / Selected / Not selected filters, "Save & add next",
  sort by skill, clear selection, a sample squad and delete all. New players are selected
  automatically while fewer than 18 are picked. The selection is saved too, so you can reuse
  last week's line-up.
- **Match Day**: a short "drawing" animation, then a staggered reveal of three
  colour-coded team cards, a balance indicator (strength bars, % balance, strength gap),
  Regenerate, Edit, Reset (clears only the selection; saved players are kept)
  and Copy-to-clipboard.

## Languages (English / العربية)

- Uses Flutter's official localization tooling (`flutter_localizations` + `gen-l10n`).
  Translations live in [lib/l10n/app_en.arb](lib/l10n/app_en.arb) and
  [lib/l10n/app_ar.arb](lib/l10n/app_ar.arb). The Dart classes are generated automatically
  on `flutter pub get` / `flutter run`, or manually with `flutter gen-l10n`.
- The app follows the phone's language by default. The button at the top of the Home screen
  switches between English and Arabic, and the choice is saved.
- Arabic switches the whole layout to right-to-left, uses proper Arabic plural forms and
  team letters (أ / ب / ج), and turns off letter-spacing so Arabic letters stay joined.
- The domain layer contains no UI text. It returns typed issues (`NameIssue`,
  `SelectionIssue`) that the UI turns into the right language.
- **To add a language:** copy `app_en.arb` to `app_xx.arb` and translate the values.

## Architecture

```
lib/
├── core/constants/        App-wide constants (team count/size, limits)
├── domain/                Pure business logic, no UI
│   ├── models/            Player, SkillLevel, Team, TeamGenerationResult
│   ├── services/          TeamBalancer (algorithm), duplicate-name labelling
│   └── validation/        PlayerValidator
├── data/repositories/     PlayerRepository interface + SharedPreferences / in-memory impls
└── presentation/
    ├── controllers/       RosterController (ChangeNotifier) + RosterScope (InheritedNotifier)
    ├── screens/           Home, PlayersSetup, TeamResults
    ├── widgets/           Reusable UI: PlayerCard, SkillSelector, TeamCard, BalanceIndicator…
    ├── navigation/        Shared page transition
    └── theme/             Colours, skill/team colours, ThemeData
```

State management uses only Flutter built-ins (`ChangeNotifier` + `InheritedNotifier`).

## The balancing algorithm

**Scoring.** A player's strength is `7 − rank`, so rank 1 scores 6 points and rank 6 scores 1 point.

**Search.** Players with the same rank are interchangeable for strength, so the balancer
doesn't try all ~2.86 million ways to split 18 individuals. It enumerates every way to
split each rank's *head-count* across the three teams, keeping each team at exactly 6.
That search is **exhaustive, so the result is provably optimal**, and it takes milliseconds.
A test checks it against a full brute-force search over individual players.

**Ranking candidates (lexicographic):**
1. *Strength gap*: strongest team total minus weakest team total.
2. *Variance*: how far each team is from the average.
3. *Rank spread*: how evenly each rank is shared, so strong or weak players don't stack up
   on one team. For example, three rank-1 players always go to three different teams.

**Variety.** One of the equally optimal splits is picked at random, and players are shuffled
within each rank. *Regenerate* also avoids repeating the previous grouping, so you get a
different but equally fair line-up.

**Safety.** The balancer rejects anything other than exactly 18 unique, named players, and
it checks that every player ends up in exactly one team.

## Validation & edge cases

| Case | Handling |
| --- | --- |
| Empty name | Form error; names are trimmed and whitespace is collapsed |
| Duplicate names | Allowed. Marked "Same name" in the list and numbered in the teams, e.g. `Ali (2)` |
| Missing skill | Form error until a rank 1–6 is picked |
| Invalid rank | Impossible from the UI (enum); invalid stored data is dropped on load |
| Pool < 18 | Generate explains how many more players to add |
| Selection ≠ 18 | Selecting a 19th player is refused; Generate shows `x/18` and what's missing |
| Deleted player | Removed from the selection too; undo restores both |
| Repeated generation | Each run is optimal and tries to differ from the previous one |

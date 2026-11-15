import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../controllers/locale_controller.dart';
import '../controllers/roster_scope.dart';
import '../l10n/l10n_extensions.dart';
import '../navigation/fade_slide_route.dart';
import '../theme/app_colors.dart';
import '../widgets/app_logo.dart';
import '../widgets/pitch_background.dart';
import '../widgets/primary_button.dart';
import '../widgets/reveal_transition.dart';
import 'players_setup_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..forward();

  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _entrance.dispose();
    _float.dispose();
    super.dispose();
  }

  void _openSetup() =>
      Navigator.of(context).push(fadeSlideRoute(const PlayersSetupScreen()));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final roster = RosterScope.of(context);
    final count = roster.poolSize;
    final selected = roster.selectedCount;
    final required = roster.requiredCount;

    final startLabel = switch (count) {
      0 => l10n.start,
      _ when roster.isReadyToGenerate => l10n.continueReady,
      _ => l10n.continueSelected(selected, required),
    };

    return Scaffold(
      body: PitchBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: _LanguageButton(),
                        ),
                      ),
                      const Spacer(flex: 2),
                      RevealTransition(
                        animation: _entrance.interval(0, 0.5),
                        child: AnimatedBuilder(
                          animation: _float,
                          builder: (context, child) => Transform.translate(
                            offset: Offset(
                              0,
                              -10 * Curves.easeInOut.transform(_float.value),
                            ),
                            child: child,
                          ),
                          child: const AppLogo(size: 124),
                        ),
                      ),
                      const SizedBox(height: 36),
                      RevealTransition(
                        animation: _entrance.interval(0.15, 0.65),
                        child: Column(
                          children: [
                            Text(
                              l10n.brandName,
                              style: theme.textTheme.displayMedium?.copyWith(
                                letterSpacing: context.tracking(10),
                              ),
                            ),
                            Text(
                              l10n.brandTagline,
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: AppColors.accentBright,
                                letterSpacing: context.tracking(6),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      RevealTransition(
                        animation: _entrance.interval(0.3, 0.8),
                        child: Text(
                          l10n.homeIntro(
                            AppConstants.rosterSize,
                            AppConstants.teamCount,
                            AppConstants.playersPerTeam,
                          ),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.45,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      RevealTransition(
                        animation: _entrance.interval(0.4, 0.9),
                        child: Row(
                          children: [
                            _StatPill(
                              icon: Icons.groups_rounded,
                              value: '${AppConstants.rosterSize}',
                              label: l10n.statPlayers,
                            ),
                            const SizedBox(width: 10),
                            _StatPill(
                              icon: Icons.shield_rounded,
                              value: '${AppConstants.teamCount}',
                              label: l10n.statTeams,
                            ),
                            const SizedBox(width: 10),
                            _StatPill(
                              icon: Icons.balance_rounded,
                              value: '1–6',
                              label: l10n.statSkillRanks,
                            ),
                          ],
                        ),
                      ),
                      const Spacer(flex: 3),
                      const SizedBox(height: 24),
                      RevealTransition(
                        animation: _entrance.interval(0.55, 1),
                        child: PrimaryButton(
                          label: startLabel,
                          icon: Icons.sports_soccer_rounded,
                          onPressed: _openSetup,
                        ),
                      ),
                      const SizedBox(height: 12),
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: count > 0 ? 1 : 0,
                        child: Text(
                          l10n.playersSaved(count),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  const _LanguageButton();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Tooltip(
      message: l10n.changeLanguage,
      child: OutlinedButton.icon(
        onPressed: () => LocaleScope.read(
          context,
        ).toggle(Localizations.localeOf(context)),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 40),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          backgroundColor: AppColors.surface.withValues(alpha: 0.6),
          shape: const StadiumBorder(),
        ),
        icon: const Icon(Icons.translate_rounded, size: 18),
        label: Text(l10n.switchLanguage),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.outline),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.accent, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

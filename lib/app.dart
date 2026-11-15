import 'package:flutter/material.dart';

import 'l10n/app_localizations.dart';
import 'presentation/controllers/locale_controller.dart';
import 'presentation/controllers/roster_controller.dart';
import 'presentation/controllers/roster_scope.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/theme/app_theme.dart';

class KoraApp extends StatelessWidget {
  const KoraApp({
    super.key,
    required this.controller,
    required this.localeController,
  });

  final RosterController controller;
  final LocaleController localeController;

  @override
  Widget build(BuildContext context) {
    return LocaleScope(
      controller: localeController,
      child: RosterScope(
        controller: controller,
        child: ValueListenableBuilder<Locale?>(
          valueListenable: localeController,
          builder: (context, locale, _) => MaterialApp(
            onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
            debugShowCheckedModeBanner: false,
            // `null` follows the device language (falls back to English).
            locale: locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            theme: AppTheme.dark,
            darkTheme: AppTheme.dark,
            themeMode: ThemeMode.dark,
            home: const HomeScreen(),
          ),
        ),
      ),
    );
  }
}

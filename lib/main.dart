import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'data/repositories/settings_repository.dart';
import 'data/repositories/shared_prefs_player_repository.dart';
import 'domain/services/team_balancer.dart';
import 'presentation/controllers/locale_controller.dart';
import 'presentation/controllers/roster_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final controller = RosterController(
    repository: SharedPrefsPlayerRepository(),
    balancer: TeamBalancer(),
  );
  final localeController = LocaleController(
    repository: SharedPrefsSettingsRepository(),
  );
  await Future.wait([controller.load(), localeController.load()]);

  runApp(KoraApp(controller: controller, localeController: localeController));
}

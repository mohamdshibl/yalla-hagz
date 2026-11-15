import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/app.dart';
import 'package:kora/data/repositories/player_repository.dart';
import 'package:kora/data/repositories/settings_repository.dart';
import 'package:kora/domain/services/team_balancer.dart';
import 'package:kora/presentation/controllers/locale_controller.dart';
import 'package:kora/presentation/controllers/roster_controller.dart';

Future<(RosterController, LocaleController)> pumpApp(
  WidgetTester tester,
  Locale locale,
) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.5;
  addTearDown(tester.view.reset);

  final controller = RosterController(
    repository: InMemoryPlayerRepository(),
    balancer: TeamBalancer(random: Random(1)),
    random: Random(2),
  );
  await controller.load();
  final localeController = LocaleController(
    repository: InMemorySettingsRepository(),
    initial: locale,
  );

  await tester.pumpWidget(
    KoraApp(controller: controller, localeController: localeController),
  );
  await tester.pump(const Duration(seconds: 2));
  return (controller, localeController);
}

void main() {
  testWidgets('full flow in English: home → setup → teams', (tester) async {
    final (controller, _) = await pumpApp(tester, const Locale('en'));
    expect(find.text('KORA'), findsOneWidget);

    await tester.tap(find.text('Start'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Players'), findsOneWidget);
    expect(find.text('No players yet'), findsOneWidget);

    controller.fillWithSampleSquad();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Line-up ready!'), findsOneWidget);

    await tester.tap(find.text('Generate Teams'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Balancing the squads…'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Team A'), findsOneWidget);
    expect(find.textContaining('Balance'), findsWidgets);
  });

  testWidgets('full flow in Arabic is right-to-left', (tester) async {
    final (controller, _) = await pumpApp(tester, const Locale('ar'));
    expect(find.text('كورة'), findsOneWidget);
    final home = tester.element(find.text('كورة'));
    expect(Directionality.of(home), TextDirection.rtl);

    await tester.tap(find.text('ابدأ'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('اللاعبون'), findsOneWidget);

    controller.fillWithSampleSquad(names: ['أحمد', 'عمر', 'يوسف']);
    expect(controller.poolSize, 3);
    controller.fillWithSampleSquad(); // tops up with default names
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('التشكيلة جاهزة!'), findsOneWidget);

    await tester.tap(find.text('كوّن الفرق'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('الفريق أ'), findsOneWidget);
  });

  testWidgets('language button switches English ↔ Arabic', (tester) async {
    final (_, localeController) = await pumpApp(tester, const Locale('en'));

    await tester.tap(find.text('العربية'));
    await tester.pump(const Duration(seconds: 2));
    expect(localeController.value, const Locale('ar'));
    expect(find.text('كورة'), findsOneWidget);

    await tester.tap(find.text('English'));
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('KORA'), findsOneWidget);
  });
}

import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../data/repositories/settings_repository.dart';

/// The app language chosen by the user, or `null` to follow the device.
class LocaleController extends ValueNotifier<Locale?> {
  LocaleController({required SettingsRepository repository, Locale? initial})
    : _repository = repository,
      super(initial);

  final SettingsRepository _repository;

  Future<void> load() async {
    try {
      final code = await _repository.loadLanguageCode();
      if (code != null) value = Locale(code);
    } catch (error) {
      debugPrint('Could not load language: $error');
    }
  }

  void setLocale(Locale? locale) {
    value = locale;
    unawaited(_repository.saveLanguageCode(locale?.languageCode));
  }

  /// Switches between English and Arabic, starting from the [current]
  /// language actually shown on screen.
  void toggle(Locale current) => setLocale(
    current.languageCode == 'ar' ? const Locale('en') : const Locale('ar'),
  );
}

class LocaleScope extends InheritedNotifier<LocaleController> {
  const LocaleScope({
    super.key,
    required LocaleController controller,
    required super.child,
  }) : super(notifier: controller);

  static LocaleController read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<LocaleScope>();
    assert(scope != null, 'No LocaleScope found in the widget tree.');
    return scope!.notifier!;
  }
}

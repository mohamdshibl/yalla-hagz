import 'package:shared_preferences/shared_preferences.dart';

/// App preferences that are not part of the squad (e.g. language).
abstract interface class SettingsRepository {
  /// `null` means "follow the device language".
  Future<String?> loadLanguageCode();

  Future<void> saveLanguageCode(String? code);
}

class SharedPrefsSettingsRepository implements SettingsRepository {
  static const String _languageKey = 'kora.language.v1';

  @override
  Future<String?> loadLanguageCode() async =>
      (await SharedPreferences.getInstance()).getString(_languageKey);

  @override
  Future<void> saveLanguageCode(String? code) async {
    final prefs = await SharedPreferences.getInstance();
    if (code == null) {
      await prefs.remove(_languageKey);
    } else {
      await prefs.setString(_languageKey, code);
    }
  }
}

class InMemorySettingsRepository implements SettingsRepository {
  InMemorySettingsRepository([this._code]);

  String? _code;

  @override
  Future<String?> loadLanguageCode() async => _code;

  @override
  Future<void> saveLanguageCode(String? code) async => _code = code;
}

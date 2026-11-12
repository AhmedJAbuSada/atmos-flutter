import 'package:shared_preferences/shared_preferences.dart';

import 'key_value_store.dart';

/// The real store (ADR-0008): `SharedPreferencesAsync`, which uses DataStore Preferences on
/// Android and `UserDefaults` on iOS. Thin glue: the logic is tested with
/// [InMemoryKeyValueStore]; this class needs the platform plugin, so the app's journey tests
/// (step 07) cover it.
final class SharedPreferencesStore implements KeyValueStore {
  SharedPreferencesStore([SharedPreferencesAsync? preferences])
    : _preferences = preferences ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _preferences;

  @override
  Future<String?> getString(String key) => _preferences.getString(key);

  @override
  Future<void> setString(String key, String value) => _preferences.setString(key, value);
}

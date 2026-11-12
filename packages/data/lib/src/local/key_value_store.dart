import 'dart:convert';

/// The few storage operations the data layer needs (ADR-0008). Strings in, strings out: the
/// repositories store JSON.
abstract interface class KeyValueStore {
  Future<String?> getString(String key);

  Future<void> setString(String key, String value);
}

/// Keeps everything in memory: for tests, and a safe fallback.
final class InMemoryKeyValueStore implements KeyValueStore {
  InMemoryKeyValueStore([Map<String, String>? initial]) : entries = {...?initial};

  /// Visible, so tests can look at and corrupt what was stored.
  final Map<String, String> entries;

  @override
  Future<String?> getString(String key) async => entries[key];

  @override
  Future<void> setString(String key, String value) async => entries[key] = value;
}

/// Reads a JSON value. Missing **or unreadable** data is `null`, never a crash: corrupt data
/// is no data.
Future<Object?> readJson(KeyValueStore store, String key) async {
  final raw = await store.getString(key);
  if (raw == null) return null;
  try {
    return jsonDecode(raw);
  } on FormatException {
    return null;
  }
}

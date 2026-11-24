// ─── Preferences Store ────────────────────────────────────────────
// Small JSON documents kept on the phone: the household profile and, in the
// development flavor, everything the demo repositories change, so the app
// survives a restart without a server.
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

abstract interface class PrefsStore {
  Future<Object?> read(String key);
  Future<void> write(String key, Object? value);
  Future<void> remove(String key);
}

/// The phone's own storage (shared_preferences).
class DevicePrefsStore implements PrefsStore {
  DevicePrefsStore([SharedPreferencesAsync? prefs]) : _prefs = prefs ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _prefs;
  static const _prefix = 'domease.';

  @override
  Future<Object?> read(String key) async {
    final raw = await _prefs.getString('$_prefix$key');
    return raw == null ? null : jsonDecode(raw);
  }

  @override
  Future<void> write(String key, Object? value) => _prefs.setString('$_prefix$key', jsonEncode(value));

  @override
  Future<void> remove(String key) => _prefs.remove('$_prefix$key');
}

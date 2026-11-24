// ─── Test Fakes ───────────────────────────────────────────────────
// Shared by every test, never shipped.
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:domease/config/dependencies.dart';
import 'package:domease/config/environment.dart';
import 'package:domease/data/services/prefs_store.dart';

/// Storage in memory, round-tripped through JSON like the real thing.
class MemoryPrefsStore implements PrefsStore {
  final Map<String, String> _data = {};

  @override
  Future<Object?> read(String key) async => _data[key] == null ? null : jsonDecode(_data[key]!);

  @override
  Future<void> write(String key, Object? value) async {
    _data[key] = jsonEncode(value);
  }

  @override
  Future<void> remove(String key) async {
    _data.remove(key);
  }
}

/// The development flavor (demo data from assets/demo) with memory storage.
ProviderScope demoScope({required Widget child, PrefsStore? store}) => ProviderScope(
      overrides: [
        flavorProvider.overrideWithValue(Flavor.development),
        prefsStoreProvider.overrideWithValue(store ?? MemoryPrefsStore()),
      ],
      child: child,
    );

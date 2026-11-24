// ─── Preferences View Model ───────────────────────────────────────
// Appearance and reminders for this phone. The app root watches
// themeModeProvider, so a change to Appearance shows at once.
import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:domease/config/dependencies.dart';
import 'package:domease/domain/models/preferences.dart';

final preferencesProvider = AsyncNotifierProvider<PreferencesNotifier, Preferences>(PreferencesNotifier.new);

class PreferencesNotifier extends AsyncNotifier<Preferences> {
  @override
  Future<Preferences> build() => ref.watch(preferencesRepositoryProvider).load();

  Future<void> change(Preferences Function(Preferences) edit) async {
    final next = edit(state.value ?? const Preferences());
    state = AsyncData(next);
    await ref.read(preferencesRepositoryProvider).save(next);
  }
}

final themeModeProvider = Provider<ThemeMode>((ref) => switch (ref.watch(preferencesProvider).value?.appearance) {
      Appearance.light => ThemeMode.light,
      Appearance.dark => ThemeMode.dark,
      _ => ThemeMode.system,
    });

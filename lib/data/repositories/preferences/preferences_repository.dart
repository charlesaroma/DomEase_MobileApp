// ─── Preferences Repository ───────────────────────────────────────
// Kept on the phone in every flavor: appearance and reminders are a choice
// about this device, not the household's record on the server.
import 'package:domease/data/model/json.dart';
import 'package:domease/data/services/prefs_store.dart';
import 'package:domease/domain/models/preferences.dart';

class PreferencesRepository {
  PreferencesRepository(this._store);

  final PrefsStore _store;
  static const _key = 'preferences';

  Future<Preferences> load() async {
    final j = await _store.read(_key) as Json?;
    if (j == null) return const Preferences();
    return Preferences(
      appearance: byName(Appearance.values, j['appearance'], Appearance.system),
      remindTasks: j['remindTasks'] as bool? ?? true,
      remindLowStock: j['remindLowStock'] as bool? ?? true,
      weeklyPlan: j['weeklyPlan'] as bool? ?? true,
    );
  }

  Future<void> save(Preferences p) => _store.write(_key, {
        'appearance': p.appearance.name,
        'remindTasks': p.remindTasks,
        'remindLowStock': p.remindLowStock,
        'weeklyPlan': p.weeklyPlan,
      });
}

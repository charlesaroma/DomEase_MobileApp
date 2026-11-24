// ─── Household Repository (API) ───────────────────────────────────
import 'package:domease/data/model/household_json.dart';
import 'package:domease/data/model/json.dart';
import 'package:domease/data/repositories/household/household_repository.dart';
import 'package:domease/data/services/api/api_client.dart';
import 'package:domease/data/services/prefs_store.dart';
import 'package:domease/domain/models/failure.dart';
import 'package:domease/domain/models/household.dart';
import 'package:domease/domain/models/premium.dart';

/// The API is the record; a copy is kept on the phone so the app opens
/// straight onto Today on a poor connection.
class HouseholdRepositoryRemote implements HouseholdRepository {
  HouseholdRepositoryRemote(this._api, this._store);

  final ApiClient _api;
  final PrefsStore _store;
  static const _key = 'household';

  @override
  Future<Household?> current() async {
    try {
      final h = householdFromJson(await _api.get('/households/me') as Json);
      await _store.write(_key, householdToJson(h));
      return h;
    } on NotFoundFailure {
      return null;
    } on NetworkFailure {
      final cached = await _store.read(_key);
      return cached == null ? null : householdFromJson(cached as Json);
    }
  }

  @override
  Future<Household> save(Household household) async {
    final h = householdFromJson(await _api.put('/households/me', householdToJson(household)) as Json);
    await _store.write(_key, householdToJson(h));
    return h;
  }

  @override
  Future<Household> upgrade(Household household, PremiumPlan plan) async {
    final h = householdFromJson(await _api.post('/subscriptions/checkout', {'plan': plan.name}) as Json);
    await _store.write(_key, householdToJson(h));
    return h;
  }

  @override
  Future<Household> join(String code) async {
    final h = householdFromJson(await _api.post('/households/join', {'code': code.trim().toUpperCase()}) as Json);
    await _store.write(_key, householdToJson(h));
    return h;
  }

  @override
  Future<String> inviteCode() async => ((await _api.post('/households/me/invite') as Json)['code'] as String);

  @override
  Future<void> leave() async {
    await _api.post('/households/me/leave');
    await clear();
  }

  @override
  Future<void> clear() => _store.remove(_key);
}

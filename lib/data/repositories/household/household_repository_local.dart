// ─── Household Repository (demo) ──────────────────────────────────
import 'package:domease/data/model/household_json.dart';
import 'package:domease/data/model/json.dart';
import 'package:domease/data/repositories/household/household_repository.dart';
import 'package:domease/data/services/demo_assets.dart';
import 'package:domease/data/services/prefs_store.dart';
import 'package:domease/domain/models/failure.dart';
import 'package:domease/domain/models/household.dart';
import 'package:domease/domain/models/premium.dart';

/// Kept on the phone. "Upgrading" switches Premium on at once, so every
/// Premium screen can be tried without a payment provider.
class HouseholdRepositoryLocal implements HouseholdRepository {
  HouseholdRepositoryLocal(this._store);

  final PrefsStore _store;
  static const _key = 'household';

  @override
  Future<Household?> current() async {
    final json = await _store.read(_key);
    return json == null ? null : householdFromJson(json as Json);
  }

  @override
  Future<Household> save(Household household) async {
    await _store.write(_key, householdToJson(household));
    return household;
  }

  @override
  Future<Household> upgrade(Household household, PremiumPlan plan) => save(household.copyWith(tier: Tier.premium));

  /// The demo home anyone can join: assets/demo/household.json.
  static const demoInviteCode = 'DOM123';

  @override
  Future<Household> join(String code) async {
    if (code.trim().toUpperCase() != demoInviteCode) {
      throw const NotFoundFailure('That code did not match a home. Check it with the person who invited you.');
    }
    return save(householdFromJson(await loadDemoMap('household')));
  }

  @override
  Future<String> inviteCode() async => demoInviteCode;

  @override
  Future<void> leave() => clear();

  @override
  Future<void> clear() => _store.remove(_key);
}

// ─── Household Repository ─────────────────────────────────────────
import 'package:domease/domain/models/household.dart';
import 'package:domease/domain/models/premium.dart';

/// The signed in household's profile and plan.
abstract interface class HouseholdRepository {
  /// Null until onboarding has been finished on this phone.
  Future<Household?> current();

  /// Create or update the profile (FR-ON-5).
  Future<Household> save(Household household);

  /// Start Premium for [household] through mobile money. The server decides
  /// the plan (FR-MZ-1).
  Future<Household> upgrade(Household household, PremiumPlan plan);

  /// Join a home someone else set up, with the code they shared.
  /// Throws a NotFoundFailure when the code matches no home.
  Future<Household> join(String code);

  /// The code to share so someone can join this home (Premium sharing).
  Future<String> inviteCode();

  /// Leave a home someone else set up. The home carries on for them.
  Future<void> leave();

  /// Forget the profile on this phone (sign out, or start again).
  Future<void> clear();
}

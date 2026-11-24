// ─── Household View Model ─────────────────────────────────────────
// The household every screen works for. Null until onboarding is finished.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:domease/config/dependencies.dart';
import 'package:domease/domain/models/failure.dart';
import 'package:domease/domain/models/household.dart';
import 'package:domease/domain/models/premium.dart';

final householdProvider = AsyncNotifierProvider<HouseholdNotifier, Household?>(HouseholdNotifier.new);

class HouseholdNotifier extends AsyncNotifier<Household?> {
  @override
  Future<Household?> build() => ref.watch(householdRepositoryProvider).current();

  Future<Household> save(Household household) async {
    final saved = await ref.read(householdRepositoryProvider).save(household);
    state = AsyncData(saved);
    return saved;
  }

  /// Upgrades the household the app already has in hand, so a slow or
  /// missing read from storage can never block a payment.
  Future<void> upgrade(PremiumPlan plan) async {
    final household = state.value ?? await future;
    if (household == null) throw const NoHouseholdFailure();
    state = AsyncData(await ref.read(householdRepositoryProvider).upgrade(household, plan));
  }

  /// Join someone else's home with their invite code.
  Future<Household> join(String code) async {
    final h = await ref.read(householdRepositoryProvider).join(code);
    state = AsyncData(h);
    return h;
  }

  /// Leave a home someone else set up.
  Future<void> leave() async {
    await ref.read(householdRepositoryProvider).leave();
    state = const AsyncData(null);
  }

  /// Start again: forget this phone's household and go back to onboarding.
  Future<void> reset() async {
    await ref.read(householdRepositoryProvider).clear();
    state = const AsyncData(null);
  }
}

/// True when the household is on Premium. Every Premium gate reads this (FR-MZ-2).
final isPremiumProvider = Provider<bool>((ref) => ref.watch(householdProvider).value?.isPremium ?? false);

/// The code to share so someone can join this home (Premium sharing).
final inviteCodeProvider = FutureProvider<String>((ref) => ref.watch(householdRepositoryProvider).inviteCode());

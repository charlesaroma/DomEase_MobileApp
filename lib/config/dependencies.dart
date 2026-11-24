// ─── Dependencies ─────────────────────────────────────────────────
// The composition root: the one place that decides which implementation
// serves each repository, from the flavor (config/environment.dart).
// Development gets the `_local` repositories (demo data); staging and
// production get the `_remote` ones (the API). View models read these
// providers; tests override them with fakes.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:domease/config/environment.dart';
import 'package:domease/data/repositories/auth/auth_repository.dart';
import 'package:domease/data/repositories/auth/auth_repository_local.dart';
import 'package:domease/data/repositories/auth/auth_repository_remote.dart';
import 'package:domease/data/repositories/content/content_repository.dart';
import 'package:domease/data/repositories/content/content_repository_local.dart';
import 'package:domease/data/repositories/content/content_repository_remote.dart';
import 'package:domease/data/repositories/house_help/house_help_repository.dart';
import 'package:domease/data/repositories/house_help/house_help_repository_local.dart';
import 'package:domease/data/repositories/house_help/house_help_repository_remote.dart';
import 'package:domease/data/repositories/household/household_repository.dart';
import 'package:domease/data/repositories/household/household_repository_local.dart';
import 'package:domease/data/repositories/household/household_repository_remote.dart';
import 'package:domease/data/repositories/meals/meal_repository.dart';
import 'package:domease/data/repositories/meals/meal_repository_local.dart';
import 'package:domease/data/repositories/meals/meal_repository_remote.dart';
import 'package:domease/data/repositories/preferences/preferences_repository.dart';
import 'package:domease/data/repositories/shopping/shopping_repository.dart';
import 'package:domease/data/repositories/shopping/shopping_repository_local.dart';
import 'package:domease/data/repositories/shopping/shopping_repository_remote.dart';
import 'package:domease/data/repositories/zones/zone_repository.dart';
import 'package:domease/data/repositories/zones/zone_repository_local.dart';
import 'package:domease/data/repositories/zones/zone_repository_remote.dart';
import 'package:domease/data/services/api/api_client.dart';
import 'package:domease/data/services/prefs_store.dart';
import 'package:domease/data/services/social_sign_in.dart';

// ── Services ──

final prefsStoreProvider = Provider<PrefsStore>((ref) => DevicePrefsStore());

/// The signed in token, set by the auth repository and read by every request.
class TokenHolder {
  String? value;
}

final tokenHolderProvider = Provider<TokenHolder>((ref) => TokenHolder());

final apiClientProvider = Provider<ApiClient>((ref) {
  final holder = ref.watch(tokenHolderProvider);
  return ApiClient(ref.watch(flavorProvider).apiRoot, token: () => holder.value);
});

/// Google and Apple on the phone. Swap in the real implementation once the
/// keys are set up (docs/02-architecture.md, "Sign in").
final socialSignInProvider = Provider<SocialSignIn>((ref) => const UnconfiguredSocialSignIn());

bool _demo(Ref ref) => ref.watch(flavorProvider).useDemoData;

// ── Repositories ──

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final holder = ref.watch(tokenHolderProvider);
  void onToken(String? token) => holder.value = token;
  return _demo(ref)
      ? AuthRepositoryLocal(ref.watch(prefsStoreProvider), onToken)
      : AuthRepositoryRemote(ref.watch(apiClientProvider), ref.watch(prefsStoreProvider), ref.watch(socialSignInProvider), onToken);
});

final householdRepositoryProvider = Provider<HouseholdRepository>((ref) => _demo(ref)
    ? HouseholdRepositoryLocal(ref.watch(prefsStoreProvider))
    : HouseholdRepositoryRemote(ref.watch(apiClientProvider), ref.watch(prefsStoreProvider)));

final mealRepositoryProvider = Provider<MealRepository>(
    (ref) => _demo(ref) ? MealRepositoryLocal(ref.watch(prefsStoreProvider)) : MealRepositoryRemote(ref.watch(apiClientProvider)));

final zoneRepositoryProvider = Provider<ZoneRepository>(
    (ref) => _demo(ref) ? ZoneRepositoryLocal(ref.watch(prefsStoreProvider)) : ZoneRepositoryRemote(ref.watch(apiClientProvider)));

final shoppingRepositoryProvider = Provider<ShoppingRepository>((ref) =>
    _demo(ref) ? ShoppingRepositoryLocal(ref.watch(prefsStoreProvider)) : ShoppingRepositoryRemote(ref.watch(apiClientProvider)));

/// On the phone in every flavor (appearance and reminders are per device).
final preferencesRepositoryProvider = Provider<PreferencesRepository>((ref) => PreferencesRepository(ref.watch(prefsStoreProvider)));

final contentRepositoryProvider =
    Provider<ContentRepository>((ref) => _demo(ref) ? ContentRepositoryLocal() : ContentRepositoryRemote(ref.watch(apiClientProvider)));

final houseHelpRepositoryProvider =
    Provider<HouseHelpRepository>((ref) => _demo(ref) ? HouseHelpRepositoryLocal() : HouseHelpRepositoryRemote(ref.watch(apiClientProvider)));

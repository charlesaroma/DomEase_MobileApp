// ─── Auth View Model ──────────────────────────────────────────────
// The session on this phone and every way to start one. Screens call these
// and show the AuthFailure's sentence if one comes back.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:domease/config/dependencies.dart';
import 'package:domease/domain/models/session.dart';
import 'package:domease/routing/routes.dart';
import 'package:domease/ui/core/view_models/household_viewmodel.dart';

/// Create an account (new to DomEase) or log back in.
enum AuthMode { signUp, logIn }

final sessionProvider = AsyncNotifierProvider<SessionNotifier, Session?>(SessionNotifier.new);

class SessionNotifier extends AsyncNotifier<Session?> {
  @override
  Future<Session?> build() => ref.watch(authRepositoryProvider).current();

  Future<Session> _run(Future<Session> Function() signIn) async {
    final s = await signIn();
    state = AsyncData(s);
    return s;
  }

  Future<Session> google() => _run(ref.read(authRepositoryProvider).signInWithGoogle);
  Future<Session> apple() => _run(ref.read(authRepositoryProvider).signInWithApple);

  Future<Session> emailSignUp(String name, String email, String password) =>
      _run(() => ref.read(authRepositoryProvider).signUpWithEmail(name: name, email: email, password: password));

  Future<Session> emailLogIn(String email, String password) =>
      _run(() => ref.read(authRepositoryProvider).signInWithEmail(email: email, password: password));

  Future<void> sendCode(String phone) => ref.read(authRepositoryProvider).sendPhoneCode(phone);

  Future<Session> verifyCode(String phone, String code) =>
      _run(() => ref.read(authRepositoryProvider).verifyPhoneCode(phone: phone, code: code));

  Future<void> sendReset(String email) => ref.read(authRepositoryProvider).sendPasswordReset(email);

  Future<Session> updateProfile({String? name, String? email, String? phone}) async {
    final s = await ref.read(authRepositoryProvider).updateProfile(name: name, email: email, phone: phone);
    state = AsyncData(s);
    return s;
  }

  Future<void> changePassword(String current, String next) =>
      ref.read(authRepositoryProvider).changePassword(current: current, next: next);

  /// Deletes the account for good. The household on this phone goes with it.
  Future<void> deleteAccount() async {
    await ref.read(authRepositoryProvider).deleteAccount();
    await ref.read(householdProvider.notifier).reset();
    state = const AsyncData(null);
  }

  /// Signs out and forgets this phone's copy of the household.
  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    await ref.read(householdProvider.notifier).reset();
    state = const AsyncData(null);
  }
}

/// Where to go once signed in: Today if the account already has a home on
/// this phone, otherwise the choice to set one up or join one.
Future<String> routeAfterSignIn(WidgetRef ref) async {
  ref.invalidate(householdProvider);
  final household = await ref.read(householdProvider.future);
  return household == null ? Routes.setup : Routes.today;
}

/// Where the splash sends someone: Welcome when signed out, the set up
/// choice when signed in without a home, Today otherwise.
Future<String> routeOnLaunch(WidgetRef ref) async {
  Object? session;
  Object? household;
  try {
    session = await ref.read(sessionProvider.future);
    household = session == null ? null : await ref.read(householdProvider.future);
  } catch (_) {
    // A broken read must never strand someone on the splash.
  }
  if (session == null) return Routes.welcome;
  return household == null ? Routes.setup : Routes.today;
}

// ─── Auth Repository ──────────────────────────────────────────────
import 'package:domease/domain/models/session.dart';

/// Every way into an account (PRD 7.2). Each sign in returns a Session whose
/// token the ApiClient sends from then on. Failures are AuthFailures with a
/// sentence a person can act on.
abstract interface class AuthRepository {
  /// The session saved on this phone, if any.
  Future<Session?> current();

  Future<Session> signInWithGoogle();
  Future<Session> signInWithApple();

  Future<Session> signUpWithEmail({required String name, required String email, required String password});
  Future<Session> signInWithEmail({required String email, required String password});

  /// Sends a reset link. Says the same whether or not the email has an
  /// account, so nobody can use it to find out who is signed up.
  Future<void> sendPasswordReset(String email);

  /// Texts a 6 digit code to [phone] (international format).
  Future<void> sendPhoneCode(String phone);
  Future<Session> verifyPhoneCode({required String phone, required String code});

  Future<void> signOut();

  /// Change the name, email or phone on the account. A new email or phone
  /// is confirmed by the server (a link or a code) before it is used to sign in.
  Future<Session> updateProfile({String? name, String? email, String? phone});

  /// Email accounts only. Throws an AuthFailure if [current] is wrong.
  Future<void> changePassword({required String current, required String next});

  /// Deletes the account and everything it owns, then signs out. Apple and
  /// Google Play both require this to be possible from inside the app.
  Future<void> deleteAccount();
}

// ─── Auth Repository (demo) ───────────────────────────────────────
// Accounts kept on the phone so every sign in screen can be tried with no
// server. The texted code is always 123456 (the code screen says so in the
// development flavor only).
import 'package:domease/data/model/json.dart';
import 'package:domease/data/model/session_json.dart';
import 'package:domease/data/repositories/auth/auth_repository.dart';
import 'package:domease/data/services/prefs_store.dart';
import 'package:domease/domain/models/failure.dart';
import 'package:domease/domain/models/session.dart';

const demoCode = '123456';

class AuthRepositoryLocal implements AuthRepository {
  AuthRepositoryLocal(this._store, this._onToken);

  final PrefsStore _store;
  final void Function(String? token) _onToken;

  Future<Session> _start(SignInMethod method, {String? name, String? email, String? phone}) async {
    final id = 'user_${(email ?? phone ?? name ?? method.name).hashCode.abs()}';
    final session = Session(userId: id, token: 'demo.$id', method: method, name: name, email: email, phone: phone);
    await _store.write('session', sessionToJson(session));
    _onToken(session.token);
    return session;
  }

  Future<Json> _accounts() async => (await _store.read('demo_accounts') as Json?) ?? <String, dynamic>{};

  @override
  Future<Session?> current() async {
    final json = await _store.read('session');
    final s = json == null ? null : sessionFromJson(json as Json);
    _onToken(s?.token);
    return s;
  }

  @override
  Future<Session> signInWithGoogle() => _start(SignInMethod.google, name: 'Sarah Namukasa', email: 'sarah.namukasa@gmail.com');

  @override
  Future<Session> signInWithApple() => _start(SignInMethod.apple, name: 'Sarah Namukasa', email: 'sarah@icloud.com');

  @override
  Future<Session> signUpWithEmail({required String name, required String email, required String password}) async {
    final key = email.trim().toLowerCase();
    final accounts = await _accounts();
    if (accounts.containsKey(key)) throw const AuthFailure('There is already an account with that email. Log in instead.');
    await _store.write('demo_accounts', {...accounts, key: {'name': name, 'password': password}});
    return _start(SignInMethod.email, name: name, email: key);
  }

  @override
  Future<Session> signInWithEmail({required String email, required String password}) async {
    final key = email.trim().toLowerCase();
    final account = (await _accounts())[key] as Json?;
    if (account == null) throw const AuthFailure('No account uses that email. Create one instead.');
    if (account['password'] != password) throw const AuthFailure('That password is not right. Try again, or reset it.');
    return _start(SignInMethod.email, name: account['name'] as String?, email: key);
  }

  @override
  Future<void> sendPasswordReset(String email) async {}

  @override
  Future<void> sendPhoneCode(String phone) async {}

  @override
  Future<Session> verifyPhoneCode({required String phone, required String code}) async {
    if (code != demoCode) throw const AuthFailure('That code is not right. Check the text and try again.');
    return _start(SignInMethod.phone, phone: phone);
  }

  @override
  Future<void> signOut() async {
    await _store.remove('session');
    _onToken(null);
  }

  Future<Session> _current() async {
    final s = await current();
    if (s == null) throw const AuthFailure('Your session has ended. Log in again.');
    return s;
  }

  @override
  Future<Session> updateProfile({String? name, String? email, String? phone}) async {
    final s = (await _current()).copyWith(name: name, email: email?.trim().toLowerCase(), phone: phone);
    await _store.write('session', sessionToJson(s));
    return s;
  }

  @override
  Future<void> changePassword({required String current, required String next}) async {
    final s = await _current();
    final key = s.email ?? '';
    final accounts = await _accounts();
    final account = accounts[key] as Json?;
    if (account == null || account['password'] != current) throw const AuthFailure('Your current password is not right.');
    await _store.write('demo_accounts', {...accounts, key: {...account, 'password': next}});
  }

  @override
  Future<void> deleteAccount() async {
    final s = await current();
    final accounts = await _accounts();
    if (s?.email != null && accounts.containsKey(s!.email)) {
      await _store.write('demo_accounts', {...accounts}..remove(s.email));
    }
    // Everything the demo kept for this account goes with it.
    for (final key in const ['household', 'zones', 'shop', 'meal_plan', 'favourites', 'suggestions', 'preferences']) {
      await _store.remove(key);
    }
    await signOut();
  }
}

// ─── Auth Repository (API) ────────────────────────────────────────
import 'package:domease/data/model/json.dart';
import 'package:domease/data/model/session_json.dart';
import 'package:domease/data/repositories/auth/auth_repository.dart';
import 'package:domease/data/services/api/api_client.dart';
import 'package:domease/data/services/prefs_store.dart';
import 'package:domease/data/services/social_sign_in.dart';
import 'package:domease/domain/models/failure.dart';
import 'package:domease/domain/models/session.dart';

/// The API answers every sign in with `{ token, user }` (docs/04-api-contract.md).
class AuthRepositoryRemote implements AuthRepository {
  AuthRepositoryRemote(this._api, this._store, this._social, this._onToken);

  final ApiClient _api;
  final PrefsStore _store;
  final SocialSignIn _social;
  final void Function(String? token) _onToken;

  Future<Session> _session(String path, Json body, SignInMethod method) async {
    try {
      final session = sessionFromApi(await _api.post(path, body) as Json, method);
      await _store.write('session', sessionToJson(session));
      _onToken(session.token);
      return session;
    } on ServerFailure catch (e) {
      // The API's own sentence ("That code has expired") is the clearest.
      throw AuthFailure(e.message);
    }
  }

  @override
  Future<Session?> current() async {
    final json = await _store.read('session');
    final s = json == null ? null : sessionFromJson(json as Json);
    _onToken(s?.token);
    return s;
  }

  @override
  Future<Session> signInWithGoogle() async {
    final t = await _social.google();
    return _session('/auth/google', {'idToken': t.idToken}, SignInMethod.google);
  }

  @override
  Future<Session> signInWithApple() async {
    final t = await _social.apple();
    return _session('/auth/apple', {'idToken': t.idToken, if (t.name != null) 'name': t.name}, SignInMethod.apple);
  }

  @override
  Future<Session> signUpWithEmail({required String name, required String email, required String password}) =>
      _session('/auth/email/sign-up', {'name': name, 'email': email, 'password': password}, SignInMethod.email);

  @override
  Future<Session> signInWithEmail({required String email, required String password}) =>
      _session('/auth/email/sign-in', {'email': email, 'password': password}, SignInMethod.email);

  @override
  Future<void> sendPasswordReset(String email) async {
    await _api.post('/auth/password/forgot', {'email': email});
  }

  @override
  Future<void> sendPhoneCode(String phone) async {
    await _api.post('/auth/phone/start', {'phone': phone});
  }

  @override
  Future<Session> verifyPhoneCode({required String phone, required String code}) =>
      _session('/auth/phone/verify', {'phone': phone, 'code': code}, SignInMethod.phone);

  @override
  Future<void> signOut() async {
    await _store.remove('session');
    _onToken(null);
  }

  @override
  Future<Session> updateProfile({String? name, String? email, String? phone}) async {
    final json = await _store.read('session');
    if (json == null) throw const AuthFailure('Your session has ended. Log in again.');
    final old = sessionFromJson(json as Json);
    try {
      final user = await _api.patch('/me', {'name': ?name, 'email': ?email, 'phone': ?phone}) as Json;
      final s = sessionFromApi({'token': old.token, 'user': user}, old.method);
      await _store.write('session', sessionToJson(s));
      return s;
    } on ServerFailure catch (e) {
      throw AuthFailure(e.message);
    }
  }

  @override
  Future<void> changePassword({required String current, required String next}) async {
    try {
      await _api.post('/me/password', {'current': current, 'next': next});
    } on ServerFailure catch (e) {
      throw AuthFailure(e.message);
    }
  }

  @override
  Future<void> deleteAccount() async {
    await _api.delete('/me');
    for (final key in const ['household', 'preferences']) {
      await _store.remove(key);
    }
    await signOut();
  }
}

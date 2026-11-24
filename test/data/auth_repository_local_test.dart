// ─── Demo Auth Tests ──────────────────────────────────────────────
// The development flavor's accounts behave like the real ones will.
import 'package:flutter_test/flutter_test.dart';

import 'package:domease/data/repositories/auth/auth_repository_local.dart';
import 'package:domease/domain/models/failure.dart';
import 'package:domease/domain/models/session.dart';

import '../../testing/fakes.dart';

void main() {
  late AuthRepositoryLocal auth;
  String? token;

  setUp(() {
    token = null;
    auth = AuthRepositoryLocal(MemoryPrefsStore(), (t) => token = t);
  });

  test('sign up, sign out, log back in', () async {
    final s = await auth.signUpWithEmail(name: 'Pearl', email: 'Pearl@DomEase.app', password: 'homelife1');
    expect(s.email, 'pearl@domease.app');
    expect(token, s.token);
    await auth.signOut();
    expect(await auth.current(), isNull);
    expect(token, isNull);
    final back = await auth.signInWithEmail(email: 'pearl@domease.app', password: 'homelife1');
    expect(back.method, SignInMethod.email);
  });

  test('wrong password and unknown email say so', () async {
    await auth.signUpWithEmail(name: 'Pearl', email: 'pearl@domease.app', password: 'homelife1');
    expect(() => auth.signInWithEmail(email: 'pearl@domease.app', password: 'nope1234'), throwsA(isA<AuthFailure>()));
    expect(() => auth.signInWithEmail(email: 'who@domease.app', password: 'homelife1'), throwsA(isA<AuthFailure>()));
  });

  test('the phone code is checked', () async {
    expect(() => auth.verifyPhoneCode(phone: '+256772123456', code: '000000'), throwsA(isA<AuthFailure>()));
    final s = await auth.verifyPhoneCode(phone: '+256772123456', code: demoCode);
    expect(s.phone, '+256772123456');
    expect((await auth.current())?.userId, s.userId);
  });
}

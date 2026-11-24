// ─── Account and Preferences Tests ────────────────────────────────
import 'package:flutter_test/flutter_test.dart';

import 'package:domease/data/repositories/auth/auth_repository_local.dart';
import 'package:domease/data/repositories/preferences/preferences_repository.dart';
import 'package:domease/domain/models/failure.dart';
import 'package:domease/domain/models/preferences.dart';

import '../../testing/fakes.dart';

void main() {
  test('profile changes, password change and account deletion', () async {
    final store = MemoryPrefsStore();
    final auth = AuthRepositoryLocal(store, (_) {});
    await auth.signUpWithEmail(name: 'Pearl', email: 'pearl@example.com', password: 'home2026');

    final renamed = await auth.updateProfile(name: 'Pearl A');
    expect(renamed.name, 'Pearl A');
    expect((await auth.current())!.name, 'Pearl A');

    await expectLater(auth.changePassword(current: 'wrong123', next: 'newhome1'), throwsA(isA<AuthFailure>()));
    await auth.changePassword(current: 'home2026', next: 'newhome1');
    await auth.signOut();
    await auth.signInWithEmail(email: 'pearl@example.com', password: 'newhome1');

    await store.write('household', {'id': 'h'});
    await auth.deleteAccount();
    expect(await auth.current(), isNull);
    expect(await store.read('household'), isNull);
    await expectLater(auth.signInWithEmail(email: 'pearl@example.com', password: 'newhome1'), throwsA(isA<AuthFailure>()));
  });

  test('preferences default sensibly and survive a restart', () async {
    final store = MemoryPrefsStore();
    expect((await PreferencesRepository(store).load()).appearance, Appearance.system);
    await PreferencesRepository(store).save(const Preferences(appearance: Appearance.dark, remindTasks: false));
    final again = await PreferencesRepository(store).load();
    expect(again.appearance, Appearance.dark);
    expect(again.remindTasks, isFalse);
    expect(again.remindLowStock, isTrue);
  });
}

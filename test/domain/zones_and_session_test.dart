// ─── Zones and Session Tests ──────────────────────────────────────
import 'package:flutter_test/flutter_test.dart';

import 'package:domease/domain/models/session.dart';
import 'package:domease/domain/models/zone.dart';
import 'package:domease/domain/models/zone_presets.dart';

void main() {
  test('a preset zone comes with its starter tasks and unique ids', () {
    final compound = zonePresets.firstWhere((p) => p.name == 'Compound').build('zone_1');
    expect(compound.name, 'Compound');
    expect(compound.tasks, isNotEmpty);
    expect(compound.tasks.map((t) => t.id).toSet().length, compound.tasks.length);
    expect(compound.tasks.every((t) => t.id.startsWith('zone_1_')), isTrue);
    expect(compound.consumables.map((c) => c.name), contains('Rubbish sacks'));
  });

  test('assigning someone and clearing them again', () {
    const zone = Zone(id: 'z', name: 'Veranda', tasks: [], consumables: []);
    expect(zone.withAssignee('Grace').assignee, 'Grace');
    expect(zone.withAssignee('Grace').withAssignee('').assignee, isNull);
  });

  test('initials and what can be changed per sign in method', () {
    const google = Session(userId: 'u', token: 't', method: SignInMethod.google, name: 'Sarah Namukasa');
    expect(google.initials, 'SN');
    expect(google.canChangeEmail, isFalse);
    expect(google.hasPassword, isFalse);
    const email = Session(userId: 'u', token: 't', method: SignInMethod.email, email: 'pearl@example.com');
    expect(email.initials, 'P');
    expect(email.hasPassword, isTrue);
  });
}

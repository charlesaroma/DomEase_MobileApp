// ─── Payroll View Models ──────────────────────────────────────────
// A fair record of pay for whoever helps at home (Premium).
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:domease/config/dependencies.dart';
import 'package:domease/domain/models/insights.dart';
import 'package:domease/domain/use_cases/insights.dart';
import 'package:domease/ui/core/view_models/household_viewmodel.dart';

final staffProvider = AsyncNotifierProvider<StaffNotifier, List<Staff>>(StaffNotifier.new);

class StaffNotifier extends AsyncNotifier<List<Staff>> {
  @override
  Future<List<Staff>> build() => ref.watch(insightsRepositoryProvider).staff();

  Future<void> _set(List<Staff> next) async {
    state = AsyncData(next);
    await ref.read(insightsRepositoryProvider).saveStaff(next);
  }

  Future<List<Staff>> get _now async => state.value ?? await future;

  /// Adds someone new, or saves changes to someone already there.
  Future<void> upsert(Staff person) async {
    final list = await _now;
    await _set(list.any((p) => p.id == person.id) ? [for (final p in list) p.id == person.id ? person : p] : [...list, person]);
  }

  Future<void> remove(String id) async => _set([for (final p in await _now) if (p.id != id) p]);

  Future<void> addEntry(String staffId, PayEntry entry) async =>
      _set([for (final p in await _now) p.id == staffId ? p.copyWith(entries: [...p.entries, entry]) : p]);

  Future<void> removeEntry(String staffId, String entryId) async =>
      _set([for (final p in await _now) p.id == staffId ? p.copyWith(entries: [for (final e in p.entries) if (e.id != entryId) e]) : p]);

  Future<void> restore(List<Staff> before) => _set(before);
}

/// Paydays in the next three days with pay still owed, for Today (Premium only).
final paydaysDueProvider = Provider<List<(Staff, int days, int owed)>>((ref) {
  if (!ref.watch(isPremiumProvider)) return const [];
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return [
    for (final s in ref.watch(staffProvider).value ?? const <Staff>[])
      if (nextPayday(s).difference(today).inDays <= 3 && payMonth(s).owed > 0) (s, nextPayday(s).difference(today).inDays, payMonth(s).owed),
  ];
});

// ─── Clean View Model ─────────────────────────────────────────────
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:domease/config/dependencies.dart';
import 'package:domease/domain/models/zone.dart';
import 'package:domease/domain/models/zone_presets.dart';
import 'package:domease/ui/core/view_models/content_viewmodel.dart';

final zonesProvider = AsyncNotifierProvider<ZonesNotifier, List<Zone>>(ZonesNotifier.new);

/// Ticking a task, changing how often it repeats, marking a consumable low.
/// Each change shows at once and is saved behind it.
class ZonesNotifier extends AsyncNotifier<List<Zone>> {
  @override
  Future<List<Zone>> build() => ref.watch(zoneRepositoryProvider).zones();

  Future<void> _update(String zoneId, Zone Function(Zone) change) async {
    final zones = [for (final z in state.value ?? const <Zone>[]) z.id == zoneId ? change(z) : z];
    state = AsyncData(zones);
    await ref.read(zoneRepositoryProvider).save(zones);
  }

  Future<void> toggleTask(String zoneId, String taskId) => _update(zoneId, (z) {
        final tasks = [for (final t in z.tasks) t.id == taskId ? t.copyWith(done: !t.done) : t];
        final wasClear = z.clear;
        final next = z.copyWith(tasks: tasks);
        // A streak grows the moment a zone is cleared (FR-HM-2).
        return next.clear && !wasClear ? next.copyWith(streak: z.streak + 1) : next;
      });

  Future<void> setFrequency(String zoneId, String taskId, Frequency f) =>
      _update(zoneId, (z) => z.copyWith(tasks: [for (final t in z.tasks) t.id == taskId ? t.copyWith(frequency: f) : t]));

  Future<void> toggleLow(String zoneId, String consumableId) => _update(
      zoneId, (z) => z.copyWith(consumables: [for (final c in z.consumables) c.id == consumableId ? c.copyWith(low: !c.low) : c]));

  Future<void> addTask(String zoneId, String label) => _update(
      zoneId,
      (z) => z.copyWith(tasks: [
            ...z.tasks,
            ZoneTask(id: '${zoneId}_${DateTime.now().millisecondsSinceEpoch}', label: label, frequency: Frequency.weekly),
          ]));

  Future<void> rename(String zoneId, String name) => _update(zoneId, (z) => z.copyWith(name: name));

  Future<void> removeTask(String zoneId, String taskId) =>
      _update(zoneId, (z) => z.copyWith(tasks: [for (final t in z.tasks) if (t.id != taskId) t]));

  Future<void> restoreTask(String zoneId, ZoneTask task) =>
      _update(zoneId, (z) => z.tasks.any((t) => t.id == task.id) ? z : z.copyWith(tasks: [...z.tasks, task]));

  Future<void> addSupply(String zoneId, String name) => _update(
      zoneId,
      (z) => z.copyWith(consumables: [
            ...z.consumables,
            Consumable(id: '${zoneId}_c${DateTime.now().millisecondsSinceEpoch}', name: name, cycle: Frequency.monthly),
          ]));

  Future<void> removeSupply(String zoneId, String consumableId) =>
      _update(zoneId, (z) => z.copyWith(consumables: [for (final c in z.consumables) if (c.id != consumableId) c]));

  /// Who looks after the zone; an empty name clears it.
  Future<void> assign(String zoneId, String? person) => _update(zoneId, (z) => z.withAssignee(person));

  /// Adds a zone from a preset, or an empty one with the household's own name.
  Future<Zone> addZone({ZonePreset? preset, String? name}) async {
    final id = 'zone_${DateTime.now().millisecondsSinceEpoch}';
    final zone = preset?.build(id) ?? Zone(id: id, name: name!.trim(), tasks: const [], consumables: const []);
    final zones = [...?state.value, zone];
    state = AsyncData(zones);
    await ref.read(zoneRepositoryProvider).save(zones);
    return zone;
  }

  Future<void> removeZone(String zoneId) async {
    final zones = [for (final z in state.value ?? const <Zone>[]) if (z.id != zoneId) z];
    state = AsyncData(zones);
    await ref.read(zoneRepositoryProvider).save(zones);
  }

  /// Puts a removed zone back exactly as it was (the Undo on the snackbar).
  Future<void> restoreZone(Zone zone, int index) async {
    final zones = [...?state.value]..insert(index.clamp(0, state.value?.length ?? 0), zone);
    state = AsyncData(zones);
    await ref.read(zoneRepositoryProvider).save(zones);
  }

  Future<void> move(int from, int to) async {
    final zones = [...?state.value];
    if (from < 0 || from >= zones.length) return;
    final z = zones.removeAt(from);
    zones.insert(to > from ? to - 1 : to, z);
    state = AsyncData(zones);
    await ref.read(zoneRepositoryProvider).save(zones);
  }
}

/// Presets not already in the household, by name.
final zoneSuggestionsProvider = Provider<List<ZonePreset>>((ref) {
  final names = {for (final z in ref.watch(zonesProvider).value ?? const <Zone>[]) z.name.toLowerCase()};
  final presets = ref.watch(zonePresetsProvider).value ?? zonePresets;
  return [for (final p in presets) if (!names.contains(p.name.toLowerCase())) p];
});

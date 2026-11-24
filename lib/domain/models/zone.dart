// ─── Zone ─────────────────────────────────────────────────────────
// An area of the home with its own tasks and consumables (FR-HM-1 to FR-HM-4).

enum Frequency {
  daily('Daily'),
  weekly('Weekly'),
  monthly('Monthly');

  const Frequency(this.label);
  final String label;
}

class ZoneTask {
  const ZoneTask({required this.id, required this.label, required this.frequency, this.done = false});

  final String id;
  final String label;
  final Frequency frequency;
  final bool done;

  ZoneTask copyWith({String? label, Frequency? frequency, bool? done}) =>
      ZoneTask(id: id, label: label ?? this.label, frequency: frequency ?? this.frequency, done: done ?? this.done);
}

class Consumable {
  const Consumable({required this.id, required this.name, required this.cycle, this.low = false});

  final String id;
  final String name;
  final Frequency cycle;

  /// Marked low: it goes on the Household part of the list (FR-HM-4).
  final bool low;

  Consumable copyWith({bool? low}) => Consumable(id: id, name: name, cycle: cycle, low: low ?? this.low);
}

class Zone {
  const Zone({
    required this.id,
    required this.name,
    required this.tasks,
    required this.consumables,
    this.assignee,
    this.streak = 0,
  });

  final String id;
  final String name;
  final List<ZoneTask> tasks;
  final List<Consumable> consumables;

  /// Who it belongs to this week; House Help sees only their zones.
  final String? assignee;
  final int streak;

  int get done => tasks.where((t) => t.done).length;
  double get progress => tasks.isEmpty ? 0 : done / tasks.length;
  bool get clear => tasks.isNotEmpty && done == tasks.length;

  /// copyWith cannot clear a field, so assigning has its own method.
  Zone withAssignee(String? person) => Zone(
        id: id,
        name: name,
        tasks: tasks,
        consumables: consumables,
        assignee: (person == null || person.trim().isEmpty) ? null : person.trim(),
        streak: streak,
      );

  Zone copyWith({String? name, List<ZoneTask>? tasks, List<Consumable>? consumables, String? assignee, int? streak}) => Zone(
        id: id,
        name: name ?? this.name,
        tasks: tasks ?? this.tasks,
        consumables: consumables ?? this.consumables,
        assignee: assignee ?? this.assignee,
        streak: streak ?? this.streak,
      );
}

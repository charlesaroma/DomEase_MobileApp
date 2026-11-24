// ─── Zone JSON ────────────────────────────────────────────────────
import 'package:domease/data/model/json.dart';
import 'package:domease/domain/models/zone.dart';

Zone zoneFromJson(Json j) => Zone(
      id: j['id'] as String,
      name: j['name'] as String,
      assignee: j['assignee'] as String?,
      streak: toIntOrNull(j['streakCount']) ?? 0,
      tasks: [
        for (final t in (j['tasks'] as List?) ?? const [])
          ZoneTask(
            id: (t as Json)['id'] as String,
            label: t['label'] as String,
            frequency: byName(Frequency.values, t['frequency'], Frequency.weekly),
            done: t['done'] == true,
          ),
      ],
      consumables: [
        for (final c in (j['consumables'] as List?) ?? const [])
          Consumable(
            id: (c as Json)['id'] as String,
            name: c['name'] as String,
            cycle: byName(Frequency.values, c['replenishmentCycle'], Frequency.monthly),
            low: c['isLowStock'] == true,
          ),
      ],
    );

Json zoneToJson(Zone z) => {
      'id': z.id,
      'name': z.name,
      'assignee': z.assignee,
      'streakCount': z.streak,
      'tasks': [for (final t in z.tasks) {'id': t.id, 'label': t.label, 'frequency': t.frequency.name, 'done': t.done}],
      'consumables': [
        for (final c in z.consumables) {'id': c.id, 'name': c.name, 'replenishmentCycle': c.cycle.name, 'isLowStock': c.low},
      ],
    };

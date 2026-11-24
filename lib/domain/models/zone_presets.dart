// ─── Zone Presets ─────────────────────────────────────────────────
// Ready made zones a household can add beside the four it starts with, each
// with sensible starter tasks and supplies. Everything stays editable, and a
// household can also add a zone with a name of its own.
import 'package:domease/domain/models/zone.dart';

class ZonePreset {
  const ZonePreset(this.name, this.tasks, [this.supplies = const []]);

  final String name;
  final List<(String, Frequency)> tasks;
  final List<(String, Frequency)> supplies;

  /// A new zone from this preset, with ids unique to this household.
  Zone build(String id) => Zone(
        id: id,
        name: name,
        tasks: [for (final (i, (label, f)) in tasks.indexed) ZoneTask(id: '${id}_t$i', label: label, frequency: f)],
        consumables: [for (final (i, (name, f)) in supplies.indexed) Consumable(id: '${id}_c$i', name: name, cycle: f)],
      );
}

const zonePresets = [
  ZonePreset('Compound', [
    ('Sweep the compound', Frequency.daily),
    ('Collect and burn or bag rubbish', Frequency.weekly),
    ('Clear the drainage', Frequency.weekly),
    ('Slash the grass', Frequency.monthly),
  ], [
    ('Rubbish sacks', Frequency.monthly),
    ('Hard broom', Frequency.monthly),
  ]),
  ZonePreset('Laundry', [
    ('Wash the clothes', Frequency.weekly),
    ('Iron and fold', Frequency.weekly),
    ('Wash the bedding', Frequency.weekly),
  ], [
    ('Washing powder', Frequency.monthly),
    ('Bar soap', Frequency.monthly),
  ]),
  ZonePreset('Veranda', [
    ('Sweep the veranda', Frequency.daily),
    ('Mop the floor', Frequency.weekly),
    ('Wipe the chairs and table', Frequency.weekly),
  ]),
  ZonePreset('Dining room', [
    ('Wipe the table after meals', Frequency.daily),
    ('Mop the floor', Frequency.weekly),
    ('Dust the cupboards', Frequency.weekly),
  ]),
  ZonePreset("Children's room", [
    ('Make the beds', Frequency.daily),
    ('Pack away toys and books', Frequency.daily),
    ('Change the bedding', Frequency.weekly),
  ]),
  ZonePreset('Store', [
    ('Tidy the shelves', Frequency.weekly),
    ('Check for pests', Frequency.monthly),
    ('Throw out what has expired', Frequency.monthly),
  ]),
  ZonePreset('Garden', [
    ('Water the plants', Frequency.daily),
    ('Weed the beds', Frequency.weekly),
    ('Trim the hedge', Frequency.monthly),
  ]),
  ZonePreset('Animals', [
    ('Feed and give water', Frequency.daily),
    ('Clean the shelter', Frequency.weekly),
  ], [
    ('Animal feed', Frequency.weekly),
  ]),
  ZonePreset('Car', [
    ('Wash the outside', Frequency.weekly),
    ('Clean the inside', Frequency.monthly),
  ]),
  ZonePreset('Kitchen', [
    ('Wash the dishes', Frequency.daily),
    ('Wipe the counters', Frequency.daily),
    ('Clean the stove', Frequency.weekly),
  ], [
    ('Dish soap', Frequency.monthly),
  ]),
  ZonePreset('Bathroom and toilet', [
    ('Clean the toilet', Frequency.daily),
    ('Scrub the shower', Frequency.weekly),
  ], [
    ('Toilet paper', Frequency.weekly),
  ]),
  ZonePreset('Bedrooms', [
    ('Make the beds', Frequency.daily),
    ('Change the bedding', Frequency.weekly),
  ]),
  ZonePreset('Living room', [
    ('Tidy and dust', Frequency.daily),
    ('Mop the floor', Frequency.weekly),
  ]),
];

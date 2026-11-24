// ─── Zone Menu ────────────────────────────────────────────────────
// The three dots on a zone: rename it, give it to someone, add a supply,
// move it, or remove it (with Undo, so nothing is lost by a slip).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:domease/domain/models/household.dart';
import 'package:domease/domain/models/zone.dart';
import 'package:domease/ui/clean/view_models/clean_viewmodel.dart';
import 'package:domease/ui/core/view_models/household_viewmodel.dart';

enum _Action { rename, assign, supply, up, down, remove }

class ZoneMenu extends ConsumerWidget {
  const ZoneMenu({super.key, required this.zone, required this.index, required this.count});

  final Zone zone;
  final int index;
  final int count;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final zones = ref.read(zonesProvider.notifier);

    Future<void> run(_Action a) async {
      switch (a) {
        case _Action.rename:
          final name = await askText(context, title: 'Rename zone', label: 'Zone name', initial: zone.name, action: 'Save');
          if (name != null && name.isNotEmpty) await zones.rename(zone.id, name);
        case _Action.assign:
          final household = ref.read(householdProvider).value;
          if (!context.mounted) return;
          final person = await _askPerson(context, zone, household);
          if (person != null) await zones.assign(zone.id, person);
        case _Action.supply:
          final name = await askText(context, title: 'Add a supply', label: 'What runs out here?', hint: 'Bleach, brooms', action: 'Add');
          if (name != null && name.isNotEmpty) await zones.addSupply(zone.id, name);
        case _Action.up:
          await zones.move(index, index - 1);
        case _Action.down:
          await zones.move(index, index + 2);
        case _Action.remove:
          await zones.removeZone(zone.id);
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('${zone.name} removed.'),
            action: SnackBarAction(label: 'Undo', onPressed: () => zones.restoreZone(zone, index)),
          ));
      }
    }

    return PopupMenuButton<_Action>(
      tooltip: 'Zone options',
      icon: Icon(Icons.more_vert, color: Theme.of(context).colorScheme.outline),
      onSelected: run,
      itemBuilder: (_) => [
        const PopupMenuItem(value: _Action.rename, child: ListTile(leading: Icon(Icons.edit_outlined), title: Text('Rename'))),
        const PopupMenuItem(value: _Action.assign, child: ListTile(leading: Icon(Icons.person_outline), title: Text('Who looks after it'))),
        const PopupMenuItem(value: _Action.supply, child: ListTile(leading: Icon(Icons.inventory_2_outlined), title: Text('Add a supply'))),
        if (index > 0) const PopupMenuItem(value: _Action.up, child: ListTile(leading: Icon(Icons.arrow_upward), title: Text('Move up'))),
        if (index < count - 1)
          const PopupMenuItem(value: _Action.down, child: ListTile(leading: Icon(Icons.arrow_downward), title: Text('Move down'))),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: _Action.remove,
          child: ListTile(
            leading: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
            title: Text('Remove zone', style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ),
      ],
    );
  }
}

/// A one field dialog. Returns the trimmed text, or null when cancelled.
Future<String?> askText(BuildContext context,
    {required String title, required String label, required String action, String initial = '', String? hint}) {
  final text = TextEditingController(text: initial);
  return showDialog<String>(
    context: context,
    builder: (c) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: text,
        autofocus: true,
        maxLength: 40,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(labelText: label, hintText: hint),
        onSubmitted: (v) => Navigator.pop(c, v.trim()),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(c, text.text.trim()), child: Text(action)),
      ],
    ),
  );
}

/// The people at home plus House Help, or anyone typed in. '' clears it.
Future<String?> _askPerson(BuildContext context, Zone zone, Household? household) {
  final names = <String>{
    for (final m in household?.members ?? const <HouseholdMember>[]) if (m.name.trim().isNotEmpty) m.name.trim(),
    'House Help',
  };
  return showModalBottomSheet<String>(
    context: context,
    useSafeArea: true,
    constraints: const BoxConstraints(maxWidth: 640),
    builder: (c) => ListView(shrinkWrap: true, children: [
      ListTile(title: Text('Who looks after ${zone.name}?', style: Theme.of(c).textTheme.titleMedium)),
      for (final n in names)
        ListTile(
          leading: CircleAvatar(child: Text(n[0])),
          title: Text(n),
          trailing: zone.assignee == n ? Icon(Icons.check, color: Theme.of(c).colorScheme.primary) : null,
          onTap: () => Navigator.pop(c, n),
        ),
      ListTile(
        leading: const Icon(Icons.person_add_alt_1_outlined),
        title: const Text('Someone else'),
        onTap: () async {
          final n = await askText(c, title: 'Who looks after it?', label: 'Name', action: 'Save');
          if (c.mounted) Navigator.pop(c, n);
        },
      ),
      if (zone.assignee != null)
        ListTile(leading: const Icon(Icons.close), title: const Text('Nobody for now'), onTap: () => Navigator.pop(c, '')),
      const SizedBox(height: 8),
    ]),
  );
}

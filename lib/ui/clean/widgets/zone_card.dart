// ─── Zone Card ────────────────────────────────────────────────────
// Closed: name, who it belongs to, progress and streak. Open: the tasks and
// the consumables. Marking a consumable low puts it on the shopping list.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:domease/domain/models/zone.dart';
import 'package:domease/ui/clean/view_models/clean_viewmodel.dart';
import 'package:domease/ui/clean/widgets/zone_menu.dart';
import 'package:domease/ui/core/themes/tokens.dart';
import 'package:domease/ui/core/themes/typography.dart';
import 'package:domease/ui/core/ui/status_pill.dart';

class ZoneCard extends ConsumerStatefulWidget {
  const ZoneCard({super.key, required this.zone, required this.index, required this.count, this.startOpen = false});

  final Zone zone;

  /// Where it sits in the rota, for Move up and Move down.
  final int index;
  final int count;

  /// A zone that was just added opens straight away, ready for its tasks.
  final bool startOpen;

  @override
  ConsumerState<ZoneCard> createState() => _ZoneCardState();
}

class _ZoneCardState extends ConsumerState<ZoneCard> {
  late bool _open = widget.startOpen;

  @override
  Widget build(BuildContext context) {
    final z = widget.zone;
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final zones = ref.read(zonesProvider.notifier);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpace.md),
      clipBehavior: Clip.antiAlias,
      child: Column(children: [
        // ── Header ──
        InkWell(
          onTap: () => setState(() => _open = !_open),
          child: Padding(
            padding: const EdgeInsets.all(AppSpace.lg),
            child: Column(children: [
              Row(children: [
                Icon(Icons.auto_awesome_outlined, size: 18, color: dark ? AppColors.sage400 : AppColors.sage),
                const SizedBox(width: AppSpace.sm),
                Expanded(
                  child: Text.rich(TextSpan(children: [
                    TextSpan(text: z.name, style: AppText.subheading.copyWith(color: scheme.onSurface)),
                    if (z.assignee != null) TextSpan(text: '  ·  ${z.assignee}', style: Theme.of(context).textTheme.bodySmall),
                  ])),
                ),
                if (z.clear)
                  const StatusPill(label: 'Clear', icon: Icons.check_circle_outline, tone: PillTone.good)
                else
                  Text('${(z.progress * 100).round()}%', style: AppText.money.copyWith(fontSize: 13, color: scheme.onSurface)),
                Icon(_open ? Icons.expand_less : Icons.expand_more, color: scheme.outline),
                ZoneMenu(zone: z, index: widget.index, count: widget.count),
              ]),
              const SizedBox(height: AppSpace.md),
              ClipRRect(borderRadius: AppRadii.pillAll, child: LinearProgressIndicator(value: z.progress, minHeight: 6)),
              if (z.streak > 0) ...[
                const SizedBox(height: AppSpace.sm),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.local_fire_department_outlined, size: 16, color: scheme.primary),
                    const SizedBox(width: AppSpace.xs),
                    Text('${z.streak} day streak', style: AppText.caption.copyWith(color: scheme.primary)),
                  ]),
                ),
              ],
            ]),
          ),
        ),

        // ── Tasks and consumables ──
        if (_open) ...[
          const Divider(),
          if (z.tasks.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpace.lg, AppSpace.md, AppSpace.lg, 0),
              child: Text('No tasks yet. Add the first one below.', style: Theme.of(context).textTheme.bodySmall),
            ),
          for (final t in z.tasks)
            // Swipe a task away to remove it; Undo brings it back.
            Dismissible(
              key: ValueKey(t.id),
              direction: DismissDirection.endToStart,
              background: Container(
                color: scheme.error,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: AppSpace.xl),
                child: const Icon(Icons.delete_outline, color: AppColors.white),
              ),
              onDismissed: (_) {
                zones.removeTask(z.id, t.id);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('"${t.label}" removed.'),
                  action: SnackBarAction(label: 'Undo', onPressed: () => zones.restoreTask(z.id, t)),
                ));
              },
              child: CheckboxListTile(
                value: t.done,
                onChanged: (_) => zones.toggleTask(z.id, t.id),
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(t.label, style: AppText.body.copyWith(color: scheme.onSurface, decoration: t.done ? TextDecoration.lineThrough : null)),
                secondary: _FrequencyButton(frequency: t.frequency, onChanged: (f) => zones.setFrequency(z.id, t.id, f)),
              ),
            ),
          _AddTask(onAdd: (label) => zones.addTask(z.id, label)),
          if (z.consumables.isNotEmpty) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpace.lg, AppSpace.sm, AppSpace.lg, AppSpace.xs),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('RUNNING LOW?', style: AppText.eyebrow.copyWith(color: Theme.of(context).textTheme.bodySmall?.color)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpace.lg, AppSpace.sm, AppSpace.lg, AppSpace.lg),
              child: Wrap(spacing: AppSpace.sm, runSpacing: AppSpace.sm, children: [
                for (final c in z.consumables)
                  FilterChip(
                    label: Text(c.name),
                    selected: c.low,
                    avatar: c.low ? const Icon(Icons.warning_amber_rounded, size: 16) : null,
                    showCheckmark: false,
                    deleteIcon: const Icon(Icons.close, size: 16),
                    deleteButtonTooltipMessage: 'Remove ${c.name}',
                    onDeleted: () => zones.removeSupply(z.id, c.id),
                    onSelected: (_) {
                      zones.toggleLow(z.id, c.id);
                      if (!c.low) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${c.name} added to the shopping list.')));
                      }
                    },
                  ),
              ]),
            ),
          ],
        ],
      ]),
    );
  }
}

/// Daily, weekly or monthly, independent of done (FR-HM-3).
class _FrequencyButton extends StatelessWidget {
  const _FrequencyButton({required this.frequency, required this.onChanged});

  final Frequency frequency;
  final ValueChanged<Frequency> onChanged;

  @override
  Widget build(BuildContext context) => PopupMenuButton<Frequency>(
        initialValue: frequency,
        onSelected: onChanged,
        tooltip: 'How often',
        itemBuilder: (_) => [for (final f in Frequency.values) PopupMenuItem(value: f, child: Text(f.label))],
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.sm),
          child: Text(frequency.label, style: AppText.caption.copyWith(color: Theme.of(context).colorScheme.primary)),
        ),
      );
}

class _AddTask extends StatefulWidget {
  const _AddTask({required this.onAdd});

  final ValueChanged<String> onAdd;

  @override
  State<_AddTask> createState() => _AddTaskState();
}

class _AddTaskState extends State<_AddTask> {
  final _text = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _submit() {
    final label = _text.text.trim();
    if (label.isEmpty) return;
    widget.onAdd(label);
    _text.clear();
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(AppSpace.lg, 0, AppSpace.sm, AppSpace.sm),
        child: Row(children: [
          Expanded(
            child: TextField(
              controller: _text,
              onSubmitted: (_) => _submit(),
              decoration: const InputDecoration(hintText: 'Add a task', isDense: true),
            ),
          ),
          IconButton(onPressed: _submit, icon: const Icon(Icons.add), tooltip: 'Add task'),
        ]),
      );
}

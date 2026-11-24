// ─── Add Zone Sheet ───────────────────────────────────────────────
// Every home is shaped differently: a compound, a laundry corner, animals.
// Pick a ready made zone (it comes with starter tasks) or name your own.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:domease/domain/models/zone.dart';
import 'package:domease/domain/models/zone_presets.dart';
import 'package:domease/ui/clean/view_models/clean_viewmodel.dart';
import 'package:domease/ui/core/themes/tokens.dart';
import 'package:domease/ui/core/themes/typography.dart';

/// Returns the zone that was added, or null if the sheet was closed.
Future<Zone?> showAddZoneSheet(BuildContext context) => showModalBottomSheet<Zone>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.stage))),
      constraints: const BoxConstraints(maxWidth: 640),
      builder: (_) => const _AddZone(),
    );

class _AddZone extends ConsumerStatefulWidget {
  const _AddZone();

  @override
  ConsumerState<_AddZone> createState() => _AddZoneState();
}

class _AddZoneState extends ConsumerState<_AddZone> {
  final _name = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _add({ZonePreset? preset}) async {
    final name = _name.text.trim();
    if (preset == null && name.isEmpty) return;
    setState(() => _busy = true);
    final zone = await ref.read(zonesProvider.notifier).addZone(preset: preset, name: name);
    if (mounted) Navigator.of(context).pop(zone);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final suggestions = ref.watch(zoneSuggestionsProvider);
    return Padding(
      padding: EdgeInsets.fromLTRB(AppSpace.screen, AppSpace.xl, AppSpace.screen, MediaQuery.viewInsetsOf(context).bottom + AppSpace.xl),
      child: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text('Add a zone', style: AppText.heading.copyWith(color: scheme.onSurface)),
          const SizedBox(height: AppSpace.xs),
          Text('Any part of your home that needs looking after. You can change its tasks afterwards.',
              style: Theme.of(context).textTheme.bodySmall),
          if (suggestions.isNotEmpty) ...[
            const SizedBox(height: AppSpace.xl),
            Text('READY MADE', style: AppText.eyebrow.copyWith(color: Theme.of(context).textTheme.bodySmall?.color)),
            const SizedBox(height: AppSpace.md),
            Wrap(spacing: AppSpace.sm, runSpacing: AppSpace.sm, children: [
              for (final p in suggestions)
                ActionChip(
                  avatar: Icon(Icons.add, size: 18, color: scheme.primary),
                  label: Text(p.name),
                  tooltip: '${p.tasks.length} starter tasks',
                  onPressed: _busy ? null : () => _add(preset: p),
                ),
            ]),
          ],
          const SizedBox(height: AppSpace.xl),
          Text('YOUR OWN', style: AppText.eyebrow.copyWith(color: Theme.of(context).textTheme.bodySmall?.color)),
          const SizedBox(height: AppSpace.md),
          TextField(
            controller: _name,
            textCapitalization: TextCapitalization.sentences,
            maxLength: 30,
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _add(),
            decoration: const InputDecoration(labelText: 'Zone name', hintText: 'Boys quarters, staircase, shop'),
          ),
          const SizedBox(height: AppSpace.md),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _busy || _name.text.trim().isEmpty ? null : () => _add(),
              child: const Text('Add zone'),
            ),
          ),
        ]),
      ),
    );
  }
}

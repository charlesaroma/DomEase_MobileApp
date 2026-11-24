// ─── Clean ────────────────────────────────────────────────────────
// The rota: every zone with its tasks, how often each repeats, and the
// consumables that run out (FR-HM-1 to FR-HM-4). Households add their own
// zones (a compound, the laundry, animals), rename, reorder and remove them.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:domease/ui/clean/view_models/clean_viewmodel.dart';
import 'package:domease/ui/clean/widgets/add_zone_sheet.dart';
import 'package:domease/ui/clean/widgets/zone_card.dart';
import 'package:domease/ui/core/themes/tokens.dart';
import 'package:domease/ui/core/themes/typography.dart';
import 'package:domease/ui/core/ui/ad_slot.dart';
import 'package:domease/ui/core/ui/async_view.dart';
import 'package:domease/ui/core/ui/readable_width.dart';

class CleanScreen extends ConsumerStatefulWidget {
  const CleanScreen({super.key});

  @override
  ConsumerState<CleanScreen> createState() => _CleanScreenState();
}

class _CleanScreenState extends ConsumerState<CleanScreen> {
  /// The zone just added, opened so its tasks can be filled in.
  String? _added;

  Future<void> _addZone() async {
    final zone = await showAddZoneSheet(context);
    if (zone == null || !mounted) return;
    setState(() => _added = zone.id);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${zone.name} added to the rota.')));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final zones = ref.watch(zonesProvider);
    return Scaffold(
      appBar: AppBar(
        titleSpacing: AppSpace.screen,
        title: Text('Clean', style: AppText.title.copyWith(color: scheme.onSurface)),
        actions: [
          IconButton(onPressed: _addZone, icon: const Icon(Icons.add_circle_outline), tooltip: 'Add a zone'),
          const SizedBox(width: AppSpace.sm),
        ],
      ),
      body: AsyncView(
        value: zones,
        onRetry: () => ref.invalidate(zonesProvider),
        data: (list) => ReadableWidth(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(AppSpace.screen, 0, AppSpace.screen, AppSpace.huge),
            children: [
              Text(
                list.isEmpty
                    ? 'No zones yet. Add the parts of your home that need looking after.'
                    : '${list.length} ${list.length == 1 ? 'zone' : 'zones'}, one rota. ${list.where((z) => z.clear).length} clear today.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpace.lg),
              for (final (i, z) in list.indexed)
                ZoneCard(key: ValueKey(z.id), zone: z, index: i, count: list.length, startOpen: z.id == _added),
              OutlinedButton.icon(
                onPressed: _addZone,
                icon: const Icon(Icons.add),
                label: const Text('Add a zone'),
                style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
              ),
              const SizedBox(height: AppSpace.sm),
              Text('Compound, laundry, veranda, animals, or a name of your own.',
                  textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: AppSpace.lg),
              const AdSlot(screen: 'clean'),
            ],
          ),
        ),
      ),
    );
  }
}

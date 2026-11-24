// ─── House Help ───────────────────────────────────────────────────
// Premium in full: the guides and the vetting questionnaire behind one
// lock, visible but inert on the free plan (FR-HH-1, FR-HH-2).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:domease/ui/core/themes/tokens.dart';
import 'package:domease/ui/core/themes/typography.dart';
import 'package:domease/ui/core/ui/async_view.dart';
import 'package:domease/ui/core/ui/premium_lock.dart';
import 'package:domease/ui/core/ui/readable_width.dart';
import 'package:domease/ui/core/ui/section_label.dart';
import 'package:domease/ui/core/view_models/household_viewmodel.dart';
import 'package:domease/ui/house_help/view_models/house_help_viewmodel.dart';
import 'package:domease/ui/house_help/widgets/vetting_flow.dart';

class HouseHelpScreen extends ConsumerWidget {
  const HouseHelpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final guides = ref.watch(guidesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('House Help')),
      body: ReadableWidth(child: PremiumLock(
        locked: !ref.watch(isPremiumProvider),
        title: 'House Help comes with Premium',
        body: 'Compare candidates with a fair fit score, and four guides from hiring to review.',
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpace.screen, 0, AppSpace.screen, AppSpace.huge),
          children: [
            Text('Hire and keep good help', style: AppText.title.copyWith(color: scheme.onSurface)),
            const SizedBox(height: AppSpace.sm),
            Text('Eleven questions in four areas give each candidate a fit score, with anything worth a second conversation flagged.',
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: AppSpace.lg),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const VettingFlow())),
              icon: const Icon(Icons.fact_check_outlined),
              label: const Text('Vet a candidate'),
            ),
            const SectionLabel('Guides'),
            AsyncView(
              value: guides,
              data: (list) => Column(children: [
                for (final g in list)
                  Card(
                    margin: const EdgeInsets.only(bottom: AppSpace.sm),
                    child: ListTile(
                      leading: Icon(Icons.description_outlined, color: scheme.primary),
                      title: Text(g.title, style: AppText.bodyStrong.copyWith(color: scheme.onSurface)),
                      subtitle: Text('${g.summary}\n${g.pages} pages'),
                      isThreeLine: true,
                    ),
                  ),
              ]),
            ),
          ],
        ),
      )),
    );
  }
}

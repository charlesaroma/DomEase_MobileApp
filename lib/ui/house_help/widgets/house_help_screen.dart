// ─── House Help ───────────────────────────────────────────────────
// Premium in full: vet a candidate, keep a fair record of pay, and read the
// guides. Each tab sits behind the lock, visible but inert on the free plan
// (FR-HH-1, FR-HH-2).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:domease/ui/core/themes/tokens.dart';
import 'package:domease/ui/core/themes/typography.dart';
import 'package:domease/ui/core/ui/async_view.dart';
import 'package:domease/ui/core/ui/premium_lock.dart';
import 'package:domease/ui/core/ui/readable_width.dart';
import 'package:domease/ui/core/view_models/household_viewmodel.dart';
import 'package:domease/ui/house_help/view_models/house_help_viewmodel.dart';
import 'package:domease/ui/house_help/widgets/payroll_view.dart';
import 'package:domease/ui/house_help/widgets/vetting_flow.dart';

class HouseHelpScreen extends ConsumerWidget {
  const HouseHelpScreen({super.key, this.initialTab = 0});

  /// 0 Vet, 1 Pay, 2 Guides.
  final int initialTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locked = !ref.watch(isPremiumProvider);
    return DefaultTabController(
      length: 3,
      initialIndex: initialTab,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('House Help'),
          bottom: const TabBar(tabs: [Tab(text: 'Vet'), Tab(text: 'Pay'), Tab(text: 'Guides')]),
        ),
        body: ReadableWidth(
          child: TabBarView(children: [
            PremiumLock(
              locked: locked,
              title: 'House Help comes with Premium',
              body: 'Compare candidates with a fair fit score, and four guides from hiring to review.',
              child: const _Vet(),
            ),
            PremiumLock(
              locked: locked,
              title: 'House help pay comes with Premium',
              body: 'Salary, advances and days off in one record, with a payslip to send on WhatsApp.',
              child: const PayrollView(),
            ),
            PremiumLock(locked: locked, title: 'The guides come with Premium', child: const _Guides()),
          ]),
        ),
      ),
    );
  }
}

class _Vet extends StatelessWidget {
  const _Vet();

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.fromLTRB(AppSpace.screen, AppSpace.lg, AppSpace.screen, AppSpace.huge),
        children: [
          Text('Hire and keep good help', style: AppText.title.copyWith(color: Theme.of(context).colorScheme.onSurface)),
          const SizedBox(height: AppSpace.sm),
          Text('Eleven questions in four areas give each candidate a fit score, with anything worth a second conversation flagged.',
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppSpace.lg),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const VettingFlow())),
            icon: const Icon(Icons.fact_check_outlined),
            label: const Text('Vet a candidate'),
          ),
        ],
      );
}

class _Guides extends ConsumerWidget {
  const _Guides();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSpace.screen, AppSpace.lg, AppSpace.screen, AppSpace.huge),
      children: [
        AsyncView(
          value: ref.watch(guidesProvider),
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
    );
  }
}

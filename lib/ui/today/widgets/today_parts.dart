// ─── Today Parts ──────────────────────────────────────────────────
// The cards that make up Today, each small enough to rebuild alone.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:domease/domain/models/household.dart';
import 'package:domease/domain/models/recipe.dart';
import 'package:domease/domain/models/zone.dart';
import 'package:domease/routing/routes.dart';
import 'package:domease/ui/clean/view_models/clean_viewmodel.dart';
import 'package:domease/ui/core/themes/tokens.dart';
import 'package:domease/ui/core/themes/typography.dart';
import 'package:domease/ui/core/ui/premium_lock.dart';
import 'package:domease/ui/core/ui/status_pill.dart';
import 'package:domease/ui/core/view_models/content_viewmodel.dart';
import 'package:domease/ui/core/view_models/household_viewmodel.dart';
import 'package:domease/ui/house_help/view_models/payroll_viewmodel.dart';
import 'package:domease/utils/money.dart';

/// "Family · 4" (FR-TD-1); opens the household page.
class HouseholdChip extends StatelessWidget {
  const HouseholdChip({super.key, required this.household, required this.onTap});

  final Household household;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: dark ? AppColors.nightClayTint : AppColors.clay100,
      shape: const StadiumBorder(),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpace.md, vertical: 6),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.people_outline, size: 16, color: scheme.primary),
            const SizedBox(width: 6),
            Text('${household.size}', style: AppText.label.copyWith(color: scheme.primary, fontWeight: FontWeight.w600)),
          ]),
        ),
      ),
    );
  }
}

/// One rotating health nudge (FR-TD-3).
class NudgeBanner extends ConsumerWidget {
  const NudgeBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nudge = ref.watch(nudgeOfTheDayProvider).value;
    if (nudge == null) return const SizedBox.shrink();
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(top: AppSpace.lg),
      padding: const EdgeInsets.all(AppSpace.md),
      decoration: BoxDecoration(color: dark ? const Color(0xFF24352A) : AppColors.sage100, borderRadius: AppRadii.cardAll),
      child: Row(children: [
        Icon(Icons.spa_outlined, size: 20, color: dark ? AppColors.sage400 : AppColors.sage800),
        const SizedBox(width: AppSpace.md),
        Expanded(child: Text(nudge.text, style: AppText.label.copyWith(color: dark ? AppColors.sage200 : AppColors.sage800))),
      ]),
    );
  }
}

/// Tonight's dinner, with a clay edge (the Colour Direction's Today card).
class TonightCard extends StatelessWidget {
  const TonightCard({super.key, required this.recipe});

  final Recipe? recipe;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final r = recipe;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: r == null ? null : () => context.go(Routes.recipe(r.id)),
        child: Container(
          decoration: BoxDecoration(border: Border(left: BorderSide(color: AppColors.clay600, width: 3))),
          padding: const EdgeInsets.all(AppSpace.lg),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(Icons.ramen_dining_outlined, size: 14, color: scheme.primary),
              const SizedBox(width: 6),
              Text('TONIGHT', style: AppText.eyebrow.copyWith(color: scheme.primary)),
            ]),
            const SizedBox(height: AppSpace.sm),
            Text(r?.name ?? 'Nothing planned yet', style: AppText.heading.copyWith(color: scheme.onSurface)),
            if (r != null) ...[
              Text('${r.cuisine} · ${r.benefits.take(2).join(', ')}', style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: AppSpace.md),
              Row(children: [
                if (r.vegForward) const StatusPill(label: 'Veg forward', icon: Icons.eco_outlined, tone: PillTone.good),
                const Spacer(),
                Text('Recipe', style: AppText.label.copyWith(color: scheme.primary)),
                Icon(Icons.chevron_right, size: 18, color: scheme.primary),
              ]),
            ],
          ]),
        ),
      ),
    );
  }
}

/// Daily tasks still to do, tickable from here (FR-TD-4).
class DueToday extends ConsumerWidget {
  const DueToday({super.key, required this.items});

  final List<(Zone, ZoneTask)> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Card(
        child: Column(children: [
          for (final (zone, task) in items)
            CheckboxListTile(
              key: ValueKey(task.id),
              value: task.done,
              onChanged: (_) => ref.read(zonesProvider.notifier).toggleTask(zone.id, task.id),
              title: Text(task.label, style: AppText.body.copyWith(color: Theme.of(context).colorScheme.onSurface)),
              subtitle: Text(zone.assignee == null ? zone.name : '${zone.name} · ${zone.assignee}'),
              controlAffinity: ListTileControlAffinity.leading,
              dense: true,
            ),
        ]),
      );
}

/// The list in one line: total and how many are running low (FR-TD-4).
class ListSnapshot extends StatelessWidget {
  const ListSnapshot({super.key, required this.total, required this.low, required this.currency});

  final int total;
  final int low;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: ListTile(
        onTap: () => context.go(Routes.shop),
        leading: Icon(Icons.shopping_basket_outlined, color: scheme.onSurface),
        title: Text('Shopping list', style: AppText.bodyStrong.copyWith(color: scheme.onSurface)),
        subtitle: Text(currency == 'UGX' ? money(total) : 'About ${money(total)}', style: AppText.money.copyWith(fontSize: 13, color: scheme.onSurface)),
        trailing: low > 0 ? StatusPill(label: '$low low', icon: Icons.warning_amber_rounded, tone: PillTone.low) : null,
      ),
    );
  }
}

/// Quick ways into the converter and House Help (FR-TD-5).
class ToolsRow extends ConsumerWidget {
  const ToolsRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final premium = ref.watch(isPremiumProvider);
    return Row(children: [
      Expanded(child: _Tool(icon: Icons.currency_exchange, label: 'Convert', onTap: () => context.push(Routes.convert))),
      const SizedBox(width: AppSpace.md),
      Expanded(
        child: _Tool(icon: Icons.badge_outlined, label: 'House Help', locked: !premium, onTap: () => context.push(Routes.houseHelp)),
      ),
      const SizedBox(width: AppSpace.md),
      Expanded(child: _Tool(icon: Icons.insights_outlined, label: 'Insights', locked: !premium, onTap: () => context.push(Routes.insights))),
    ]);
  }
}

class _Tool extends StatelessWidget {
  const _Tool({required this.icon, required this.label, required this.onTap, this.locked = false});

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.lg),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Icon(icon, color: scheme.primary), const Spacer(), if (locked) const PremiumBadge(small: true)]),
            const SizedBox(height: AppSpace.md),
            Text(label, style: AppText.subheading.copyWith(color: scheme.onSurface)),
          ]),
        ),
      ),
    );
  }
}

/// A payday in the next three days with pay still owed (Premium, House Help pay).
class PaydayBanner extends ConsumerWidget {
  const PaydayBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final due = ref.watch(paydaysDueProvider);
    final currency = ref.watch(householdProvider).value?.currency ?? 'UGX';
    return Column(children: [
      for (final (s, days, owed) in due)
        Card(
          margin: const EdgeInsets.only(top: AppSpace.lg),
          color: AppColors.amber200,
          child: ListTile(
            onTap: () => context.push(Routes.housePay),
            leading: const Icon(Icons.event_outlined, color: AppColors.amber800),
            title: Text("${s.name}'s payday is ${days == 0 ? 'today' : days == 1 ? 'tomorrow' : 'in $days days'}",
                style: AppText.bodyStrong.copyWith(color: AppColors.amber800)),
            subtitle: Text('${money(owed, currency)} still to pay this month.', style: AppText.label.copyWith(color: AppColors.ink)),
            trailing: const Icon(Icons.chevron_right, color: AppColors.amber800),
          ),
        ),
    ]);
  }
}

/// What Premium adds, for the free plan only (FR-TD-7).
class PremiumUpsell extends ConsumerWidget {
  const PremiumUpsell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(isPremiumProvider)) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(top: AppSpace.lg),
      padding: const EdgeInsets.all(AppSpace.xl),
      decoration: BoxDecoration(color: AppColors.clay900, borderRadius: AppRadii.stageAll),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Run it your way', style: AppText.heading.copyWith(color: AppColors.white)),
        const SizedBox(height: AppSpace.sm),
        Text('A food budget, House Help pay and vetting, allergy profiles and no ads.', style: AppText.label.copyWith(color: AppColors.clay200)),
        const SizedBox(height: AppSpace.lg),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.amber, foregroundColor: AppColors.white, minimumSize: const Size(0, 44)),
          onPressed: () => context.push(Routes.premium),
          child: const Text('Learn more'),
        ),
      ]),
    );
  }
}

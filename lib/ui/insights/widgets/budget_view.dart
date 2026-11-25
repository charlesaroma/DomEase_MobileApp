// ─── Budget View ──────────────────────────────────────────────────
// The month against the food budget, six months of spending, the market
// against the list's estimate, and every trip saved from Done shopping.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:domease/domain/models/insights.dart';
import 'package:domease/domain/use_cases/insights.dart';
import 'package:domease/ui/core/themes/tokens.dart';
import 'package:domease/ui/core/themes/typography.dart';
import 'package:domease/ui/core/ui/async_view.dart';
import 'package:domease/ui/core/ui/section_label.dart';
import 'package:domease/ui/core/view_models/household_viewmodel.dart';
import 'package:domease/ui/insights/view_models/insights_viewmodel.dart';
import 'package:domease/utils/dates.dart';
import 'package:domease/utils/money.dart';

class BudgetView extends ConsumerWidget {
  const BudgetView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(householdProvider).value?.currency ?? 'UGX';
    String fmt(num v) => money(v, currency);
    return AsyncView(
      value: ref.watch(budgetProvider),
      onRetry: () => ref.invalidate(budgetProvider),
      data: (budget) {
        final m = budgetMonth(budget);
        return ListView(
          padding: const EdgeInsets.fromLTRB(AppSpace.screen, AppSpace.lg, AppSpace.screen, AppSpace.huge),
          children: [
            _MonthCard(m: m, fmt: fmt, onEdit: () => _editBudget(context, ref, budget, currency)),
            const SizedBox(height: AppSpace.md),
            Row(children: [
              Expanded(child: _Stat(label: 'Trips this month', value: '${m.trips}')),
              const SizedBox(width: AppSpace.md),
              Expanded(
                child: _Stat(
                  label: 'Market against the list',
                  value: m.vsEstimate == null ? 'No trips yet' : m.vsEstimate == 0 ? 'Right on it' : '${m.vsEstimate!.abs()}% ${m.vsEstimate! > 0 ? 'above' : 'under'}',
                ),
              ),
            ]),
            const SectionLabel('Six months of food shopping'),
            _MonthBars(months: m.byMonth, fmt: fmt),
            const SectionLabel('Trips'),
            if (budget.trips.isEmpty)
              Text('No trips yet. Tick things off on Shop, then tap Done shopping.', style: Theme.of(context).textTheme.bodySmall)
            else
              Card(
                child: Column(children: [
                  for (final t in budget.trips.take(12))
                    ListTile(
                      leading: Icon(Icons.shopping_basket_outlined, color: Theme.of(context).colorScheme.primary),
                      title: Text(shortDate(t.date)),
                      subtitle: Text('${t.items} items${t.estimate > 0 ? ' · estimate ${fmt(t.estimate)}' : ''}'),
                      trailing: Text(fmt(t.actual), style: AppText.money.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                      onLongPress: () => _removeTrip(context, ref, budget, t),
                    ),
                ]),
              ),
          ],
        );
      },
    );
  }

  Future<void> _removeTrip(BuildContext context, WidgetRef ref, Budget before, Trip t) async {
    await ref.read(budgetProvider.notifier).removeTrip(t.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Trip removed.'),
      action: SnackBarAction(label: 'Undo', onPressed: () => ref.read(budgetProvider.notifier).restore(before)),
    ));
  }

  Future<void> _editBudget(BuildContext context, WidgetRef ref, Budget budget, String currency) async {
    final controller = TextEditingController(text: budget.monthly?.toString() ?? '');
    final value = await showDialog<int?>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Monthly food budget'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: 'A month of food and household shopping ($currency)', helperText: 'A guide, not a limit.'),
        ),
        actions: [
          if (budget.monthly != null) TextButton(onPressed: () => Navigator.pop(c, -1), child: const Text('Remove')),
          FilledButton(onPressed: () => Navigator.pop(c, int.tryParse(controller.text.replaceAll(RegExp(r'\D'), ''))), child: const Text('Save')),
        ],
      ),
    );
    controller.dispose();
    if (value == null) return;
    await ref.read(budgetProvider.notifier).setMonthly(value <= 0 ? null : value);
  }
}

class _MonthCard extends StatelessWidget {
  const _MonthCard({required this.m, required this.fmt, required this.onEdit});

  final BudgetMonth m;
  final String Function(num) fmt;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final over = m.left != null && m.left! < 0;
    return Container(
      padding: const EdgeInsets.all(AppSpace.xl),
      decoration: BoxDecoration(color: over ? AppColors.danger : AppColors.sage800, borderRadius: AppRadii.stageAll),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text('Spent on food this month', style: AppText.label.copyWith(color: AppColors.white))),
          TextButton.icon(
            onPressed: onEdit,
            style: TextButton.styleFrom(foregroundColor: AppColors.white),
            icon: const Icon(Icons.edit_outlined, size: 16),
            label: Text(m.budget == null ? 'Set a budget' : 'Budget'),
          ),
        ]),
        Text(fmt(m.spent), style: AppText.title.copyWith(color: AppColors.white)),
        const SizedBox(height: AppSpace.md),
        if (m.budget != null) ...[
          ClipRRect(
            borderRadius: AppRadii.pillAll,
            child: LinearProgressIndicator(
              value: (m.percent ?? 0).clamp(0, 100) / 100,
              minHeight: 8,
              color: AppColors.white,
              backgroundColor: AppColors.white.withValues(alpha: 0.25),
            ),
          ),
          const SizedBox(height: AppSpace.md),
        ],
        Text(
          m.budget == null
              ? 'Set a monthly budget to see what is left as the month goes.'
              : over
                  ? '${fmt(-m.left!)} over a budget of ${fmt(m.budget!)}.'
                  : '${fmt(m.left!)} left of ${fmt(m.budget!)}, about ${fmt(m.perDay)} a day to the end of the month.',
          style: AppText.label.copyWith(color: AppColors.white),
        ),
      ]),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.lg),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: AppSpace.xs),
            Text(value, style: AppText.subheading.copyWith(color: Theme.of(context).colorScheme.onSurface)),
          ]),
        ),
      );
}

/// Six thin bars, the amount read out with each month for screen readers.
class _MonthBars extends StatelessWidget {
  const _MonthBars({required this.months, required this.fmt});

  final List<(String, int)> months;
  final String Function(num) fmt;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final top = months.fold(1, (n, m) => m.$2 > n ? m.$2 : n);
    return SizedBox(
      height: 150,
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        for (final (label, value) in months)
          Expanded(
            child: Semantics(
              label: '$label, ${fmt(value)}',
              excludeSemantics: true,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Container(
                    height: 110 * value / top,
                    decoration: BoxDecoration(color: scheme.primary, borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
                  ),
                  const SizedBox(height: AppSpace.xs),
                  Text(label, style: AppText.caption),
                ]),
              ),
            ),
          ),
      ]),
    );
  }
}

// ─── Payroll View ─────────────────────────────────────────────────
// A fair record of pay for whoever helps at home: what is still owed this
// month, the next payday, and every payment, advance and day off.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:domease/domain/models/household.dart';
import 'package:domease/domain/models/insights.dart';
import 'package:domease/domain/use_cases/insights.dart';
import 'package:domease/ui/core/themes/tokens.dart';
import 'package:domease/ui/core/themes/typography.dart';
import 'package:domease/ui/core/ui/async_view.dart';
import 'package:domease/ui/core/view_models/household_viewmodel.dart';
import 'package:domease/ui/house_help/view_models/payroll_viewmodel.dart';
import 'package:domease/ui/house_help/widgets/payroll_sheets.dart';
import 'package:domease/utils/dates.dart';
import 'package:domease/utils/money.dart';

class PayrollView extends ConsumerWidget {
  const PayrollView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final home = ref.watch(householdProvider).value;
    String fmt(num v) => money(v, home?.currency ?? 'UGX');
    return AsyncView(
      value: ref.watch(staffProvider),
      onRetry: () => ref.invalidate(staffProvider),
      data: (staff) {
        final helpers = [
          for (final m in home?.members ?? const <HouseholdMember>[])
            if (m.role == MemberRole.houseHelp && !staff.any((p) => p.name == m.name)) m.name,
        ];
        return ListView(
          padding: const EdgeInsets.fromLTRB(AppSpace.screen, AppSpace.lg, AppSpace.screen, AppSpace.huge),
          children: [
            if (staff.isEmpty) ...[
              Text('Keep a fair record of pay', style: AppText.title.copyWith(color: Theme.of(context).colorScheme.onSurface)),
              const SizedBox(height: AppSpace.sm),
              Text('Salary, advances and days off in one place, with a payslip to send on WhatsApp. No more guessing what was paid.',
                  style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: AppSpace.lg),
            ],
            for (final p in staff) _Person(person: p, fmt: fmt, home: home?.name ?? ''),
            OutlinedButton.icon(
              onPressed: () => showStaffSheet(context, suggestions: helpers, currency: home?.currency ?? 'UGX'),
              icon: const Icon(Icons.add),
              label: const Text('Add someone'),
            ),
          ],
        );
      },
    );
  }
}

class _Person extends ConsumerWidget {
  const _Person({required this.person, required this.fmt, required this.home});

  final Staff person;
  final String Function(num) fmt;
  final String home;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final m = payMonth(person);
    final payday = nextPayday(person);
    final now = DateTime.now();
    final inDays = payday.difference(DateTime(now.year, now.month, now.day)).inDays;
    final currency = ref.watch(householdProvider).value?.currency ?? 'UGX';

    Future<void> removeEntry(PayEntry e) async {
      final before = ref.read(staffProvider).value ?? const <Staff>[];
      await ref.read(staffProvider.notifier).removeEntry(person.id, e.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Entry removed.'),
        action: SnackBarAction(label: 'Undo', onPressed: () => ref.read(staffProvider.notifier).restore(before)),
      ));
    }

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpace.lg),
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.lg),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(person.name, style: AppText.heading.copyWith(color: scheme.onSurface)),
                Text('${person.role} · ${fmt(person.salary)} a month', style: Theme.of(context).textTheme.bodySmall),
              ]),
            ),
            IconButton(
              tooltip: 'Edit ${person.name}',
              onPressed: () => showStaffSheet(context, person: person, suggestions: const [], currency: currency),
              icon: const Icon(Icons.edit_outlined),
            ),
          ]),
          const SizedBox(height: AppSpace.lg),
          Text(m.owed >= 0 ? 'Still to pay for ${monthName(m.month)}' : 'Paid ahead this month', style: Theme.of(context).textTheme.bodySmall),
          Text(fmt(m.owed.abs()), style: AppText.title.copyWith(color: m.owed <= 0 ? AppColors.sage800 : scheme.onSurface)),
          Text(inDays == 0 ? 'Payday is today' : inDays == 1 ? 'Payday is tomorrow' : 'Payday ${shortDate(payday)}, in $inDays days',
              style: Theme.of(context).textTheme.bodySmall),
          const Divider(height: AppSpace.xxl),
          _Row('Salary', fmt(m.salary)),
          if (m.bonus > 0) _Row('Bonus', '+ ${fmt(m.bonus)}'),
          if (m.advances > 0) _Row('Advances', '- ${fmt(m.advances)}'),
          if (m.deductions > 0) _Row('Deductions', '- ${fmt(m.deductions)}'),
          _Row('Paid', m.paid > 0 ? '- ${fmt(m.paid)}' : 'Nothing yet'),
          _Row('Days off this year', '${daysOffThisYear(person)}'),
          const SizedBox(height: AppSpace.md),
          Wrap(spacing: AppSpace.sm, runSpacing: AppSpace.sm, children: [
            FilledButton.icon(
              onPressed: () => showEntrySheet(context, person: person, currency: currency),
              icon: const Icon(Icons.add),
              label: const Text('Record'),
            ),
            OutlinedButton.icon(
              onPressed: () => showPayslipSheet(context, person: person, home: home, fmt: fmt),
              icon: const Icon(Icons.receipt_long_outlined),
              label: const Text('Payslip'),
            ),
          ]),
          if (m.entries.isNotEmpty) ...[
            const SizedBox(height: AppSpace.md),
            for (final e in m.entries)
              ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: Text(e.kind.label),
                subtitle: Text([shortDate(e.date), if (e.note.isNotEmpty) e.note].join(' · ')),
                trailing: Text(e.kind == PayKind.leave ? '${e.days} ${e.days == 1 ? 'day' : 'days'}' : fmt(e.amount), style: AppText.money.copyWith(fontSize: 13, color: scheme.onSurface)),
                onLongPress: () => removeEntry(e),
              ),
          ],
        ]),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpace.xs),
        child: Row(children: [
          Expanded(child: Text(label, style: AppText.label)),
          Text(value, style: AppText.money.copyWith(fontSize: 14, color: Theme.of(context).colorScheme.onSurface)),
        ]),
      );
}

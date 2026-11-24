// ─── Convert ──────────────────────────────────────────────────────
// Amount, From and To across the 12 currencies, with a swap and a live
// result; the rate table's date is always shown (FR-CC-1 to FR-CC-3).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:domease/domain/models/currency.dart';
import 'package:domease/domain/use_cases/convert_currency.dart';
import 'package:domease/ui/convert/view_models/convert_viewmodel.dart';
import 'package:domease/ui/core/themes/tokens.dart';
import 'package:domease/ui/core/themes/typography.dart';
import 'package:domease/ui/core/ui/async_view.dart';
import 'package:domease/ui/core/ui/readable_width.dart';
import 'package:domease/ui/core/view_models/content_viewmodel.dart';
import 'package:domease/utils/dates.dart';
import 'package:domease/utils/money.dart';

class ConvertScreen extends ConsumerWidget {
  const ConvertScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rates = ref.watch(ratesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Convert')),
      body: ReadableWidth(child: AsyncView(value: rates, onRetry: () => ref.invalidate(ratesProvider), data: (table) => _Converter(table: table))),
    );
  }
}

class _Converter extends ConsumerWidget {
  const _Converter({required this.table});

  final RateTable table;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final s = ref.watch(convertProvider);
    final c = ref.read(convertProvider.notifier);
    final from = table.byCode(s.from) ?? table.rates.first;
    final to = table.byCode(s.to) ?? table.rates.first;
    final result = convert(s.amount, from, to);

    Widget picker(String value, ValueChanged<String> onChanged, String label) => InputDecorator(
          decoration: InputDecoration(labelText: label),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              isDense: true,
              items: [for (final r in table.rates) DropdownMenuItem(value: r.code, child: Text('${r.code}  ${r.name}'))],
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
            ),
          ),
        );

    return ListView(
      padding: const EdgeInsets.all(AppSpace.screen),
      children: [
        TextFormField(
          initialValue: s.amount.toStringAsFixed(0),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: AppText.title.copyWith(color: scheme.onSurface),
          decoration: const InputDecoration(labelText: 'Amount'),
          onChanged: (v) => c.setAmount(double.tryParse(v.replaceAll(',', '')) ?? 0),
        ),
        const SizedBox(height: AppSpace.lg),
        picker(s.from, c.setFrom, 'From'),
        Center(child: IconButton.filledTonal(onPressed: c.swap, icon: const Icon(Icons.swap_vert), tooltip: 'Swap')),
        picker(s.to, c.setTo, 'To'),
        const SizedBox(height: AppSpace.xxl),
        Container(
          padding: const EdgeInsets.all(AppSpace.xl),
          decoration: BoxDecoration(color: scheme.surfaceContainerHighest, borderRadius: AppRadii.stageAll),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${money(s.amount, from.code)} is', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: AppSpace.xs),
            Text(money(result, to.code), style: AppText.display.copyWith(color: scheme.primary, fontSize: 34)),
          ]),
        ),
        const SizedBox(height: AppSpace.md),
        Text('Rates last updated ${shortDate(table.updatedAt)}. A guide, not a bank rate.', style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

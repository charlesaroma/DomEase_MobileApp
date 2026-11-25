// ─── Done Shopping Sheet ──────────────────────────────────────────
// The end of a market trip: what it really cost, saved as a trip, then the
// ticks cleared for next time. Every home keeps the record; Premium shows it
// against a monthly budget (Insights).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:domease/domain/models/shopping.dart';
import 'package:domease/ui/core/themes/tokens.dart';
import 'package:domease/ui/core/themes/typography.dart';
import 'package:domease/ui/core/view_models/household_viewmodel.dart';
import 'package:domease/ui/insights/view_models/insights_viewmodel.dart';
import 'package:domease/ui/shop/view_models/shop_viewmodel.dart';
import 'package:domease/utils/money.dart';

Future<void> showDoneShoppingSheet(BuildContext context, List<ShoppingItem> items) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.stage))),
      builder: (_) => _DoneShopping(items: items),
    );

class _DoneShopping extends ConsumerStatefulWidget {
  const _DoneShopping({required this.items});

  final List<ShoppingItem> items;

  @override
  ConsumerState<_DoneShopping> createState() => _DoneShoppingState();
}

class _DoneShoppingState extends ConsumerState<_DoneShopping> {
  late final List<ShoppingItem> _bought = widget.items.where((i) => i.checked).toList();
  late final int _estimate = _bought.fold(0, (n, i) => n + (i.price ?? 0));
  late final _paid = TextEditingController(text: _estimate > 0 ? '$_estimate' : '');

  @override
  void dispose() {
    _paid.dispose();
    super.dispose();
  }

  int get _amount => int.tryParse(_paid.text.replaceAll(RegExp(r'\D'), '')) ?? 0;

  Future<void> _finish({required bool record}) async {
    final amount = _amount;
    if (record && amount <= 0) return;
    final shop = ref.read(shopStateProvider.notifier);
    final checked = _bought.map((i) => i.id).toSet();
    if (record) await ref.read(budgetProvider.notifier).addTrip(estimate: _estimate, actual: amount, items: _bought.length);
    // Ticked items come off; anything added by hand and bought goes too.
    for (final id in checked.where((id) => id.startsWith('manual_'))) {
      await shop.remove(id);
    }
    await shop.clearTicks();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final premium = ref.watch(isPremiumProvider);
    return Padding(
      padding: EdgeInsets.fromLTRB(AppSpace.screen, AppSpace.xl, AppSpace.screen, MediaQuery.viewInsetsOf(context).bottom + AppSpace.xl),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        Text('Done shopping', style: AppText.title.copyWith(color: scheme.onSurface)),
        const SizedBox(height: AppSpace.sm),
        Text('${_bought.length} ${_bought.length == 1 ? 'item' : 'items'} bought, estimated at ${money(_estimate)}.', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: AppSpace.lg),
        TextField(
          controller: _paid,
          autofocus: true,
          keyboardType: TextInputType.number,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(labelText: 'What did it cost?', helperText: 'Include anything bought that wasn\'t on the list.'),
        ),
        if (!premium) ...[
          const SizedBox(height: AppSpace.lg),
          Text('Premium keeps every trip against a monthly food budget, so you see where the money goes.', style: AppText.label),
        ],
        const SizedBox(height: AppSpace.xl),
        Row(children: [
          Expanded(child: OutlinedButton(onPressed: () => _finish(record: false), child: const Text('Just clear ticks'))),
          const SizedBox(width: AppSpace.md),
          Expanded(child: FilledButton(onPressed: _amount > 0 ? () => _finish(record: true) : null, child: const Text('Save the trip'))),
        ]),
      ]),
    );
  }
}

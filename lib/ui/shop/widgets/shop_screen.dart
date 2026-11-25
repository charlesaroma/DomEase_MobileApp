// ─── Shop ─────────────────────────────────────────────────────────
// One list the whole house shares: written from the week's meals and the
// zones' low consumables, grouped as you walk the market, priced in
// Shillings (FR-SL-1 to FR-SL-3).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:domease/domain/models/shopping.dart';
import 'package:domease/domain/use_cases/build_shopping_list.dart';
import 'package:domease/ui/core/themes/tokens.dart';
import 'package:domease/ui/core/themes/typography.dart';
import 'package:domease/ui/core/ui/ad_slot.dart';
import 'package:domease/ui/core/ui/async_view.dart';
import 'package:domease/ui/core/ui/readable_width.dart';
import 'package:domease/ui/core/ui/section_label.dart';
import 'package:domease/ui/core/ui/status_pill.dart';
import 'package:domease/ui/shop/view_models/shop_viewmodel.dart';
import 'package:domease/ui/shop/widgets/add_item_sheet.dart';
import 'package:domease/ui/shop/widgets/done_shopping_sheet.dart';
import 'package:domease/utils/money.dart';

class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final list = ref.watch(shoppingListProvider);
    return Scaffold(
      appBar: AppBar(
        titleSpacing: AppSpace.screen,
        title: Text('Shop', style: AppText.title.copyWith(color: scheme.onSurface)),
        actions: [
          TextButton(
            onPressed: list.value?.any((i) => i.checked) ?? false ? () => showDoneShoppingSheet(context, list.value!) : null,
            child: const Text('Done shopping'),
          ),
          const SizedBox(width: AppSpace.sm),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showAddItemSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Add item'),
      ),
      body: ReadableWidth(child: AsyncView(
        value: list,
        onRetry: () => ref.invalidate(shoppingListProvider),
        data: (items) {
          final groups = <String, List<ShoppingItem>>{};
          for (final i in items) {
            groups.putIfAbsent(i.category, () => []).add(i);
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(AppSpace.screen, 0, AppSpace.screen, 120),
            children: [
              Text('One list, everyone sees it', style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: AppSpace.lg),
              _Total(items: items),
              const AdSlot(screen: 'shop', native: true),
              for (final e in groups.entries) ...[
                SectionLabel(e.key, trailing: Text('${e.value.length}', style: AppText.money.copyWith(fontSize: 13))),
                Card(child: Column(children: [for (final i in e.value) _ItemRow(key: ValueKey(i.id), item: i)])),
              ],
            ],
          );
        },
      )),
    );
  }
}

class _Total extends StatelessWidget {
  const _Total({required this.items});

  final List<ShoppingItem> items;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final low = items.where((i) => i.low && !i.checked).length;
    final left = items.where((i) => !i.checked).length;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.lg),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Still to buy, estimated', style: Theme.of(context).textTheme.bodySmall),
              Text(money(estimateTotal(items)), style: AppText.title.copyWith(color: scheme.onSurface)),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            if (low > 0) StatusPill(label: '$low low', icon: Icons.warning_amber_rounded, tone: PillTone.low),
            const SizedBox(height: AppSpace.xs),
            Text('$left of ${items.length} items', style: AppText.money.copyWith(fontSize: 12, color: scheme.outline)),
          ]),
        ]),
      ),
    );
  }
}

class _ItemRow extends ConsumerWidget {
  const _ItemRow({super.key, required this.item});

  final ShoppingItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final source = switch (item.source) {
      ItemSource.meal => 'For this week\'s meals',
      ItemSource.zone => 'Running low at home',
      ItemSource.manual => 'Added by hand',
    };
    final row = CheckboxListTile(
      value: item.checked,
      onChanged: (_) => ref.read(shopStateProvider.notifier).toggle(item.id),
      controlAffinity: ListTileControlAffinity.leading,
      title: Row(children: [
        Expanded(
          child: Text(
            item.quantity == null ? item.name : '${item.name}, ${item.quantity}',
            style: AppText.body.copyWith(
              color: item.checked ? scheme.outline : scheme.onSurface,
              decoration: item.checked ? TextDecoration.lineThrough : null,
            ),
          ),
        ),
        if (item.low && !item.checked) const StatusPill(label: 'Low', icon: Icons.warning_amber_rounded, tone: PillTone.low),
      ]),
      subtitle: Text(source),
      secondary: item.price == null ? null : Text(money(item.price!), style: AppText.money.copyWith(fontSize: 13, color: scheme.onSurface)),
    );
    if (item.source != ItemSource.manual) return row;
    return Dismissible(
      key: ValueKey('dismiss_${item.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        color: AppColors.danger,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpace.xl),
        child: const Icon(Icons.delete_outline, color: AppColors.white),
      ),
      onDismissed: (_) => ref.read(shopStateProvider.notifier).remove(item.id),
      child: row,
    );
  }
}

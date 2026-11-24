// ─── Add Item Sheet ───────────────────────────────────────────────
// Manual add for anything the plan did not think of (FR-SL-2).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:domease/ui/core/themes/tokens.dart';
import 'package:domease/ui/core/themes/typography.dart';
import 'package:domease/ui/shop/view_models/shop_viewmodel.dart';

Future<void> showAddItemSheet(BuildContext context) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.stage))),
      builder: (_) => const _AddItemForm(),
    );

class _AddItemForm extends ConsumerStatefulWidget {
  const _AddItemForm();

  @override
  ConsumerState<_AddItemForm> createState() => _AddItemFormState();
}

class _AddItemFormState extends ConsumerState<_AddItemForm> {
  final _name = TextEditingController();
  final _qty = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _qty.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    final qty = _qty.text.trim();
    await ref.read(shopStateProvider.notifier).add(name, quantity: qty.isEmpty ? null : qty);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.fromLTRB(AppSpace.screen, AppSpace.xl, AppSpace.screen, MediaQuery.viewInsetsOf(context).bottom + AppSpace.xl),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text('Add to the list', style: AppText.title.copyWith(color: Theme.of(context).colorScheme.onSurface)),
          const SizedBox(height: AppSpace.lg),
          TextField(controller: _name, autofocus: true, decoration: const InputDecoration(labelText: 'What do you need?')),
          const SizedBox(height: AppSpace.md),
          TextField(controller: _qty, onSubmitted: (_) => _add(), decoration: const InputDecoration(labelText: 'How much', hintText: '2 kg')),
          const SizedBox(height: AppSpace.xl),
          SizedBox(width: double.infinity, child: FilledButton(onPressed: _add, child: const Text('Add'))),
        ]),
      );
}

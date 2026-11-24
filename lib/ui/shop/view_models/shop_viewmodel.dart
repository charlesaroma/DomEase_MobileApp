// ─── Shop View Models ─────────────────────────────────────────────
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:domease/config/dependencies.dart';
import 'package:domease/domain/models/shopping.dart';
import 'package:domease/domain/use_cases/build_shopping_list.dart';
import 'package:domease/ui/clean/view_models/clean_viewmodel.dart';
import 'package:domease/ui/core/view_models/content_viewmodel.dart';
import 'package:domease/ui/meals/view_models/meals_viewmodel.dart';

final shopStateProvider = AsyncNotifierProvider<ShopStateNotifier, ShopState>(ShopStateNotifier.new);

class ShopStateNotifier extends AsyncNotifier<ShopState> {
  @override
  Future<ShopState> build() => ref.watch(shoppingRepositoryProvider).state();

  Future<void> _set(ShopState next) async {
    state = AsyncData(next);
    await ref.read(shoppingRepositoryProvider).saveState(next);
  }

  Future<void> toggle(String id) async {
    final s = state.value ?? const ShopState();
    await _set(s.copyWith(checked: s.checked.contains(id) ? ({...s.checked}..remove(id)) : {...s.checked, id}));
  }

  /// Manual add (FR-SL-2).
  Future<void> add(String name, {String? quantity}) async {
    final s = state.value ?? const ShopState();
    final item = ShoppingItem(
      id: 'manual_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      category: 'Added by hand',
      source: ItemSource.manual,
      quantity: quantity,
    );
    await _set(s.copyWith(manual: [...s.manual, item]));
  }

  Future<void> remove(String id) async {
    final s = state.value ?? const ShopState();
    await _set(s.copyWith(manual: [for (final m in s.manual) if (m.id != id) m]));
  }

  /// Untick everything for a new shopping trip.
  Future<void> clearTicks() async => _set((state.value ?? const ShopState()).copyWith(checked: {}));
}

/// The combined list: meals, low consumables and hand-added items, merged (FR-SL-1).
final shoppingListProvider = FutureProvider<List<ShoppingItem>>((ref) async {
  final plan = await ref.watch(mealPlanProvider.future);
  final recipes = await ref.watch(recipesProvider.future);
  final zones = await ref.watch(zonesProvider.future);
  final prices = await ref.watch(pricesProvider.future);
  final state = await ref.watch(shopStateProvider.future);
  return buildShoppingList(plan: plan, recipes: recipes, zones: zones, prices: prices, state: state);
});

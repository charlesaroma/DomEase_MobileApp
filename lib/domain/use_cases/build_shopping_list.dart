// ─── Build Shopping List ──────────────────────────────────────────
// One list from the week's meals and the zones' low consumables, plus what
// the household added by hand (FR-SL-1, FR-HM-4). Each ingredient appears
// once, priced from the market table. Things with no market price, like
// water, never go on the list.
import 'package:domease/domain/models/meal_plan.dart';
import 'package:domease/domain/models/recipe.dart';
import 'package:domease/domain/models/shopping.dart';
import 'package:domease/domain/models/zone.dart';

List<ShoppingItem> buildShoppingList({
  required MealPlan plan,
  required List<Recipe> recipes,
  required List<Zone> zones,
  required List<MarketPrice> prices,
  required ShopState state,
}) {
  final priceOf = {for (final p in prices) p.name.toLowerCase(): p};
  final byId = {for (final r in recipes) r.id: r};
  final items = <String, ShoppingItem>{};

  void add(String name, ItemSource source, {bool low = false}) {
    final p = priceOf[name.toLowerCase()];
    if (p == null) return;
    final id = 'item_${name.toLowerCase().replaceAll(RegExp('[^a-z0-9]+'), '_')}';
    final existing = items[id];
    items[id] = ShoppingItem(
      id: id,
      name: p.name,
      category: p.category,
      source: existing?.source ?? source,
      quantity: p.pack,
      price: p.price,
      low: low || (existing?.low ?? false),
      checked: state.checked.contains(id),
    );
  }

  for (final ids in plan.days.values) {
    for (final id in ids) {
      for (final i in byId[id]?.ingredients ?? const <Ingredient>[]) {
        add(i.name, ItemSource.meal);
      }
    }
  }
  for (final z in zones) {
    for (final c in z.consumables.where((c) => c.low)) {
      add(c.name, ItemSource.zone, low: true);
    }
  }
  final manual = [for (final m in state.manual) m.copyWith(checked: state.checked.contains(m.id))];
  final list = [...items.values, ...manual]..sort((a, b) => a.category.compareTo(b.category));
  return list;
}

/// The estimated cost of what is still to buy.
int estimateTotal(List<ShoppingItem> items) => items.where((i) => !i.checked).fold(0, (n, i) => n + (i.price ?? 0));

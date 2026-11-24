// ─── Today View Model ─────────────────────────────────────────────
// What the household opens on: tonight's dinner, the zones due today, and
// the list (FR-TD-4). Worked out here so the screen only draws.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:domease/domain/models/recipe.dart';
import 'package:domease/domain/models/zone.dart';
import 'package:domease/domain/use_cases/build_shopping_list.dart';
import 'package:domease/ui/clean/view_models/clean_viewmodel.dart';
import 'package:domease/ui/meals/view_models/meals_viewmodel.dart';
import 'package:domease/ui/shop/view_models/shop_viewmodel.dart';

class TodaySummary {
  const TodaySummary({
    required this.tonight,
    required this.mealsPlanned,
    required this.mealsTotal,
    required this.zonesClear,
    required this.zones,
    required this.dueToday,
    required this.itemsBought,
    required this.itemsTotal,
    required this.lowCount,
    required this.listTotal,
  });

  final Recipe? tonight;
  final int mealsPlanned;
  final int mealsTotal;
  final int zonesClear;
  final int zones;

  /// Daily tasks still to do, with the zone they belong to.
  final List<(Zone, ZoneTask)> dueToday;
  final int itemsBought;
  final int itemsTotal;
  final int lowCount;
  final int listTotal;
}

final todayProvider = FutureProvider<TodaySummary>((ref) async {
  final plan = await ref.watch(mealPlanProvider.future);
  final zones = await ref.watch(zonesProvider.future);
  final list = await ref.watch(shoppingListProvider.future);
  final weekday = DateTime.now().weekday;
  final tonightId = plan.on(MealType.dinner, weekday);
  final tonight = tonightId == null ? null : await ref.watch(recipeProvider(tonightId).future);
  return TodaySummary(
    tonight: tonight,
    mealsPlanned: plan.count,
    mealsTotal: MealType.values.length * 7,
    zonesClear: zones.where((z) => z.clear).length,
    zones: zones.length,
    dueToday: [
      for (final z in zones)
        for (final t in z.tasks)
          if (t.frequency == Frequency.daily && !t.done) (z, t),
    ],
    itemsBought: list.where((i) => i.checked).length,
    itemsTotal: list.length,
    lowCount: list.where((i) => i.low && !i.checked).length,
    listTotal: estimateTotal(list),
  );
});

// ─── Plan Week ────────────────────────────────────────────────────
// Seven days of one meal type from the recipe pool (FR-MP-1, FR-MP-6).
// Premium allergy profiles filter out anything with a matching ingredient
// (FR-MP-11). Recipes marked Premium in the admin go to Premium homes only. The same seed gives the same week, so a plan is stable until
// the household asks to swap it.
import 'dart:math';

import 'package:domease/domain/models/recipe.dart';

List<String> planWeek(List<Recipe> pool, MealType type, {required int seed, Set<String> allergies = const {}, bool premium = false}) {
  final options = [
    for (final r in pool)
      if (r.mealType == type && r.occasions.isEmpty && (premium || !r.isPremium) && !r.contains(allergies)) r.id,
  ]..shuffle(Random(seed));
  if (options.isEmpty) return const [];
  // Spread the pool across the week before repeating anything.
  return [for (var day = 0; day < 7; day++) options[day % options.length]];
}

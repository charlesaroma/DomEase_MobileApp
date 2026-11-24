// ─── Meals View Models ────────────────────────────────────────────
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:domease/config/dependencies.dart';
import 'package:domease/domain/models/meal_plan.dart';
import 'package:domease/domain/models/recipe.dart';
import 'package:domease/domain/use_cases/plan_week.dart';
import 'package:domease/ui/core/view_models/household_viewmodel.dart';
import 'package:domease/utils/dates.dart';

final recipesProvider = FutureProvider<List<Recipe>>((ref) => ref.watch(mealRepositoryProvider).recipes());

final recipeProvider = FutureProvider.family<Recipe?, String>((ref, id) async {
  for (final r in await ref.watch(recipesProvider.future)) {
    if (r.id == id) return r;
  }
  return null;
});

/// The week: loaded if saved, otherwise planned from the library and saved.
final mealPlanProvider = AsyncNotifierProvider<MealPlanNotifier, MealPlan>(MealPlanNotifier.new);

class MealPlanNotifier extends AsyncNotifier<MealPlan> {
  @override
  Future<MealPlan> build() async {
    final saved = await ref.watch(mealRepositoryProvider).plan();
    if (saved != null && saved.count > 0) return saved;
    final plan = await _fresh(weekStart(DateTime.now()).millisecondsSinceEpoch ~/ 86400000);
    await ref.read(mealRepositoryProvider).savePlan(plan);
    return plan;
  }

  Future<MealPlan> _fresh(int seed) async {
    final pool = await ref.read(recipesProvider.future);
    final household = ref.read(householdProvider).value;
    final allergies = household != null && household.isPremium ? household.allergies : <String>{};
    return MealPlan({for (final t in MealType.values) t: planWeek(pool, t, seed: seed + t.index, allergies: allergies, premium: household?.isPremium ?? false)});
  }

  /// "Swap this week's plan" for one meal type (FR-MP-6).
  Future<void> swap(MealType type) async {
    final current = state.value;
    if (current == null) return;
    final pool = await ref.read(recipesProvider.future);
    final household = ref.read(householdProvider).value;
    final allergies = household != null && household.isPremium ? household.allergies : <String>{};
    final next = current.withType(type, planWeek(pool, type, seed: DateTime.now().millisecondsSinceEpoch, allergies: allergies, premium: household?.isPremium ?? false));
    state = AsyncData(next);
    await ref.read(mealRepositoryProvider).savePlan(next);
  }
}

/// The meal type shown on the Meals screen.
final selectedMealTypeProvider = NotifierProvider<SelectedMealType, MealType>(SelectedMealType.new);

class SelectedMealType extends Notifier<MealType> {
  @override
  MealType build() => MealType.dinner;

  void select(MealType type) => state = type;
}

/// Premium favourites, kept for the session (FR-MP-10).
final favouritesProvider = NotifierProvider<Favourites, Set<String>>(Favourites.new);

class Favourites extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};

  void toggle(String id) => state = state.contains(id) ? ({...state}..remove(id)) : {...state, id};
}

/// Send a dish idea for review (FR-MP-13).
Future<void> suggestRecipe(WidgetRef ref, RecipeSuggestion suggestion) => ref.read(mealRepositoryProvider).suggest(suggestion);

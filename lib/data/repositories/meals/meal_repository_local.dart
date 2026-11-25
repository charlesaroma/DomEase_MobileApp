// ─── Meal Repository (demo) ───────────────────────────────────────
import 'package:domease/data/model/json.dart';
import 'package:domease/data/model/recipe_json.dart';
import 'package:domease/data/repositories/meals/meal_repository.dart';
import 'package:domease/data/services/demo_assets.dart';
import 'package:domease/data/services/prefs_store.dart';
import 'package:domease/domain/models/meal_plan.dart';
import 'package:domease/domain/models/recipe.dart';
import 'package:domease/domain/use_cases/plan_week.dart';

/// assets/demo/recipes.json; the plan and suggestions stay on the phone.
class MealRepositoryLocal implements MealRepository {
  MealRepositoryLocal(this._store);

  final PrefsStore _store;
  List<Recipe>? _recipes;

  @override
  Future<List<Recipe>> recipes() async => _recipes ??= [for (final j in await loadDemoList('recipes')) recipeFromJson(j)];

  @override
  Future<MealPlan?> plan() async {
    final json = await _store.read('meal_plan');
    return json == null ? null : mealPlanFromJson(json as Json);
  }

  @override
  Future<void> savePlan(MealPlan plan) => _store.write('meal_plan', mealPlanToJson(plan));

  /// Saved weeks, or four made up ones so the demo has trends to show.
  @override
  Future<List<MealPlan>> history() async {
    final json = await _store.read('meal_plan_history');
    if (json != null) return [for (final j in json as List) mealPlanFromJson(j as Json)];
    final pool = await recipes();
    return [
      for (final w in [4, 3, 2, 1]) MealPlan({for (final t in MealType.values) t: planWeek(pool, t, seed: 1000 + w + t.index)}),
    ];
  }

  @override
  Future<void> suggest(RecipeSuggestion suggestion) async {
    final sent = (await _store.read('suggestions') as List?) ?? [];
    await _store.write('suggestions', [...sent, suggestionToJson(suggestion)]);
  }
}

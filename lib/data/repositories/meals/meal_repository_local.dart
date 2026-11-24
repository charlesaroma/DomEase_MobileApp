// ─── Meal Repository (demo) ───────────────────────────────────────
import 'package:domease/data/model/json.dart';
import 'package:domease/data/model/recipe_json.dart';
import 'package:domease/data/repositories/meals/meal_repository.dart';
import 'package:domease/data/services/demo_assets.dart';
import 'package:domease/data/services/prefs_store.dart';
import 'package:domease/domain/models/meal_plan.dart';
import 'package:domease/domain/models/recipe.dart';

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

  @override
  Future<void> suggest(RecipeSuggestion suggestion) async {
    final sent = (await _store.read('suggestions') as List?) ?? [];
    await _store.write('suggestions', [...sent, suggestionToJson(suggestion)]);
  }
}

// ─── Meal Repository (API) ────────────────────────────────────────
import 'package:domease/data/model/json.dart';
import 'package:domease/data/model/recipe_json.dart';
import 'package:domease/data/repositories/meals/meal_repository.dart';
import 'package:domease/data/services/api/api_client.dart';
import 'package:domease/domain/models/failure.dart';
import 'package:domease/domain/models/meal_plan.dart';
import 'package:domease/domain/models/recipe.dart';

class MealRepositoryRemote implements MealRepository {
  MealRepositoryRemote(this._api);

  final ApiClient _api;

  @override
  Future<List<Recipe>> recipes() async => [for (final j in await _api.get('/recipes') as List) recipeFromJson(j as Json)];

  @override
  Future<MealPlan?> plan() async {
    try {
      return mealPlanFromJson(await _api.get('/households/me/meal-plan') as Json);
    } on NotFoundFailure {
      return null;
    }
  }

  @override
  Future<void> savePlan(MealPlan plan) => _api.put('/households/me/meal-plan', mealPlanToJson(plan));

  @override
  Future<void> suggest(RecipeSuggestion suggestion) => _api.post('/recipe-suggestions', suggestionToJson(suggestion));
}

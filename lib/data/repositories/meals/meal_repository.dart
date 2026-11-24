// ─── Meal Repository ──────────────────────────────────────────────
import 'package:domease/domain/models/meal_plan.dart';
import 'package:domease/domain/models/recipe.dart';

/// Recipes from the library, the household's week, and suggestions.
abstract interface class MealRepository {
  /// Every published recipe (FR-CP-1). Pending suggestions never appear.
  Future<List<Recipe>> recipes();

  /// The saved week, or null if none has been planned yet.
  Future<MealPlan?> plan();

  Future<void> savePlan(MealPlan plan);

  /// Sent for review; it appears nowhere until a moderator approves it (FR-MP-13).
  Future<void> suggest(RecipeSuggestion suggestion);
}

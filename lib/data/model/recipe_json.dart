// ─── Recipe JSON ──────────────────────────────────────────────────
import 'package:domease/data/model/json.dart';
import 'package:domease/domain/models/household.dart';
import 'package:domease/domain/models/meal_plan.dart';
import 'package:domease/domain/models/recipe.dart';

Ingredient _ingredient(Json j) => Ingredient(
      amount: toDouble(j['amount'], 1),
      unit: (j['unit'] as String?) ?? 'pcs',
      name: j['name'] as String,
      substitute: j['substitute'] as String?,
    );

List<Ingredient> _ingredients(Object? v) => [for (final e in (v as List?) ?? const []) _ingredient(e as Json)];

Recipe recipeFromJson(Json j) {
  final hv = j['healthyVariant'] as Json?;
  return Recipe(
    id: j['id'] as String,
    name: j['name'] as String,
    mealType: byName(MealType.values, j['mealType'], MealType.dinner),
    cuisine: (j['cuisine'] as String?) ?? '',
    servings: toIntOrNull(j['servings']) ?? 4,
    ingredients: _ingredients(j['ingredients']),
    steps: strings(j['steps']),
    ageGroups: [for (final a in strings(j['ageGroups'])) byName(AgeGroup.values, a, AgeGroup.adults)],
    benefits: strings(j['benefits']),
    dietary: strings(j['dietary']),
    occasions: strings(j['occasions']),
    vegForward: j['vegForward'] == true,
    healthyVariant: hv == null
        ? null
        : HealthyVariant(summary: (hv['summary'] as String?) ?? '', ingredients: _ingredients(hv['ingredients']), steps: strings(hv['steps'])),
  );
}

Json suggestionToJson(RecipeSuggestion s) => {
      'name': s.name,
      'ingredientsRaw': s.ingredients,
      'methodRaw': s.method,
      if (s.mealType != null) 'suggestedMealType': s.mealType!.name,
    };

MealPlan mealPlanFromJson(Json j) => MealPlan({
      for (final t in MealType.values)
        if (j[t.name] != null) t: strings(j[t.name]),
    });

Json mealPlanToJson(MealPlan p) => {for (final e in p.days.entries) e.key.name: e.value};

// ─── Recipe ───────────────────────────────────────────────────────
// A dish from the library (served from the database, FR-CP-1). Amounts are
// metric and for [Recipe.servings] people; scale_recipe.dart sizes them to
// the household.
import 'package:domease/domain/models/household.dart';

enum MealType {
  breakfast('Breakfast'),
  lunch('Lunch'),
  dinner('Dinner'),
  snack('Snack'),
  pastry('Pastry');

  const MealType(this.label);
  final String label;
}

class Ingredient {
  const Ingredient({required this.amount, required this.unit, required this.name, this.substitute});

  final double amount;
  final String unit;
  final String name;

  /// "Can't find it? Try…" (FR-MP-4), shown on every plan.
  final String? substitute;
}

/// The Premium healthier version of a pastry (FR-MP-7).
class HealthyVariant {
  const HealthyVariant({required this.summary, required this.ingredients, required this.steps});

  final String summary;
  final List<Ingredient> ingredients;
  final List<String> steps;
}

class Recipe {
  const Recipe({
    required this.id,
    required this.name,
    required this.mealType,
    required this.cuisine,
    required this.servings,
    required this.ingredients,
    required this.steps,
    this.ageGroups = const [],
    this.benefits = const [],
    this.dietary = const [],
    this.occasions = const [],
    this.vegForward = false,
    this.healthyVariant,
  });

  final String id;
  final String name;
  final MealType mealType;
  final String cuisine;
  final int servings;
  final List<Ingredient> ingredients;
  final List<String> steps;
  final List<AgeGroup> ageGroups;
  final List<String> benefits;

  /// 'diabetic', 'pcos': Premium suggestions with the disclaimer (FR-MP-12).
  final List<String> dietary;

  /// 'birthday', 'christmas', 'easter', 'eid': Premium menus (FR-MP-9).
  final List<String> occasions;
  final bool vegForward;
  final HealthyVariant? healthyVariant;

  /// True when an ingredient matches any of [allergies] (FR-MP-11).
  bool contains(Set<String> allergies) =>
      allergies.isNotEmpty && ingredients.any((i) => allergies.any((a) => i.name.toLowerCase().contains(a)));
}

/// A dish idea a household sends in; it waits for a moderator (FR-MP-13).
class RecipeSuggestion {
  const RecipeSuggestion({required this.name, required this.ingredients, required this.method, this.mealType});

  final String name;
  final String ingredients;
  final String method;
  final MealType? mealType;
}

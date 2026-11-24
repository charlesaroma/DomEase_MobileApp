// ─── Scale Recipe ─────────────────────────────────────────────────
// Ingredient amounts sized to the household, metric only: 1000 g or more
// becomes kg, 1000 ml or more becomes l (FR-MP-3).
import 'package:domease/domain/models/recipe.dart';

List<Ingredient> scaleIngredients(List<Ingredient> ingredients, {required int from, required int to}) {
  final factor = from <= 0 ? 1.0 : to / from;
  return [
    for (final i in ingredients) _metric(Ingredient(amount: i.amount * factor, unit: i.unit, name: i.name, substitute: i.substitute)),
  ];
}

Ingredient _metric(Ingredient i) {
  if (i.unit == 'g' && i.amount >= 1000) return Ingredient(amount: i.amount / 1000, unit: 'kg', name: i.name, substitute: i.substitute);
  if (i.unit == 'ml' && i.amount >= 1000) return Ingredient(amount: i.amount / 1000, unit: 'l', name: i.name, substitute: i.substitute);
  return i;
}

/// "1.5 kg", "300 g", "2 pcs": whole numbers stay whole, the rest one decimal.
String formatAmount(Ingredient i) {
  final countable = const {'pcs', 'bunch', 'tsp', 'tbsp', 'cup'}.contains(i.unit);
  final a = countable ? (i.amount * 2).round() / 2 : i.amount;
  final n = a == a.roundToDouble() ? a.toStringAsFixed(0) : a.toStringAsFixed(1);
  return '$n ${i.unit}';
}

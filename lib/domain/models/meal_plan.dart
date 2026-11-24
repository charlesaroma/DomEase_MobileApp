// ─── Meal Plan ────────────────────────────────────────────────────
import 'package:domease/domain/models/recipe.dart';

/// Monday to Sunday for each meal type: seven recipe ids per type (FR-MP-1).
class MealPlan {
  const MealPlan(this.days);

  final Map<MealType, List<String>> days;

  List<String> of(MealType type) => days[type] ?? const [];

  /// The recipe planned for [type] on [weekday] (1 Monday to 7 Sunday).
  String? on(MealType type, int weekday) {
    final list = of(type);
    return list.length >= weekday ? list[weekday - 1] : null;
  }

  int get count => days.values.fold(0, (n, l) => n + l.length);

  MealPlan withType(MealType type, List<String> ids) => MealPlan({...days, type: ids});
}

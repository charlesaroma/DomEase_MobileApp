// ─── Insights View Models ─────────────────────────────────────────
// The food budget and its trips (saved from Done shopping on Shop), and the
// eating trends worked out from this week and the weeks before it.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:domease/config/dependencies.dart';
import 'package:domease/domain/models/insights.dart';
import 'package:domease/domain/models/meal_plan.dart';
import 'package:domease/domain/use_cases/insights.dart';
import 'package:domease/ui/meals/view_models/meals_viewmodel.dart';

final budgetProvider = AsyncNotifierProvider<BudgetNotifier, Budget>(BudgetNotifier.new);

class BudgetNotifier extends AsyncNotifier<Budget> {
  @override
  Future<Budget> build() => ref.watch(insightsRepositoryProvider).budget();

  Future<void> _set(Budget next) async {
    state = AsyncData(next);
    await ref.read(insightsRepositoryProvider).saveBudget(next);
  }

  Future<Budget> get _now async => state.value ?? await future;

  Future<void> setMonthly(int? monthly) async => _set((await _now).copyWith(monthly: () => monthly));

  Future<void> addTrip({required int estimate, required int actual, required int items}) async {
    final b = await _now;
    final trip = Trip(id: 'trip_${DateTime.now().millisecondsSinceEpoch}', date: DateTime.now(), estimate: estimate, actual: actual, items: items);
    await _set(b.copyWith(trips: [trip, ...b.trips]));
  }

  Future<void> removeTrip(String id) async {
    final b = await _now;
    await _set(b.copyWith(trips: [for (final t in b.trips) if (t.id != id) t]));
  }

  /// Puts back what was there before an undo.
  Future<void> restore(Budget before) => _set(before);
}

final budgetMonthProvider = Provider<AsyncValue<BudgetMonth>>((ref) => ref.watch(budgetProvider).whenData(budgetMonth));

final planHistoryProvider = FutureProvider<List<MealPlan>>((ref) => ref.watch(mealRepositoryProvider).history());

final trendsProvider = FutureProvider<EatingTrends>((ref) async {
  final recipes = await ref.watch(recipesProvider.future);
  final current = await ref.watch(mealPlanProvider.future);
  final history = await ref.watch(planHistoryProvider.future);
  return eatingTrends(history: history, current: current, byId: {for (final r in recipes) r.id: r});
});

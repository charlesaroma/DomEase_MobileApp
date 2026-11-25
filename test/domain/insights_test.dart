// ─── Insights Tests ───────────────────────────────────────────────
// Money people rely on: what is left of the budget, and what is still owed
// to the house help. The web app's src/ClientApp/lib/insights.js must agree.
import 'package:flutter_test/flutter_test.dart';

import 'package:domease/domain/models/insights.dart';
import 'package:domease/domain/models/meal_plan.dart';
import 'package:domease/domain/models/recipe.dart';
import 'package:domease/domain/use_cases/insights.dart';
import 'package:domease/utils/money.dart';

void main() {
  final today = DateTime(2026, 11, 25);

  group('budgetMonth', () {
    final budget = Budget(monthly: 600000, trips: [
      Trip(id: 'a', date: DateTime(2026, 11, 20), estimate: 100000, actual: 110000, items: 10),
      Trip(id: 'b', date: DateTime(2026, 11, 3), estimate: 100000, actual: 90000, items: 8),
      Trip(id: 'c', date: DateTime(2026, 10, 30), estimate: 0, actual: 50000, items: 3),
    ]);

    test('counts this month only, and what is left a day', () {
      final m = budgetMonth(budget, today: today);
      expect(m.spent, 200000);
      expect(m.trips, 2);
      expect(m.left, 400000);
      expect(m.percent, 33);
      expect(m.perDay, 400000 ~/ 6); // 25th to 30th November
    });

    test('compares the market with the estimate, skipping unpriced trips', () {
      expect(budgetMonth(budget, today: today).vsEstimate, 0);
    });

    test('six months for the chart, ending this month', () {
      final m = budgetMonth(budget, today: today);
      expect(m.byMonth.map((e) => e.$1), ['Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov']);
      expect(m.byMonth.last.$2, 200000);
      expect(m.byMonth[4].$2, 50000);
    });
  });

  group('payMonth', () {
    final grace = Staff(id: 's', name: 'Grace', role: 'House help', salary: 250000, payday: 31, startedOn: DateTime(2026, 1, 1), entries: [
      PayEntry(id: '1', date: DateTime(2026, 11, 6), kind: PayKind.advance, amount: 50000),
      PayEntry(id: '2', date: DateTime(2026, 11, 10), kind: PayKind.bonus, amount: 15000),
      PayEntry(id: '3', date: DateTime(2026, 11, 12), kind: PayKind.leave, days: 2),
      PayEntry(id: '4', date: DateTime(2026, 10, 28), kind: PayKind.pay, amount: 250000),
    ]);

    test('salary plus bonus, less advances and pay, gives what is owed', () {
      final m = payMonth(grace, month: (year: 2026, month: 11));
      expect(m.owed, 215000);
      expect(m.daysOff, 2);
      expect(m.entries.first.id, '3');
      expect(payMonth(grace, month: (year: 2026, month: 10)).owed, 0);
    });

    test('a payday of 31 falls on the 30th in November, and moves on once passed', () {
      expect(nextPayday(grace, today: today), DateTime(2026, 11, 30));
      expect(nextPayday(grace.copyWith(payday: 20), today: today), DateTime(2026, 12, 20));
    });

    test('the payslip lists only what applies', () {
      final text = payslipText(staff: grace, month: payMonth(grace, month: (year: 2026, month: 11)), home: 'Our home', money: (n) => money(n));
      expect(text, contains('Payslip, November 2026'));
      expect(text, contains('Advances: minus UGX 50,000'));
      expect(text, contains('Still to pay: UGX 215,000'));
      expect(text, isNot(contains('Deductions')));
    });
  });

  test('eatingTrends: lunches and dinners on top, repeats in three of four weeks', () {
    Recipe r(String id, MealType t, {bool veg = false}) => Recipe(id: id, name: id, mealType: t, cuisine: 'Ugandan', servings: 4, ingredients: const [], steps: const ['Cook.'], vegForward: veg);
    final byId = {for (final x in [r('stew', MealType.dinner), r('beans', MealType.dinner, veg: true), r('tea', MealType.breakfast, veg: true)]) x.id: x};
    final week = MealPlan({MealType.dinner: const ['stew', 'beans', 'stew'], MealType.breakfast: const ['tea', 'tea', 'tea']});
    final t = eatingTrends(history: [week, week, const MealPlan({})], current: week, byId: byId);
    expect(t.top.first.$1.id, 'stew');
    expect(t.top.map((e) => e.$1.id), isNot(contains('tea')));
    expect(t.onRepeat.map((x) => x.id).toSet(), {'stew', 'beans'});
    expect(t.different, 3);
    expect(t.vegForward, 67);
  });
}

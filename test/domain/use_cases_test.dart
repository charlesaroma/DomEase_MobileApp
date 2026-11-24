// ─── Use Case Tests ───────────────────────────────────────────────
// The places a silent bug is costly (PRD 15.4): scaling, the list, the
// converter and the fit score.
import 'package:flutter_test/flutter_test.dart';

import 'package:domease/domain/models/currency.dart';
import 'package:domease/domain/models/house_help.dart';
import 'package:domease/domain/models/meal_plan.dart';
import 'package:domease/domain/models/recipe.dart';
import 'package:domease/domain/models/shopping.dart';
import 'package:domease/domain/models/zone.dart';
import 'package:domease/domain/use_cases/build_shopping_list.dart';
import 'package:domease/domain/use_cases/convert_currency.dart';
import 'package:domease/domain/use_cases/plan_week.dart';
import 'package:domease/domain/use_cases/scale_recipe.dart';
import 'package:domease/domain/use_cases/score_candidate.dart';
import 'package:domease/utils/money.dart';

Recipe recipe(String id, MealType type, List<Ingredient> ingredients, {List<String> occasions = const []}) =>
    Recipe(id: id, name: id, mealType: type, cuisine: 'Ugandan', servings: 4, ingredients: ingredients, steps: const ['Cook.'], occasions: occasions);

void main() {
  group('scaleIngredients', () {
    test('scales to the household and moves to kg and l at 1000', () {
      final out = scaleIngredients(const [
        Ingredient(amount: 500, unit: 'g', name: 'Rice'),
        Ingredient(amount: 250, unit: 'ml', name: 'Milk'),
        Ingredient(amount: 2, unit: 'pcs', name: 'Onion'),
      ], from: 4, to: 8);
      expect(formatAmount(out[0]), '1 kg');
      expect(formatAmount(out[1]), '500 ml');
      expect(formatAmount(out[2]), '4 pcs');
    });

    test('counts round to the nearest half', () {
      final out = scaleIngredients(const [Ingredient(amount: 1, unit: 'pcs', name: 'Onion')], from: 4, to: 3);
      expect(formatAmount(out.single), '1 pcs');
    });
  });

  group('planWeek', () {
    final pool = [
      recipe('a', MealType.dinner, const [Ingredient(amount: 1, unit: 'kg', name: 'Groundnuts')]),
      recipe('b', MealType.dinner, const [Ingredient(amount: 1, unit: 'kg', name: 'Beef')]),
      recipe('c', MealType.dinner, const [], occasions: ['christmas']),
      recipe('d', MealType.lunch, const []),
    ];

    test('fills seven days from that meal type, never occasion menus', () {
      final week = planWeek(pool, MealType.dinner, seed: 1);
      expect(week, hasLength(7));
      expect(week.toSet(), {'a', 'b'});
    });

    test('allergy profiles leave out matching dishes', () {
      expect(planWeek(pool, MealType.dinner, seed: 1, allergies: {'groundnut'}).toSet(), {'b'});
    });

    test('the same seed gives the same week', () {
      expect(planWeek(pool, MealType.dinner, seed: 9), planWeek(pool, MealType.dinner, seed: 9));
    });

    test('Premium recipes go to Premium homes only', () {
      final withPremium = [
        ...pool,
        const Recipe(id: 'p', name: 'p', mealType: MealType.dinner, cuisine: 'Ugandan', servings: 4, ingredients: [], steps: ['Cook.'], isPremium: true),
      ];
      expect(planWeek(withPremium, MealType.dinner, seed: 1).toSet(), {'a', 'b'});
      expect(planWeek(withPremium, MealType.dinner, seed: 1, premium: true).toSet(), {'a', 'b', 'p'});
    });
  });

  group('buildShoppingList', () {
    test('merges meals and low consumables, skips unpriced things, keeps ticks', () {
      final list = buildShoppingList(
        plan: const MealPlan({MealType.dinner: ['a', 'a']}),
        recipes: [
          recipe('a', MealType.dinner, const [
            Ingredient(amount: 1, unit: 'kg', name: 'Groundnuts'),
            Ingredient(amount: 1, unit: 'l', name: 'Water'),
          ]),
        ],
        zones: const [
          Zone(id: 'z', name: 'Kitchen', tasks: [], consumables: [Consumable(id: 'c', name: 'Dish soap', cycle: Frequency.monthly, low: true)]),
        ],
        prices: const [
          MarketPrice(name: 'Groundnuts', pack: '1 kg', price: 8000, category: 'Grains and staples'),
          MarketPrice(name: 'Dish soap', pack: '750 ml', price: 6000, category: 'Household'),
        ],
        state: const ShopState(checked: {'item_dish_soap'}),
      );
      expect(list.map((i) => i.name), ['Groundnuts', 'Dish soap']);
      expect(list.last.low, isTrue);
      expect(list.last.checked, isTrue);
      expect(estimateTotal(list), 8000);
    });
  });

  test('convert goes through the dollar', () {
    const ugx = Currency(code: 'UGX', name: 'Shilling', perUsd: 3700);
    const kes = Currency(code: 'KES', name: 'Shilling', perUsd: 130);
    expect(convert(3700, ugx, kes), closeTo(130, 0.001));
  });

  test('scoreCandidate: share of the best total, flags weights of 1 or less', () {
    const options = [VettingOption(label: 'Yes', weight: 3), VettingOption(label: 'No', weight: 0)];
    const qs = [
      VettingQuestion(id: 'q1', section: 'Fit', text: 'Every day?', options: options),
      VettingQuestion(id: 'q2', section: 'Trust', text: 'References?', options: options),
    ];
    final r = scoreCandidate(qs, {'q1': 0, 'q2': 1});
    expect(r.percent, 50);
    expect(r.flags, ['References?']);
    expect(r.bySection, {'Fit': 100, 'Trust': 0});
  });

  test('money formats Shillings with commas', () {
    expect(money(46500), 'UGX 46,500');
    expect(money(12.5, 'USD'), 'USD 12.50');
  });
}

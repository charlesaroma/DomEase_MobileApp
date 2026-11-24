// ─── Meals ────────────────────────────────────────────────────────
// Five meal types, each a Monday to Sunday plan (FR-MP-1). Below the week:
// special dietary support (disclaimer always shown), occasion menus, and a
// way to suggest a dish.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:domease/domain/models/recipe.dart';
import 'package:domease/ui/core/themes/tokens.dart';
import 'package:domease/ui/core/themes/typography.dart';
import 'package:domease/ui/core/ui/ad_slot.dart';
import 'package:domease/ui/core/ui/async_view.dart';
import 'package:domease/ui/core/ui/readable_width.dart';
import 'package:domease/ui/core/ui/section_label.dart';
import 'package:domease/ui/meals/view_models/meals_viewmodel.dart';
import 'package:domease/ui/meals/widgets/meal_parts.dart';

class MealsScreen extends ConsumerWidget {
  const MealsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final type = ref.watch(selectedMealTypeProvider);
    final plan = ref.watch(mealPlanProvider);
    final recipes = ref.watch(recipesProvider);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: AppSpace.screen,
        title: Text('Meals', style: AppText.title.copyWith(color: scheme.onSurface)),
        actions: [
          TextButton.icon(
            onPressed: () async {
              await ref.read(mealPlanProvider.notifier).swap(type);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('A fresh week of ${type.label.toLowerCase()}s.')));
              }
            },
            icon: const Icon(Icons.swap_horiz),
            label: const Text('Swap week'),
          ),
          const SizedBox(width: AppSpace.sm),
        ],
      ),
      body: ReadableWidth(child: ListView(
        padding: const EdgeInsets.fromLTRB(0, AppSpace.sm, 0, AppSpace.huge),
        children: [
          // ── Meal types, as chips ──
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpace.screen),
              children: [
                for (final t in MealType.values)
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpace.sm),
                    child: ChoiceChip(
                      label: Text(t.label),
                      selected: t == type,
                      onSelected: (_) => ref.read(selectedMealTypeProvider.notifier).select(t),
                      showCheckmark: false,
                      shape: const StadiumBorder(),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.screen),
            child: AsyncView(
              value: plan,
              onRetry: () => ref.invalidate(mealPlanProvider),
              data: (p) => AsyncView(
                value: recipes,
                data: (all) {
                  final byId = {for (final r in all) r.id: r};
                  final today = DateTime.now().weekday;
                  return Column(children: [
                    const SizedBox(height: AppSpace.lg),
                    for (var day = 1; day <= 7; day++)
                      DayMealCard(
                        key: ValueKey('$type$day'),
                        weekday: day,
                        isToday: day == today,
                        recipe: byId[p.on(type, day)],
                      ),
                  ]);
                },
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpace.screen),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              AdSlot(screen: 'meals'),
              SectionLabel('More for your table'),
              DietarySupportCard(),
              SizedBox(height: AppSpace.md),
              OccasionsCard(),
              SizedBox(height: AppSpace.md),
              SuggestCard(),
            ]),
          ),
        ],
      )),
    );
  }
}

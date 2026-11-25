// ─── Trends View ──────────────────────────────────────────────────
// What the home eats, from this week and the weeks before it. Planned
// meals, not a food diary.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:domease/routing/routes.dart';
import 'package:domease/ui/core/themes/tokens.dart';
import 'package:domease/ui/core/themes/typography.dart';
import 'package:domease/ui/core/ui/async_view.dart';
import 'package:domease/ui/core/ui/recipe_photo.dart';
import 'package:domease/ui/core/ui/section_label.dart';
import 'package:domease/ui/insights/view_models/insights_viewmodel.dart';

class TrendsView extends ConsumerWidget {
  const TrendsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return AsyncView(
      value: ref.watch(trendsProvider),
      onRetry: () => ref.invalidate(trendsProvider),
      data: (t) => ListView(
        padding: const EdgeInsets.fromLTRB(AppSpace.screen, AppSpace.lg, AppSpace.screen, AppSpace.huge),
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpace.lg),
            decoration: BoxDecoration(color: dark ? const Color(0xFF24352A) : AppColors.sage100, borderRadius: AppRadii.cardAll),
            child: Text(
              'This week has ${t.different} different dishes, and ${t.vegForward}% of meals over the last ${t.weeks} weeks are vegetable forward.',
              style: AppText.label.copyWith(color: dark ? AppColors.sage200 : AppColors.sage800),
            ),
          ),
          const SizedBox(height: AppSpace.md),
          Row(children: [
            Expanded(child: _Stat(label: 'Variety this week', value: '${t.variety}%')),
            const SizedBox(width: AppSpace.md),
            Expanded(child: _Stat(label: 'Vegetable forward', value: '${t.vegForward}%')),
          ]),
          const SectionLabel('Most planned lunches and dinners'),
          Card(
            child: Column(children: [
              for (final (recipe, times) in t.top)
                ListTile(
                  onTap: () => context.go(Routes.recipe(recipe.id)),
                  leading: SizedBox(
                    width: 44,
                    child: RecipePhoto(recipe: recipe, aspectRatio: 1, radius: BorderRadius.circular(AppRadii.card / 2), iconSize: 20),
                  ),
                  title: Text(recipe.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: Text('$times times', style: AppText.money.copyWith(fontSize: 13, color: scheme.onSurface)),
                ),
            ]),
          ),
          if (t.onRepeat.isNotEmpty) ...[
            const SectionLabel('On repeat lately'),
            Text('In at least three of the last four weeks. Swap the week on Meals for something new.', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: AppSpace.sm),
            Text(t.onRepeat.map((r) => r.name).join(', '), style: AppText.body.copyWith(color: scheme.onSurface)),
          ],
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.lg),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: AppSpace.xs),
            Text(value, style: AppText.heading.copyWith(color: Theme.of(context).colorScheme.onSurface)),
          ]),
        ),
      );
}
